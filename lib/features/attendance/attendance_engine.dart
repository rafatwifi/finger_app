import '../../data/models/fingerprint_rule_model.dart';
import '../../data/models/attendance_record_model.dart';

class AttendanceEngine {
  bool validateFingerprint({
    required FingerprintRuleModel rule,
    required DateTime timestamp,
    required double latitude,
    required double longitude,
    required double allowedRadius,
    required double centerLat,
    required double centerLng,
  }) {
    return true;
  }

  AttendanceRecordModel buildRecord({
    required String id,
    required String userId,
    required FingerprintRuleModel rule,
    required DateTime timestamp,
    required double latitude,
    required double longitude,
    required bool isValid,
  }) {
    return AttendanceRecordModel(
      id: id,
      userId: userId,
      fingerprintRuleId: rule.id,
      timestamp: timestamp,
      latitude: latitude,
      longitude: longitude,
      isValid: isValid,
    );
  }
}
