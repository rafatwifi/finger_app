import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/attendance/attendance_engine.dart';
import '../../data/models/fingerprint_rule_model.dart';
import '../../core/services/app_user_state.dart';
import '../../core/services/location_service.dart';

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
          onPressed: () async {
            final engine = AttendanceEngine();

            // قاعدة وقت مؤقتة (لاحقًا من إعدادات المدير)
            final rule = FingerprintRuleModel(
              id: 'rule_polygon',
              name: 'Polygon Rule',
              startTime: const TimeOfDay(hour: 7, minute: 30),
              endTime: const TimeOfDay(hour: 8, minute: 15),
            );

            // موقع الموظف ( GPS)
            final position = await LocationService.getCurrentPosition();
            final latitude = position.latitude;
            final longitude = position.longitude;

            // حدود الدائرة كمضلع (مستطيل تجريبي)
            // الترتيب: [[lat,lng], ...] حول الحدود
            final polygon = <List<double>>[
              [33.3160, 44.3650],
              [33.3160, 44.3670],
              [33.3145, 44.3670],
              [33.3145, 44.3650],
            ];

            final now = DateTime.now();

            // تحقق آلي (وقت + داخل المضلع)
            final isValid = engine.validate(
              rule: rule,
              timestamp: now,
              latitude: latitude,
              longitude: longitude,
              polygon: polygon,
            );

            // إنشاء السجل
            final record = engine.buildRecord(
              id: '',
              userId: AppUserState.user!.id,
              rule: rule,
              timestamp: now,
              latitude: latitude,
              longitude: longitude,
              isValid: isValid,
            );

            // حفظ في Firestore
            await FirebaseFirestore.instance
                .collection('attendance_records')
                .add(record.toMap());

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isValid
                        ? 'Approved (inside polygon)'
                        : 'Rejected (time or outside polygon)',
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
