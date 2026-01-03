import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_record_model.dart';

class AttendanceRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<AttendanceRecordModel>> pending() {
    return _db
        .collection('attendance_records')
        .where('status', isEqualTo: 'pending')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AttendanceRecordModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> approve(String id) async {
    await _db.collection('attendance_records').doc(id).update({
      'status': 'approved',
      'approvedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> reject(String id) async {
    await _db.collection('attendance_records').doc(id).update({
      'status': 'rejected',
      'rejectedAt': FieldValue.serverTimestamp(),
    });
  }
}
