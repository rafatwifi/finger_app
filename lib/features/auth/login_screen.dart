import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// شاشة تسجيل الدخول – تصميم جديد + منطق قديم شغال
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String? _error;

  /// دالة تسجيل الدخول باستخدام Firebase
  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // تسجيل الدخول باستخدام Firebase Auth
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // نجاح تسجيل الدخول
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      // أخطاء Firebase المتوقعة
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.code == 'wrong-password' || e.code == 'user-not-found'
              ? 'LOGIN FAIL'
              : e.message;
        });
      }
    } catch (_) {
      // أي خطأ غير متوقع
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'LOGIN FAIL';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E13),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fingerprint, size: 96, color: Color(0xFFFFD54F)),
              const SizedBox(height: 12),
              const Text(
                'ATTENDANCE SYSTEM',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'AUTHORIZED ACCESS ONLY',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // حقل الإيميل
              _buildInput(
                controller: _emailController,
                hint: 'Email',
                icon: Icons.email_outlined,
                obscure: false,
              ),
              const SizedBox(height: 16),

              // حقل الباسورد
              _buildInput(
                controller: _passwordController,
                hint: 'Password',
                icon: Icons.lock_outline,
                obscure: true,
              ),
              const SizedBox(height: 20),

              // رسالة الخطأ
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 14,
                    ),
                  ),
                ),

              // زر تسجيل الدخول
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD54F),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text(
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 16,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // أيقونة البصمة (شكل فقط)
              const Icon(Icons.fingerprint, size: 36, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }

  /// ويدجت حقل إدخال موحد
  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool obscure,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      cursorColor: const Color(0xFFFFD54F),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: Colors.white54),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFFFD54F)),
        ),
      ),
    );
  }
}
