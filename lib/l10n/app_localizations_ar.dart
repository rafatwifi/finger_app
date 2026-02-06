// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  // ===== Common / Generic =====
  @override
  String get language => 'اللغة';

  @override
  String get system => 'النظام';

  @override
  String get ok => 'موافق';

  @override
  String get cancel => 'إلغاء';

  @override
  String get title => 'العنوان';

  @override
  String get editTitle => 'تعديل العنوان';

  // 🔽 جديد: عنوان الهيدر في شاشة الأدمن
  @override
  String get controlCore => 'مركز التحكم';

  // ===== Auth =====
  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get loginButton => 'دخول';

  @override
  String get invalidCredentials => 'البريد الإلكتروني أو كلمة المرور غير صحيحة';

  // ===== Admin =====
  @override
  String get adminSettingsTitle => 'إعدادات المدير';

  @override
  String get loginScreenLogo => 'لوغو شاشة الدخول';

  @override
  String get manage => 'إدارة';

  @override
  String get changeLoginLogo => 'تغيير لوغو الدخول';

  @override
  String get removeLoginLogo => 'حذف لوغو الدخول';

  @override
  String get timeFormat => 'تنسيق الوقت';

  @override
  String get dailyScansLimit => 'الحد اليومي للبصمات';

  @override
  String get maxScansPerDay => 'أقصى عدد باليوم';

  @override
  String get validationRules => 'قواعد التحقق';

  @override
  String get requireSupervisor => 'يتطلب موافقة مشرف';

  @override
  String get requireLocation => 'يتطلب الموقع';

  @override
  String get requireBiometric => 'يتطلب بصمة الجهاز';

  @override
  String get theme => 'الثيم';

  @override
  String get primaryColor => 'اللون الأساسي';

  @override
  String get accentColor => 'اللون الثانوي';

  @override
  String get logoSize => 'حجم اللوغو';

  @override
  String get slogan => 'الشعار';

  // ===== Actions =====
  @override
  String get save => 'حفظ';

  @override
  String get apply => 'تطبيق';

  @override
  String get saved => 'تم الحفظ';

  @override
  String get applied => 'تم التطبيق';
}
