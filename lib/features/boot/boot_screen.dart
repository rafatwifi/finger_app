import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BootScreen extends StatelessWidget {
  const BootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          user == null ? 'NO SESSION' : 'SESSION OK',
          style: const TextStyle(
            color: Colors.green,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
