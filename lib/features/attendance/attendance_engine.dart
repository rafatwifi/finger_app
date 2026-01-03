import '../../data/models/fingerprint_rule_model.dart';
import '../../data/models/attendance_record_model.dart';
import '../../core/utils/geo_utils.dart';

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
    final distance = GeoUtils.distanceInMeters(
      latitude,
      longitude,
      centerLat,
      centerLng,
    );

    if (distance > allowedRadius) return false;

    if (timestamp.isBefore(rule.startTime) || timestamp.isAfter(rule.endTime)) {
      return false;
    }

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
