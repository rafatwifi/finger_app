import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/app_user_state.dart';
import '../../features/attendance/attendance_engine.dart';
import '../../data/models/fingerprint_rule_model.dart';

class EmployeeAttendanceScreen extends StatelessWidget {
  const EmployeeAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Employee'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // تسجيل خروج المستخدم
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // بطاقة البصمة
            Card(
              color: Colors.grey.shade900,
              child: ListTile(
                leading: const Icon(
                  Icons.fingerprint,
                  color: Colors.green,
                  size: 40,
                ),
                title: const Text(
                  'Submit Attendance',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Tap to send fingerprint',
                  style: TextStyle(color: Colors.grey),
                ),
                onTap: () async {
                  // محرك الحضور
                  final engine = AttendanceEngine();

                  // قاعدة وقت تجريبية
                  final rule = FingerprintRuleModel(
                    id: 'rule_test',
                    name: 'Default',
                    startTime: const TimeOfDay(hour: 7, minute: 0),
                    endTime: const TimeOfDay(hour: 18, minute: 0),
                  );

                  // إنشاء سجل حضور pending
                  final record = engine.buildRecord(
                    id: '',
                    userId: AppUserState.user!.id,
                    rule: rule,
                    timestamp: DateTime.now(),
                    latitude: 0,
                    longitude: 0,
                    isValid: true,
                  );

                  await FirebaseFirestore.instance
                      .collection('attendance_records')
                      .add(record.toMap());

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Submitted (Pending)')),
                    );
                  }
                },
              ),
            ),

            const SizedBox(height: 16),

            // بطاقة الحالة
            Card(
              color: Colors.grey.shade900,
              child: const ListTile(
                leading: Icon(Icons.info, color: Colors.orange),
                title: Text('Status', style: TextStyle(color: Colors.white)),
                subtitle: Text(
                  'Waiting for approval',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
