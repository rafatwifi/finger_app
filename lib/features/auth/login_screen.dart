/*
شاشة تسجيل الدخول.
- نفس التصميم الحالي
- لوغو علوي ديناميكي:
  - صورة مرفوعة إن وُجدت
  - وإلا أيقونة البصمة الافتراضية
- بدون تغيير أي Widget آخر

التعديل الوحيد:
- إزالة ! من AppLocalizations.of(context) لحل التحذير الأصفر.
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/auth_service.dart';
import '../../core/ui/login_logo_controller.dart';
import '../../l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // تحميل اللوغو المحفوظ إن وُجد
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoginLogoController>().loadSavedLogo();
    });
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on AuthException {
      final l10n = AppLocalizations.of(context);
      setState(() {
        _error = l10n.invalidCredentials;
      });
    } catch (_) {
      final l10n = AppLocalizations.of(context);
      setState(() {
        _error = l10n.invalidCredentials;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final logoController = context.watch<LoginLogoController>();
    final logoImage = logoController.logoImage;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // اللوغو العلوي
              logoImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(48),
                      child: Image(
                        image: logoImage,
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(Icons.fingerprint, size: 96, color: colors.primary),

              const SizedBox(height: 12),

              Text(
                l10n.loginTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),

              Text(
                'AUTHORIZED ACCESS ONLY',
                style: theme.textTheme.bodySmall?.copyWith(
                  letterSpacing: 1.5,
                  color: colors.onBackground.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 40),

              _buildInput(
                context: context,
                controller: _emailController,
                hint: l10n.email,
                icon: Icons.email_outlined,
                obscure: false,
              ),
              const SizedBox(height: 16),

              _buildInput(
                context: context,
                controller: _passwordController,
                hint: l10n.password,
                icon: Icons.lock_outline,
                obscure: true,
              ),
              const SizedBox(height: 20),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: colors.error,
                      fontSize: 14,
                    ),
                  ),
                ),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.onPrimary,
                          ),
                        )
                      : Text(
                          l10n.loginButton,
                          style: const TextStyle(
                            fontSize: 16,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool obscure,
  }) {
    final colors = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: colors.onBackground),
      cursorColor: colors.primary,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: colors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: colors.primary),
        ),
      ),
    );
  }
}
