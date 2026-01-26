// lib/features/employee/employee_attendance.dart
// شاشة الموظف: بصمة الجهاز + إضافة Record إلى Firestore + عرض آخر حالة
// ملاحظة: هذا الملف مكتفي ذاتياً ولا يعتمد على AppUserState أو ملفات موديلات

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';

class EmployeeAttendance extends StatefulWidget {
  const EmployeeAttendance({super.key});

  @override
  State<EmployeeAttendance> createState() => _EmployeeAttendanceState();
}

class _EmployeeAttendanceState extends State<EmployeeAttendance> {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _loading = false; // لمنع التكرار وإظهار دوران على الزر

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // إذا ماكو مستخدم مسجل دخول: نعرض سبنر (المفروض ما يصير إذا BootScreen مضبوط)
    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Employee Attendance'),
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
                  radius: 28,
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.person, color: Colors.black),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.email ?? '',
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'EMPLOYEE',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // زر البصمة
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: _loading
                    ? null
                    : _submitAttendance, // هنا الاستدعاء الحقيقي
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: _loading
                          ? [Colors.grey, Colors.grey]
                          : [Colors.orange, Colors.deepOrange],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.5),
                        blurRadius: 22,
                      ),
                    ],
                  ),
                  child: Center(
                    child: _loading
                        ? const SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.black,
                            ),
                          )
                        : const Icon(
                            Icons.fingerprint,
                            size: 90,
                            color: Colors.black,
                          ),
                  ),
                ),
              ),
            ),
          ),

          // آخر حالة (Realtime حتى ما يصير “يطلع وبعدين يختفي”)
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('attendance_records')
                .where('userId', isEqualTo: user.uid)
                .orderBy('timestamp', descending: true)
                .limit(1)
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Loading last status...',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

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
              final status =
                  (d.data() as Map<String, dynamic>)['status'] ?? 'pending';

              Color c = Colors.orange;
              if (status == 'approved') c = Colors.green;
              if (status == 'rejected') c = Colors.red;

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Last status: $status',
                  style: TextStyle(color: c, fontSize: 16),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _submitAttendance() async {
    // هذه الدالة هي “استدعاء الملف/المنطق” من زر البصمة
    // هنا نعمل: بصمة الجهاز -> ثم نضيف record واحد فقط إلى Firestore
    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _toast('NO SESSION');
        return;
      }

      // 1) هل الجهاز يدعم بصمات؟
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      if (!canCheck || !isSupported) {
        _toast('Biometrics not available on this device');
        return;
      }

      // 2) طلب بصمة النظام (هذه “بصمة الجهاز”)
      final ok = await _auth.authenticate(
        localizedReason: 'Confirm attendance with biometrics',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!ok) {
        _toast('Biometric cancelled/failed');
        return;
      }

      // 3) منع تكرار البصمة خلال 30 ثانية لنفس المستخدم (حل لمشكلة “مليار ريكورد”)
      final now = DateTime.now();
      final since = now.subtract(const Duration(seconds: 30));

      final recent = await FirebaseFirestore.instance
          .collection('attendance_records')
          .where('userId', isEqualTo: user.uid)
          .where('clientTimestamp', isGreaterThan: Timestamp.fromDate(since))
          .limit(1)
          .get();

      if (recent.docs.isNotEmpty) {
        _toast('Already submitted. Wait a bit.');
        return;
      }

      // 4) إضافة record
      await FirebaseFirestore.instance.collection('attendance_records').add({
        'userId': user.uid,
        'timestamp':
            FieldValue.serverTimestamp(), // وقت من السيرفر للفرز الصحيح
        'clientTimestamp': Timestamp.fromDate(
          now,
        ), // وقت من الجهاز لمنع التكرار
        'status': 'pending',
        'latitude': 0, // لاحقاً نربط Geolocator
        'longitude': 0,
        'isValid': true,
      });

      _toast('Attendance sent (pending)');
    } catch (e) {
      _toast('ERROR: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toast(String msg) {
    // إشعار سريع للمستخدم
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
