/*
هذا الملف مسؤول عن المصادقة (Authentication).
تم تعديله لمعالجة أخطاء Firebase بشكل منظم
وإرجاع كود خطأ مفهوم بدل رسالة تقنية.
*/

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // تحويل أخطاء Firebase إلى كود موحد
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        throw AuthException('invalid_credentials');
      }

      if (e.code == 'invalid-email') {
        throw AuthException('invalid_email');
      }

      // أي خطأ آخر
      throw AuthException('unknown_error');
    }
  }
}

/*
Exception مخصص للتطبيق
يُستخدم لاحقًا لربط الرسالة باللغة
*/
class AuthException implements Exception {
  final String code;
  AuthException(this.code);
}
