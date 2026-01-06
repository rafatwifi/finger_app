import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
          // زر إرسال البصمة (تجريبي)
          onPressed: () async {
            final engine = AttendanceEngine();

            // قاعدة بصمة تجريبية (الوقت)
            final rule = FingerprintRuleModel(
              id: 'rule_test',
              name: 'Morning',
              startTime: const TimeOfDay(hour: 7, minute: 30),
              endTime: const TimeOfDay(hour: 8, minute: 15),
            );

            // جلب مضلع المنطقة من Firestore
            final areaSnap = await FirebaseFirestore.instance
                .collection('settings')
                .doc('attendance_area')
                .get();

            if (!areaSnap.exists) {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('NO AREA SET')));
              }
              return;
            }

            final List polygonRaw = areaSnap['polygon'];
            final polygon = polygonRaw
                .map<List<double>>(
                  (p) => [p['lat'] as double, p['lng'] as double],
                )
                .toList();

            // إحداثيات تجريبية (لاحقًا GPS)
            final now = DateTime.now();
            const lat = 33.3152;
            const lng = 44.3661;

            // التحقق
            final isValid = engine.validate(
              rule: rule,
              timestamp: now,
              latitude: lat,
              longitude: lng,
              polygon: polygon,
            );

            // إنشاء سجل بحالة pending دائمًا
            final record = engine.buildRecord(
              id: '',
              userId: AppUserState.user!.id,
              rule: rule,
              timestamp: now,
              latitude: lat,
              longitude: lng,
              isValid: isValid,
            );

            // حفظ السجل
            await FirebaseFirestore.instance
                .collection('attendance_records')
                .add(record.toMap());

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isValid
                        ? 'SUBMITTED (PENDING)'
                        : 'REJECTED (TIME / LOCATION)',
                  ),
                ),
              );
            }
          },
          child: const Text('Submit Attendance'),
        ),
      ),
    );
  }
}
