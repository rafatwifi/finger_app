import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceSubmitter {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// تحويل التاريخ إلى مفتاح يوم (YYYY-MM-DD)
  String _dayKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// إرسال بصمة واحدة حسب (موظف + قاعدة + يوم)
  /// يمنع التكرار داخل نفس الفترة
  Future<void> submit({
    required String userId,
    required String ruleId,
    required double latitude,
    required double longitude,
  }) async {
    final now = DateTime.now();
    final day = _dayKey(now);

    /// docId ثابت يمنع التكرار
    final docId = '${userId}_$ruleId\_$day';

    final ref = _db.collection('attendance_records').doc(docId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);

      if (snap.exists) {
        final data = snap.data() as Map<String, dynamic>;
        final status = (data['status'] ?? 'pending').toString();

        /// إذا بصم مسبقاً بنفس الفترة
        if (status == 'pending' || status == 'approved') {
          throw StateError('Already submitted for this time slot');
        }

        /// إذا مرفوض، نحدث نفس السجل
        tx.update(ref, {
          'timestamp': FieldValue.serverTimestamp(),
          'latitude': latitude,
          'longitude': longitude,
          'status': 'pending',
          'resubmittedAt': FieldValue.serverTimestamp(),
        });
        return;
      }

      /// أول بصمة لهذه الفترة
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
