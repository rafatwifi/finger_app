import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final _auth = LocalAuthentication();

  static Future<bool> authenticate() async {
    try {
      // تحقق إذا الجهاز يدعم البصمة
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) return false;

      // طلب بصمة فعلي من النظام
      return await _auth.authenticate(
        localizedReason: 'Confirm your identity',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
