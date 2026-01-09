import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/firestore_user_repository_impl.dart';
import '../../core/services/app_user_state.dart';
import '../auth/login_screen.dart';
import '../shell/app_shell.dart';

class BootScreen extends StatelessWidget {
  const BootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: Colors.orange),
            ),
          );
        }

        if (!authSnap.hasData) {
          return const LoginScreen();
        }

        final firebaseUser = authSnap.data!;

        return FutureBuilder(
          future: FirestoreUserRepositoryImpl().getOrCreateUser(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? '',
          ),
          builder: (context, userSnap) {
            if (!userSnap.hasData) {
              return const Scaffold(
                backgroundColor: Colors.black,
                body: Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                ),
              );
            }

            AppUserState.set(userSnap.data!);

            return const AppShell(); // ← هذا الوحيد
          },
        );
      },
    );
  }
}
