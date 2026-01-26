import '../../data/models/fingerprint_rule_model.dart';
import '../../data/models/attendance_record_model.dart';
import '../../data/models/app_settings_model.dart';
import '../../core/utils/polygon_utils.dart';

class AttendanceEngine {
  AttendanceRecordModel process({
    required String id,
    required String userId,
    required FingerprintRuleModel rule,
    required AppSettingsModel settings,
    required DateTime timestamp,
    required double latitude,
    required double longitude,
    required List<List<double>> polygon,
  }) {
    final bool timeValid = _validateTime(rule, timestamp);

    final bool locationValid =
        !settings.requireLocation ||
        PolygonUtils.isPointInsidePolygon(
          lat: latitude,
          lng: longitude,
          polygon: polygon,
        );

    final bool isValid = timeValid && locationValid;

    final String status = settings.requireSupervisor
        ? 'pending'
        : (isValid ? 'approved' : 'rejected');

    return AttendanceRecordModel(
      id: id,
      userId: userId,
      fingerprintRuleId: rule.id,
      timestamp: timestamp,
      latitude: latitude,
      longitude: longitude,
      isValid: isValid,
      status: status,
    );
  }

  /// يدعم الدوام الليلي (مثال: 22:00 → 06:00)
  bool _validateTime(FingerprintRuleModel rule, DateTime timestamp) {
    final start = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
      rule.startTime.hour,
      rule.startTime.minute,
    );

    var end = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
      rule.endTime.hour,
      rule.endTime.minute,
    );

    // دوام ليلي
    if (end.isBefore(start)) {
      end = end.add(const Duration(days: 1));
    }

    final adjustedTimestamp = timestamp.isBefore(start)
        ? timestamp.add(const Duration(days: 1))
        : timestamp;

    return !adjustedTimestamp.isBefore(start) &&
        !adjustedTimestamp.isAfter(end);
  }
}
