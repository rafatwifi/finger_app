import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/app_user_state.dart';
import '../../features/attendance/attendance_engine.dart';
import '../../data/models/fingerprint_rule_model.dart';

class EmployeeAttendanceScreen extends StatelessWidget {
  const EmployeeAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AppUserState.user!;

    return Scaffold(
      backgroundColor: Colors.black,

      // شريط علوي
      appBar: AppBar(
        title: const Text('Employee Attendance'),
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

      body: Column(
        children: [
          // بطاقة المستخدم
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.person, color: Colors.black, size: 30),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.email,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'EMPLOYEE',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // زر البصمة الكبير
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  final engine = AttendanceEngine();

                  final rule = FingerprintRuleModel(
                    id: 'rule_test',
                    name: 'Default Rule',
                    startTime: const TimeOfDay(hour: 7, minute: 0),
                    endTime: const TimeOfDay(hour: 17, minute: 0),
                  );

                  final record = engine.buildRecord(
                    id: '',
                    userId: user.id,
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
                      const SnackBar(
                        content: Text('Attendance sent (pending)'),
                      ),
                    );
                  }
                },
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Colors.orange, Colors.deepOrange],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.5),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.fingerprint,
                    size: 80,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),

          // آخر حالة
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('attendance_records')
                .where('userId', isEqualTo: user.id)
                .orderBy('timestamp', descending: true)
                .limit(1)
                .snapshots(),
            builder: (context, snap) {
              if (!snap.hasData || snap.data!.docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No attendance yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              final d = snap.data!.docs.first;
              final status = d['status'];

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Last status: $status',
                  style: TextStyle(
                    color: status == 'approved'
                        ? Colors.green
                        : status == 'rejected'
                        ? Colors.red
                        : Colors.orange,
                    fontSize: 16,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
