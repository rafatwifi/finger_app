/*
نقطة تشغيل التطبيق.
- إضافة Provider خاص بـ LoginLogoController
- الإبقاء على AppLocale
- بدون تغيير Firebase أو Navigation أو الثيم
*/

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'core/localization/app_locale.dart';
import 'core/ui/login_logo_controller.dart';
import 'features/boot/boot_screen.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppLocale()),
        ChangeNotifierProvider(create: (_) => LoginLogoController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocale = context.watch<AppLocale>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: appLocale.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: ThemeMode.system,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const BootScreen(),
    );
  }
}
