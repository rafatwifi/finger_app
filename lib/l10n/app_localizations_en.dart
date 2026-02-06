// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  // ===== Common / Generic =====
  @override
  String get language => 'Language';

  @override
  String get system => 'System';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get title => 'Title';

  @override
  String get editTitle => 'Edit title';

  // 🔽 جديد: عنوان الهيدر في شاشة الأدمن
  @override
  String get controlCore => 'CONTROL CORE';

  // ===== Auth =====
  @override
  String get loginTitle => 'Login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get loginButton => 'Sign In';

  @override
  String get invalidCredentials => 'Invalid email or password';

  // ===== Admin =====
  @override
  String get adminSettingsTitle => 'Admin Settings';

  @override
  String get loginScreenLogo => 'Login Screen Logo';

  @override
  String get manage => 'Manage';

  @override
  String get changeLoginLogo => 'Change login logo';

  @override
  String get removeLoginLogo => 'Remove login logo';

  @override
  String get timeFormat => 'Time Format';

  @override
  String get dailyScansLimit => 'Daily Scans Limit';

  @override
  String get maxScansPerDay => 'Max scans per day';

  @override
  String get validationRules => 'Validation Rules';

  @override
  String get requireSupervisor => 'Require Supervisor Approval';

  @override
  String get requireLocation => 'Require Location';

  @override
  String get requireBiometric => 'Require Biometric (Device)';

  @override
  String get theme => 'Theme';

  @override
  String get primaryColor => 'Primary Color';

  @override
  String get accentColor => 'Accent Color';

  @override
  String get logoSize => 'Logo size';

  @override
  String get slogan => 'Slogan';

  // ===== Actions =====
  @override
  String get save => 'Save';

  @override
  String get apply => 'Apply';

  @override
  String get saved => 'Saved';

  @override
  String get applied => 'Applied';
}
