// lib/core/services/app_settings.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// إعدادات عامة للتطبيق
/// الهدف: لوغو واحد مركزي يظهر لكل المستخدمين
class AppSettings {
  static String? globalLogoType; // messenger / archive / custom
  static String? globalLogoUrl; // رابط صورة في حال custom

  /// تحميل الإعدادات من Firestore
  static Future<void> load() async {
    final snap = await FirebaseFirestore.instance
        .collection('settings')
        .doc('app')
        .get();

    if (!snap.exists) return;

    final data = snap.data()!;
    globalLogoType = data['logoType'];
    globalLogoUrl = data['logoUrl'];
  }
}
