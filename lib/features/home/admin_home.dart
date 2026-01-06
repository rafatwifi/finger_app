import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../admin/polygon_editor.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('ADMIN HOME'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // تسجيل خروج المستخدم الحالي
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PolygonEditorScreen()),
            );
          },
          child: const Text('Edit Attendance Area'),
        ),
      ),
    );
  }
}
