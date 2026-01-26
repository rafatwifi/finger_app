import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/services/app_user_state.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/firestore_user_repository_impl.dart';
import '../auth/login_screen.dart';
import '../shell/app_shell.dart';

class BootScreen extends StatefulWidget {
  const BootScreen({super.key});

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen> {
  StreamSubscription<User?>? _authSub;

  /// نخزن الـ Future هنا حتى ما يُعاد إنشاؤه مع كل build (هذا سبب شائع للـ spinner للأبد).
  Future<UserModel>? _loadUserFuture;

  /// نخزن آخر uid حتى لو تغيّر الحساب نعيد بناء Future مرة واحدة.
  String? _lastUid;

  /// نخزن رسالة خطأ واضحة بدل “صمت”.
  Object? _fatalError;

  final _repo = FirestoreUserRepositoryImpl();

  @override
  void initState() {
    super.initState();

    /// نراقب تغيّر تسجيل الدخول بشكل مباشر ونبني Future مرة واحدة لكل uid.
    _authSub = FirebaseAuth.instance.authStateChanges().listen(
      (firebaseUser) {
        if (!mounted) return;

        if (firebaseUser == null) {
          /// لا يوجد مستخدم: نمسح الحالة ونلغي أي Future قديم.
          setState(() {
            AppUserState.clear();
            _fatalError = null;
            _loadUserFuture = null;
            _lastUid = null;
          });
          return;
        }

        /// لو نفس uid لا نعيد بناء Future.
        if (_lastUid == firebaseUser.uid && _loadUserFuture != null) return;

        setState(() {
          _fatalError = null;
          _lastUid = firebaseUser.uid;

          /// نبني Future مرة واحدة، مع timeout حتى لا يبقى spinner للأبد.
          _loadUserFuture = _getOrCreateUserWithTimeout(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? '',
          );
        });
      },
      onError: (e) {
        /// أي خطأ في Stream نفسه يجب يظهر بدل spinner دائم.
        if (!mounted) return;
        setState(() {
          _fatalError = e;
        });
      },
    );
  }

  Future<UserModel> _getOrCreateUserWithTimeout({
    required String uid,
    required String email,
  }) async {
    try {
      /// timeout يمنع تعليق دائم بسبب شبكة/Firestore/Parsing.
      final user = await _repo
          .getOrCreateUser(uid: uid, email: email)
          .timeout(const Duration(seconds: 12));

      /// نخزن المستخدم في حالة التطبيق قبل فتح AppShell.
      AppUserState.set(user);
      return user;
    } catch (e) {
      /// أي استثناء هنا كان سابقاً “صامت” ويتركك في loading للأبد.
      AppUserState.clear();
      rethrow;
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// لو يوجد خطأ قاتل من auth stream نفسه.
    if (_fatalError != null) {
      return _FatalErrorView(
        title: 'خطأ في المصادقة',
        details: _fatalError.toString(),
        onRetry: () {
          /// إعادة المحاولة: نجبر إعادة الاستماع بإعادة تعيين الحالات.
          setState(() {
            _fatalError = null;
            _loadUserFuture = null;
            _lastUid = null;
            AppUserState.clear();
          });

          /// نقرأ المستخدم الحالي فوراً ونبني future (بدون انتظار stream).
          final u = FirebaseAuth.instance.currentUser;
          if (u != null) {
            setState(() {
              _lastUid = u.uid;
              _loadUserFuture = _getOrCreateUserWithTimeout(
                uid: u.uid,
                email: u.email ?? '',
              );
            });
          }
        },
      );
    }

    /// إذا لا يوجد مستخدم مسجل دخول حالياً -> LoginScreen.
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      return const LoginScreen();
    }

    /// إذا Future لم يُبنَ بعد (لحظة انتقال) نظهر تحميل بسيط.
    final f = _loadUserFuture;
    if (f == null) {
      return const _BootLoadingView();
    }

    return FutureBuilder<UserModel>(
      future: f,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _BootLoadingView();
        }

        if (snapshot.hasError) {
          return _FatalErrorView(
            title: 'فشل تحميل المستخدم',
            details: snapshot.error.toString(),
            onRetry: () {
              final u = FirebaseAuth.instance.currentUser;
              if (u == null) {
                setState(() {
                  _loadUserFuture = null;
                  _lastUid = null;
                  AppUserState.clear();
                });
                return;
              }

              setState(() {
                _fatalError = null;
                _lastUid = u.uid;
                _loadUserFuture = _getOrCreateUserWithTimeout(
                  uid: u.uid,
                  email: u.email ?? '',
                );
              });
            },
          );
        }

        /// نجاح: AppUserState تم تعيينه داخل future.
        return const AppShell();
      },
    );
  }
}

class _BootLoadingView extends StatelessWidget {
  const _BootLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _FatalErrorView extends StatelessWidget {
  final String title;
  final String details;
  final VoidCallback onRetry;

  const _FatalErrorView({
    required this.title,
    required this.details,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    details,
                    style: const TextStyle(fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: onRetry,
                      child: const Text('إعادة المحاولة'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
