import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import '../../features/attendance/attendance_engine.dart';
import '../../data/models/fingerprint_rule_model.dart';
import '../../core/services/app_user_state.dart';

class EmployeeAttendanceScreen extends StatelessWidget {
  const EmployeeAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Submit Attendance'),
          onPressed: () async {
            // 1️⃣ جلب الموقع الحقيقي
            final pos = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
            );

            // 2️⃣ جلب المضلع من Firestore
            final snap = await FirebaseFirestore.instance
                .collection('settings')
                .doc('attendance_area')
                .get();

            final polygon = (snap['polygon'] as List)
                .map<List<double>>(
                  (p) => [p['lat'] as double, p['lng'] as double],
                )
                .toList();

            // 3️⃣ قاعدة الوقت
            final rule = FingerprintRuleModel(
              id: 'rule_test',
              name: 'Office Time',
              startTime: const TimeOfDay(hour: 7, minute: 30),
              endTime: const TimeOfDay(hour: 15, minute: 0),
            );

            final engine = AttendanceEngine();

            // 4️⃣ تحقق وقت + موقع
            final isValid = engine.validate(
              rule: rule,
              timestamp: DateTime.now(),
              latitude: pos.latitude,
              longitude: pos.longitude,
              polygon: polygon,
            );

            // 5️⃣ إنشاء سجل
            final record = engine.buildRecord(
              id: '',
              userId: AppUserState.user!.id,
              rule: rule,
              timestamp: DateTime.now(),
              latitude: pos.latitude,
              longitude: pos.longitude,
              isValid: isValid,
            );

            // 6️⃣ حفظ
            await FirebaseFirestore.instance
                .collection('attendance_records')
                .add(record.toMap());

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isValid
                        ? 'Attendance Approved Automatically'
                        : 'Attendance Rejected (Location/Time)',
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
