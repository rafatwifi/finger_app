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
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.fingerprint),
              label: Text(_loading ? 'Submitting...' : 'Submit Attendance'),
              onPressed: _loading ? null : _submitAttendance,
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

      // قاعدة وقت تجريبية (وقت فقط)، الموقع/المضلع تشتغل لاحقاً من settings
      final rule = FingerprintRuleModel(
        id: 'rule_test',
        name: 'Test Rule',
        startTime: const TimeOfDay(hour: 7, minute: 30),
        endTime: const TimeOfDay(hour: 8, minute: 15),
      );

      // ننشئ سجل بصمة بحالة pending دائماً (حتى لو تحققنا لاحقاً)
      final record = engine.buildRecord(
        id: '',
        userId: AppUserState.user!.id,
        rule: rule,
        timestamp: DateTime.now(),
        latitude: 0,
        longitude: 0,
        isValid: true,
      );

      // نكتب السجل بفايرستور
      await FirebaseFirestore.instance
          .collection('attendance_records')
          .add(record.toMap());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submitted: pending approval')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ERROR: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
