/*
هذا الملف مسؤول عن إدارة لغة التطبيق.
- يستخدم لغة الجهاز افتراضيًا
- يسمح بتغيير اللغة يدويًا لاحقًا من الإعدادات
- لا يفرض لغة إنجليزي بالقوة
*/

import 'dart:ui';
import 'package:flutter/material.dart';

class AppLocale extends ChangeNotifier {
  // اللغة الحالية للتطبيق (تبدأ بلغة الجهاز)
  late Locale _locale;

  AppLocale() {
    final deviceLocale = PlatformDispatcher.instance.locale;
    _locale = Locale(deviceLocale.languageCode);
  }

  Locale get locale => _locale;

  // تغيير اللغة إلى العربية
  void setArabic() {
    _locale = const Locale('ar');
    notifyListeners();
  }

  // تغيير اللغة إلى الإنجليزية
  void setEnglish() {
    _locale = const Locale('en');
    notifyListeners();
  }

  // تغيير اللغة ديناميكيًا
  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}
