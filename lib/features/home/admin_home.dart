import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../admin/polygon_editor.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('ADMIN'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // تسجيل خروج من Firebase
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.map),
                label: const Text('Draw Attendance Area'),
                onPressed: () {
                  // فتح شاشة رسم المضلع
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PolygonEditorScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'ارسم المنطقة مرة وحدة وخزّنها، بعدها الموظف يتفحص داخل/خارج.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
