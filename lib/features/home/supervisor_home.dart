import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/utils/permission_guard.dart';
import '../../core/constants/permissions.dart';
import '../supervisor/attendance_queue.dart';

class SupervisorHome extends StatelessWidget {
  const SupervisorHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('SUPERVISOR'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // تسجيل خروج
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (PermissionGuard.can(Permission.approveAttendance))
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.rule_folder),
                  label: const Text('Pending Attendance'),
                  onPressed: () {
                    // فتح شاشة قائمة المعلّق
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SupervisorAttendanceQueue(),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            if (PermissionGuard.can(Permission.manageUsers))
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.manage_accounts),
                  label: const Text('Manage Users'),
                  onPressed: () {},
                ),
              ),
          ],
        ),
      ),
    );
  }
}
