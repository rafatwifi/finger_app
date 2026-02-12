// lib/data/models/app_settings_model.dart
// موديل إعدادات النظام (مركزي) يُحفظ في Firestore
//
// الوظيفة:
// - تخزين إعدادات الأدمن
// - دعم لغة التطبيق
// - دعم لوغو عالمي مجاني داخل Firestore بدون Firebase Storage
//
// التعديل الجديد في هذا الملف:
// - إضافة appLoginLogoBase64 داخل uiTheme
//   هذا يعني:
//   - الأدمن يرفع صورة
//   - تنحفظ كنص Base64 داخل Firestore
//   - كل الأجهزة تقرأها وتعرضها بدون Storage وبدون فلوس

class AppSettingsModel {
  final String timeFormat;
  final int maxScansPerDay;
  final bool requireSupervisor;
  final bool requireLocation;
  final bool requireBiometric;

  // UI Theme
  final String primaryColorHex;
  final String accentColorHex;
  final double logoSize;
  final String slogan;

  // Login logo
  final String? loginLogoUrl;

  // 🔽 جديد: لوغو عالمي مجاني داخل Firestore (Base64)
  // null => ماكو لوغو عالمي
  final String? appLoginLogoBase64;

  // 🔽 لغة التطبيق المختارة (null = لغة الجهاز)
  final String? appLanguageCode; // "ar" | "en" | null

  const AppSettingsModel({
    required this.timeFormat,
    required this.maxScansPerDay,
    required this.requireSupervisor,
    required this.requireLocation,
    required this.requireBiometric,
    required this.primaryColorHex,
    required this.accentColorHex,
    required this.logoSize,
    required this.slogan,
    this.loginLogoUrl,
    this.appLoginLogoBase64,
    this.appLanguageCode,
  });

  factory AppSettingsModel.defaults() {
    return const AppSettingsModel(
      timeFormat: '24',
      maxScansPerDay: 4,
      requireSupervisor: true,
      requireLocation: true,
      requireBiometric: true,
      primaryColorHex: '#FF6A00',
      accentColorHex: '#00FFAA',
      logoSize: 120,
      slogan: 'ATTEND OR BE SEEN',
      loginLogoUrl: null,
      appLoginLogoBase64: null,
      appLanguageCode: null, // لغة الجهاز
    );
  }

  factory AppSettingsModel.fromMap(Map<String, dynamic>? data) {
    final d = data ?? {};
    final ui = (d['uiTheme'] as Map<String, dynamic>?) ?? {};

    return AppSettingsModel(
      timeFormat: (d['timeFormat'] ?? '24').toString(),
      maxScansPerDay: _asInt(d['maxScansPerDay'], 4),
      requireSupervisor: _asBool(d['requireSupervisor'], true),
      requireLocation: _asBool(d['requireLocation'], true),
      requireBiometric: _asBool(d['requireBiometric'], true),
      primaryColorHex: (ui['primaryColor'] ?? '#FF6A00').toString(),
      accentColorHex: (ui['accentColor'] ?? '#00FFAA').toString(),
      logoSize: _asDouble(ui['logoSize'], 120),
      slogan: (ui['slogan'] ?? 'ATTEND OR BE SEEN').toString(),

      // قديم (اختياري)
      loginLogoUrl: ui['loginLogoUrl']?.toString(),

      // 🔽 جديد
      appLoginLogoBase64: ui['appLoginLogoBase64']?.toString(),

      appLanguageCode: d['appLanguageCode']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timeFormat': timeFormat,
      'maxScansPerDay': maxScansPerDay,
      'requireSupervisor': requireSupervisor,
      'requireLocation': requireLocation,
      'requireBiometric': requireBiometric,
      'appLanguageCode': appLanguageCode,
      'uiTheme': {
        'primaryColor': primaryColorHex,
        'accentColor': accentColorHex,
        'logoSize': logoSize,
        'slogan': slogan,

        // قديم
        'loginLogoUrl': loginLogoUrl,

        // 🔽 جديد
        'appLoginLogoBase64': appLoginLogoBase64,
      },
    };
  }

  /// copyWith:
  /// - الحقول العادية: null يعني "لا تغيّر"
  /// - appLanguageCode: نحتاج دعم null كقيمة فعلية (System)
  /// - appLoginLogoBase64: نحتاج دعم null كقيمة فعلية (حذف اللوغو)
  AppSettingsModel copyWith({
    String? timeFormat,
    int? maxScansPerDay,
    bool? requireSupervisor,
    bool? requireLocation,
    bool? requireBiometric,
    String? primaryColorHex,
    String? accentColorHex,
    double? logoSize,
    String? slogan,
    String? loginLogoUrl,

    /// 🔽 مهم:
    /// - إذا لم ترسل هذا المتغير إطلاقًا => لا تغيّر
    /// - إذا أرسلته null => حذف اللوغو العالمي
    Object? appLoginLogoBase64 = _noChange,

    /// مهم:
    /// - إذا لم ترسل هذا المتغير إطلاقًا => لا تغيّر
    /// - إذا أرسلته null => يعني System
    Object? appLanguageCode = _noChange,
  }) {
    return AppSettingsModel(
      timeFormat: timeFormat ?? this.timeFormat,
      maxScansPerDay: maxScansPerDay ?? this.maxScansPerDay,
      requireSupervisor: requireSupervisor ?? this.requireSupervisor,
      requireLocation: requireLocation ?? this.requireLocation,
      requireBiometric: requireBiometric ?? this.requireBiometric,
      primaryColorHex: primaryColorHex ?? this.primaryColorHex,
      accentColorHex: accentColorHex ?? this.accentColorHex,
      logoSize: logoSize ?? this.logoSize,
      slogan: slogan ?? this.slogan,
      loginLogoUrl: loginLogoUrl ?? this.loginLogoUrl,
      appLoginLogoBase64: appLoginLogoBase64 == _noChange
          ? this.appLoginLogoBase64
          : appLoginLogoBase64 as String?,
      appLanguageCode: appLanguageCode == _noChange
          ? this.appLanguageCode
          : appLanguageCode as String?,
    );
  }

  // Sentinel value حتى نفرّق بين:
  // - "لم يتم تمرير قيمة"
  // - "تم تمرير null فعليًا"
  static const Object _noChange = Object();

  static int _asInt(dynamic v, int fallback) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  static double _asDouble(dynamic v, double fallback) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  static bool _asBool(dynamic v, bool fallback) {
    if (v is bool) return v;
    if (v is String) {
      final s = v.toLowerCase().trim();
      if (s == 'true') return true;
      if (s == 'false') return false;
    }
    return fallback;
  }
}
