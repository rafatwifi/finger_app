import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// الملف المركزي لتعريف مفاتيح التعريب.
/// أي نص يُستخدم في الواجهات يجب أن يكون معرف هنا.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  // ===== Common / Generic =====
  String get language;
  String get system;

  String get ok;
  String get cancel;

  String get title;
  String get editTitle;

  // 🔽 جديد: عنوان الهيدر في شاشة الأدمن
  String get controlCore;

  // ===== Auth =====
  String get loginTitle;
  String get email;
  String get password;
  String get loginButton;
  String get invalidCredentials;

  // ===== Admin / Settings =====
  String get adminSettingsTitle;
  String get loginScreenLogo;
  String get manage;
  String get changeLoginLogo;
  String get removeLoginLogo;

  String get timeFormat;
  String get dailyScansLimit;
  String get maxScansPerDay;

  String get validationRules;
  String get requireSupervisor;
  String get requireLocation;
  String get requireBiometric;

  String get theme;
  String get primaryColor;
  String get accentColor;
  String get logoSize;
  String get slogan;

  // ===== Actions =====
  String get save;
  String get apply;
  String get saved;
  String get applied;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(
      lookupAppLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'Unsupported locale "$locale".',
  );
}
