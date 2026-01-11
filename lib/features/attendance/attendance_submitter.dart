import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceSubmitter {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // تحويل التاريخ لمفتاح يوم ثابت: YYYY-MM-DD
  String _dayKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> submit({
    required String userId,
    required String ruleId,
    required double latitude,
    required double longitude,
  }) async {
    final now = DateTime.now();
    final day = _dayKey(now);

    // docId ثابت يمنع إضافة أكثر من بصمة لنفس (الموظف + القاعدة + اليوم)
    final docId = '${userId}_${ruleId}_$day';

    final ref = _db.collection('attendance_records').doc(docId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);

      if (snap.exists) {
        final data = snap.data() as Map<String, dynamic>;
        final status = (data['status'] ?? 'pending').toString();

        // إذا موجود pending أو approved => نمنع التكرار
        if (status == 'pending' || status == 'approved') {
          throw StateError('Already submitted for this slot today');
        }

        // إذا كان rejected نسمح بإعادة الإرسال على نفس السجل
        tx.update(ref, {
          'timestamp': FieldValue.serverTimestamp(),
          'latitude': latitude,
          'longitude': longitude,
          'status': 'pending',
          'resubmittedAt': FieldValue.serverTimestamp(),
        });
        return;
      }

      // أول إرسال لهذا السلوك/اليوم
      tx.set(ref, {
        'userId': userId,
        'ruleId': ruleId,
        'dayKey': day,
        'timestamp': FieldValue.serverTimestamp(),
        'latitude': latitude,
        'longitude': longitude,
        'status': 'pending',
        'isValid': true,
      });
    });
  }
}
