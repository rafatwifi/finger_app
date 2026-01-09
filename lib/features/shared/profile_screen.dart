import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/app_user_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AppUserState.user!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.orange,
              child: Icon(Icons.person, size: 40, color: Colors.black),
            ),
            const SizedBox(height: 16),
            Text(user.email, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            Text(user.role.name, style: const TextStyle(color: Colors.grey)),
            const Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              icon: const Icon(Icons.logout),
              label: const Text('تسجيل خروج'),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
