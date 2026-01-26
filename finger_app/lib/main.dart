import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/services/app_settings.dart';
import 'features/boot/boot_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // تحميل إعدادات التطبيق العامة (لوغو – نوع التطبيق)
  await AppSettings.load();

  runApp(const FingerApp());
}

class FingerApp extends StatelessWidget {
  const FingerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const BootScreen(),
    );
  }
}
