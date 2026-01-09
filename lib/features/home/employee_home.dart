import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../employee/employee_attendance.dart';

class EmployeeHome extends StatelessWidget {
  const EmployeeHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('EMPLOYEE'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // تسجيل خروج من Firebase حتى يطلب تسجيل دخول من جديد
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // زر البصمة (إرسال حضور)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.fingerprint),
                label: const Text('Submit Attendance'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EmployeeAttendanceScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'اذا الزر ما يسوي شي: المشكلة تكون بالصلاحيات/الموقع/جلب المضلع',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
