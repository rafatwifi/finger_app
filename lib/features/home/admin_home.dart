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
        title: const Text('Admin'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // تسجيل خروج الأدمن
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: Colors.grey.shade900,
              child: ListTile(
                leading: const Icon(Icons.map, color: Colors.orange),
                title: const Text(
                  'Attendance Area',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Draw allowed zone',
                  style: TextStyle(color: Colors.grey),
                ),
                onTap: () {
                  // فتح محرر المنطقة
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PolygonEditorScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
