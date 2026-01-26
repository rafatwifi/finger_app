// lib/data/models/app_settings_model.dart
// موديل إعدادات النظام (مركزي) يُحفظ في Firestore

class AppSettingsModel {
  final String timeFormat; // "12" أو "24"
  final int maxScansPerDay; // عدد البصمات المسموحة باليوم
  final bool requireSupervisor; // يحتاج موافقة مشرف/مسؤول
  final bool requireLocation; // يحتاج تحقق موقع
  final bool requireBiometric; // يحتاج بصمة جهاز (مؤقت)

  // UI Theme (أساس للتحكم بالهوية)
  final String primaryColorHex; // مثل: "#FF6A00"
  final String accentColorHex; // مثل: "#00FFAA"
  final double logoSize; // حجم اللوغو في الواجهة
  final String slogan; // نص تحت/فوق اللوغو

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
  });

  // إعدادات افتراضية إذا ماكو وثيقة بعد
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
    );
  }

  // تحويل من Firestore Map
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
    );
  }

  // تحويل إلى Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'timeFormat': timeFormat,
      'maxScansPerDay': maxScansPerDay,
      'requireSupervisor': requireSupervisor,
      'requireLocation': requireLocation,
      'requireBiometric': requireBiometric,
      'uiTheme': {
        'primaryColor': primaryColorHex,
        'accentColor': accentColorHex,
        'logoSize': logoSize,
        'slogan': slogan,
      },
    };
  }

  // نسخ سريع عند التعديل داخل الشاشة
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
    );
  }

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
