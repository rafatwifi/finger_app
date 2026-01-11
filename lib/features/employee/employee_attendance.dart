import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import '../../core/services/app_user_state.dart';
import '../../features/attendance/attendance_engine.dart';
import '../../data/models/fingerprint_rule_model.dart';
import '../../core/services/biometric_service.dart';

class EmployeeAttendanceScreen extends StatelessWidget {
  const EmployeeAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // جلب المستخدم الحالي من Firebase مباشرة لتفادي null
    final firebaseUser = FirebaseAuth.instance.currentUser;

    // إذا ماكو مستخدم مسجل دخول، نطلع شاشة فاضية بدون كراش
    if (firebaseUser == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'No user logged in',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text('Employee Attendance'),
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

      body: Column(
        children: [
          // بطاقة معلومات المستخدم
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
                      firebaseUser.email ?? 'Unknown',
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

          // زر البصمة الحيوية
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  // تنفيذ التحقق البيومتري الحقيقي
                  final bool authResult = await BiometricService.authenticate();

                  // إذا فشل التحقق نوقف التنفيذ
                  if (!authResult) return;

                  // إنشاء محرك الحضور
                  final engine = AttendanceEngine();

                  // قاعدة وقت افتراضية
                  final rule = FingerprintRuleModel(
                    id: 'rule_test',
                    name: 'Default Rule',
                    startTime: const TimeOfDay(hour: 7, minute: 0),
                    endTime: const TimeOfDay(hour: 17, minute: 0),
                  );

                  // إنشاء سجل حضور
                  final record = engine.buildRecord(
                    id: '',
                    userId: firebaseUser.uid,
                    rule: rule,
                    timestamp: DateTime.now(),
                    latitude: 0,
                    longitude: 0,
                    isValid: true,
                  );

                  // حفظ السجل في Firestore
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
                        color: Colors.orange.withValues(alpha: 0.5),
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

          // عرض آخر حالة حضور
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('attendance_records')
                .where('userId', isEqualTo: firebaseUser.uid)
                .orderBy('timestamp', descending: true)
                .limit(1)
                .get(),
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
              final String status = d['status'] ?? 'pending';

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
