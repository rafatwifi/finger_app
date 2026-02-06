// lib/main.dart
// نقطة تشغيل التطبيق
// - لغة افتراضية = لغة الجهاز
// - لغة من Firestore (appLanguageCode)
// - منع loop وإعادة set أثناء build

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'core/localization/app_locale.dart';
import 'core/ui/login_logo_controller.dart';
import 'data/repositories/settings_repository.dart';
import 'data/models/app_settings_model.dart';
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

    return StreamBuilder<AppSettingsModel>(
      stream: SettingsRepository().watch(),
      builder: (context, snap) {
        if (snap.hasData) {
          final code = snap.data!.appLanguageCode;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            appLocale.applyLanguageCode(code);
          });
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: appLocale.locale,
          supportedLocales: const [
            Locale('ar'),
            Locale('en'),
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
      },
    );
  }
}
