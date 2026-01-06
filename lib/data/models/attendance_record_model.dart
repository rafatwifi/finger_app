class AttendanceRecordModel {
  final String id;
  final String userId;
  final String fingerprintRuleId;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final bool isValid;

  // حالة السجل: pending | approved | rejected
  final String status;

  AttendanceRecordModel({
    required this.id,
    required this.userId,
    required this.fingerprintRuleId,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.isValid,
    required this.status,
  });

  // تحويل الكائن إلى Map للحفظ في Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fingerprintRuleId': fingerprintRuleId,
      'timestamp': timestamp,
      'latitude': latitude,
      'longitude': longitude,
      'isValid': isValid,
      'status': status,
    };
  }

  // إنشاء كائن من بيانات Firestore
  factory AttendanceRecordModel.fromMap(String id, Map<String, dynamic> map) {
    return AttendanceRecordModel(
      id: id,
      userId: map['userId'],
      fingerprintRuleId: map['fingerprintRuleId'],
      timestamp: (map['timestamp'] as dynamic).toDate(),
      latitude: map['latitude'],
      longitude: map['longitude'],
      isValid: map['isValid'],
      status: map['status'],
    );
  }
}
