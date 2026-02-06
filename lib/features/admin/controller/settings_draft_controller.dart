/*
هذا الملف مسؤول عن إدارة إعدادات الأدمن بنظام Draft (غير فوري).

الوظيفة:
- تحميل الإعدادات مرة واحدة من Firestore.
- إنشاء نسخة Draft للتعديل بدون حفظ مباشر.
- تتبع هل يوجد تغييرات غير محفوظة بشكل صحيح.
- دعم Save (محلي) و Apply (Firestore).

ملاحظة مهمة:
- AppSettingsModel لا يملك operator == لذلك المقارنة (_draft != _original)
  كانت تعطي نتيجة خاطئة دائمًا.
- تم استبدالها بمقارنة على مستوى Map عبر toMap().
*/

import 'package:flutter/material.dart';
import '../../../data/models/app_settings_model.dart';
import '../../../data/repositories/settings_repository.dart';

class SettingsDraftController extends ChangeNotifier {
  final SettingsRepository _repository;

  AppSettingsModel? _original;
  AppSettingsModel? _draft;

  bool _hasChanges = false;

  SettingsDraftController(this._repository);

  bool get isReady => _draft != null;
  bool get hasChanges => _hasChanges;

  AppSettingsModel get value {
    if (_draft == null) {
      throw Exception('SettingsDraftController not initialized');
    }
    return _draft!;
  }

  Future<void> load() async {
    _original = await _repository.getOnce();
    _draft = _original;
    _hasChanges = false;
    notifyListeners();
  }

  void update(AppSettingsModel updated) {
    _draft = updated;

    // مقارنة حقيقية لمحتوى الإعدادات
    _hasChanges = !_isSameSettings(_draft, _original);

    notifyListeners();
  }

  /// Save = تثبيت التعديلات محليًا فقط
  void saveDraft() {
    _original = _draft;

    // بعد الحفظ المحلي نعتبر لا يوجد تغييرات (حتى يظهر APPLY فقط)
    _hasChanges = false;

    notifyListeners();
  }

  /// Apply = إرسال Firestore
  Future<void> apply() async {
    if (_draft == null) return;

    // لا نرسل إذا لا توجد تغييرات
    if (!_hasChanges && _isSameSettings(_draft, _original)) return;

    await _repository.save(_draft!);
    _original = _draft;
    _hasChanges = false;
    notifyListeners();
  }

  void reset() {
    _draft = _original;
    _hasChanges = false;
    notifyListeners();
  }

  // ===== Helpers =====

  bool _isSameSettings(AppSettingsModel? a, AppSettingsModel? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;

    // مقارنة على مستوى Map لضمان المقارنة الصحيحة
    final mapA = a.toMap();
    final mapB = b.toMap();

    return _deepMapEquals(mapA, mapB);
  }

  bool _deepMapEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;

    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;

      final va = a[key];
      final vb = b[key];

      if (va is Map<String, dynamic> && vb is Map<String, dynamic>) {
        if (!_deepMapEquals(va, vb)) return false;
      } else {
        if (va != vb) return false;
      }
    }

    return true;
  }
}
