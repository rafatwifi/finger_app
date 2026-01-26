import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';

/// حالة مستخدم التطبيق بشكل مركزي وبسيط.
/// الهدف: منع null غير متوقع + السماح لـ UI أن يستمع لتغير المستخدم.
class AppUserState {
  /// نستخدم ValueNotifier حتى نقدر نعمل rebuild عند تغيير المستخدم بدون حلول ثقيلة.
  static final ValueNotifier<UserModel?> userNotifier =
      ValueNotifier<UserModel?>(null);

  /// قراءة المستخدم الحالي.
  static UserModel? get user => userNotifier.value;

  /// تعيين المستخدم الحالي.
  static void set(UserModel? u) {
    userNotifier.value = u;
  }

  /// مسح المستخدم الحالي عند تسجيل الخروج أو فشل التحميل.
  static void clear() {
    userNotifier.value = null;
  }
}
