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
        title: const Text('EMPLOYEE HOME'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const EmployeeAttendanceScreen(),
              ),
            );
          },
          child: const Text('Submit Attendance'),
        ),
      ),
    );
  }
}
