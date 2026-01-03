import 'package:flutter/material.dart';
import '../../core/utils/permission_guard.dart';
import '../../core/constants/permissions.dart';

class SupervisorHome extends StatelessWidget {
  const SupervisorHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'SUPERVISOR HOME',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            if (PermissionGuard.can(Permission.approveAttendance))
              ElevatedButton(
                onPressed: () {},
                child: const Text('Approve Attendance'),
              ),

            if (PermissionGuard.can(Permission.manageUsers))
              ElevatedButton(
                onPressed: () {},
                child: const Text('Manage Users'),
              ),
          ],
        ),
      ),
    );
  }
}
