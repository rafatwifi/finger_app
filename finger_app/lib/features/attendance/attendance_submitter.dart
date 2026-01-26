import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/attendance_record_model.dart';

class AttendanceSubmitter {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _dayKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> submit({
    required AttendanceRecordModel record,
    required int maxScansPerDay,
  }) async {
    final day = _dayKey(record.timestamp);
    final ref = _db.collection('attendance_records').doc(record.id);

    // 1) عدّ البصمات اليومية (خارج transaction)
    final dailyCountSnap = await _db
        .collection('attendance_records')
        .where('userId', isEqualTo: record.userId)
        .where('dayKey', isEqualTo: day)
        .get();

    if (dailyCountSnap.size >= maxScansPerDay) {
      throw StateError('Daily scan limit exceeded');
    }

    // 2) كتابة آمنة داخل transaction
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);

      if (snap.exists) {
        final data = snap.data() as Map<String, dynamic>;
        final status = (data['status'] ?? '').toString();

        if (status == 'pending' || status == 'approved') {
          throw StateError('Attendance already submitted');
        }

        // rejected → نسمح بإعادة الإرسال
        tx.update(ref, {
          'timestamp': FieldValue.serverTimestamp(),
          'latitude': record.latitude,
          'longitude': record.longitude,
          'status': record.status,
          'isValid': record.isValid,
          'resubmittedAt': FieldValue.serverTimestamp(),
        });
        return;
      }

      // أول إرسال
      tx.set(ref, {
        'id': record.id,
        'userId': record.userId,
        'fingerprintRuleId': record.fingerprintRuleId,
        'dayKey': day,
        'timestamp': FieldValue.serverTimestamp(),
        'latitude': record.latitude,
        'longitude': record.longitude,
        'status': record.status,
        'isValid': record.isValid,
      });
    });
  }
}
