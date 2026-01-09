import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/attendance/attendance_engine.dart';
import '../../data/models/fingerprint_rule_model.dart';
import '../../core/services/app_user_state.dart';

class EmployeeAttendanceScreen extends StatefulWidget {
  const EmployeeAttendanceScreen({super.key});

  @override
  State<EmployeeAttendanceScreen> createState() =>
      _EmployeeAttendanceScreenState();
}

class _EmployeeAttendanceScreenState extends State<EmployeeAttendanceScreen> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          // زر البصمة المرعب
          child: GestureDetector(
            onTap: _loading ? null : _submitAttendance,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.green, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.35),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.green)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.fingerprint,
                            size: 60,
                            color: Colors.green,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'اضغط للبصمة',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitAttendance() async {
    setState(() => _loading = true);

    try {
      final engine = AttendanceEngine();

      // قاعدة وقت تجريبية
      final rule = FingerprintRuleModel(
        id: 'rule_test',
        name: 'Test Rule',
        startTime: const TimeOfDay(hour: 7, minute: 30),
        endTime: const TimeOfDay(hour: 8, minute: 15),
      );

      // إنشاء سجل حضور (Pending)
      final record = engine.buildRecord(
        id: '',
        userId: AppUserState.user!.id,
        rule: rule,
        timestamp: DateTime.now(),
        latitude: 0,
        longitude: 0,
        isValid: true,
      );

      // حفظ في Firestore
      await FirebaseFirestore.instance
          .collection('attendance_records')
          .add(record.toMap());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال البصمة (بانتظار المعالجة)')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
