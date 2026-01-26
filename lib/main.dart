import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'features/boot/boot_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// أي خطأ غير ملتقط سابقاً كان يتركك في spinner أو شاشة سوداء بدون تفسير.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  /// تشغيل Firebase قبل أي شيء.
  await Firebase.initializeApp();

  runApp(const FingerApp());
}

class FingerApp extends StatelessWidget {
  const FingerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      /// اتجاه عربي RTL من البداية.
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },

      home: const BootScreen(),
    );
  }
}
