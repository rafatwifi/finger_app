import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../supervisor/attendance_queue.dart';

class SupervisorHome extends StatelessWidget {
  const SupervisorHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('SUPERVISOR HOME'),
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
                builder: (_) => const SupervisorAttendanceQueue(),
              ),
            );
          },
          child: const Text('Approve Attendance'),
        ),
      ),
    );
  }
}
