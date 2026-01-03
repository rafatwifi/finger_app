class AttendanceRecordModel {
  final String id;
  final String userId;
  final String fingerprintRuleId;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final bool isValid;

  AttendanceRecordModel({
    required this.id,
    required this.userId,
    required this.fingerprintRuleId,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.isValid,
  });
}
