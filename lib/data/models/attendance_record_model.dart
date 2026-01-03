class AttendanceRecordModel {
  final String id;
  final String userId;
  final String fingerprintRuleId;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final bool isValid;

  // pending | approved | rejected
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

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fingerprintRuleId': fingerprintRuleId,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'isValid': isValid,
      'status': status,
    };
  }

  factory AttendanceRecordModel.fromMap(String id, Map<String, dynamic> data) {
    return AttendanceRecordModel(
      id: id,
      userId: (data['userId'] ?? '').toString(),
      fingerprintRuleId: (data['fingerprintRuleId'] ?? '').toString(),
      timestamp:
          DateTime.tryParse((data['timestamp'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      latitude: (data['latitude'] is num)
          ? (data['latitude'] as num).toDouble()
          : 0.0,
      longitude: (data['longitude'] is num)
          ? (data['longitude'] as num).toDouble()
          : 0.0,
      isValid: (data['isValid'] == true),
      status: (data['status'] ?? 'pending').toString(),
    );
  }
}
