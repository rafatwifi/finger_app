// lib/core/localization/app_locale.dart
// مسؤول عن لغة التطبيق
// - الافتراضي: لغة الجهاز
// - يدعم لغة من الإعدادات (ar / en / null)
// - متوافق مع main.dart (applyLanguageCode)

import 'dart:ui';
import 'package:flutter/material.dart';

class AppLocale extends ChangeNotifier {
  Locale _locale;

  AppLocale()
      : _locale = Locale(
          PlatformDispatcher.instance.locale.languageCode,
        );

  Locale get locale => _locale;

  // تُستدعى من main.dart
  void applyLanguageCode(String? code) {
    if (code == null) {
      final device = PlatformDispatcher.instance.locale.languageCode;
      _setIfDifferent(Locale(device));
    } else {
      _setIfDifferent(Locale(code));
    }
  }

  // ما نعيد notify إلا إذا فعليًا تغيّرت اللغة
  void _setIfDifferent(Locale next) {
    if (_locale.languageCode == next.languageCode) return;
    _locale = next;
    notifyListeners();
  }

  // إبقاء الدوال القديمة للتوافق
  void setLocale(Locale locale) {
    _setIfDifferent(locale);
  }

  void setArabic() {
    _setIfDifferent(const Locale('ar'));
  }

  void setEnglish() {
    _setIfDifferent(const Locale('en'));
  }
}
