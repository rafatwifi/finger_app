// lib/data/repositories/settings_repository.dart
// مستودع قراءة/تحديث إعدادات النظام من Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_settings_model.dart';

class SettingsRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // مسار وثيقة الإعدادات الرئيسية
  DocumentReference<Map<String, dynamic>> get _ref =>
      _db.collection('settings').doc('attendance_config');

  // بث مباشر للإعدادات (Realtime)
  Stream<AppSettingsModel> watch() {
    return _ref.snapshots().map((snap) {
      // إذا الوثيقة غير موجودة ننشئها افتراضيًا مرة واحدة
      if (!snap.exists) {
        final defaults = AppSettingsModel.defaults();
        _ref.set(defaults.toMap(), SetOptions(merge: true));
        return defaults;
      }
      return AppSettingsModel.fromMap(snap.data());
    });
  }

  // تحميل مرة واحدة
  Future<AppSettingsModel> getOnce() async {
    final snap = await _ref.get();
    if (!snap.exists) {
      final defaults = AppSettingsModel.defaults();
      await _ref.set(defaults.toMap(), SetOptions(merge: true));
      return defaults;
    }
    return AppSettingsModel.fromMap(snap.data());
  }

  // حفظ/تحديث
  Future<void> save(AppSettingsModel settings) async {
    await _ref.set(settings.toMap(), SetOptions(merge: true));
  }
}
