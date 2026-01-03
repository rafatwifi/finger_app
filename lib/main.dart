import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      home: const Scaffold(body: Center(child: Text(AppConstants.appName))),
    );
  }
}
