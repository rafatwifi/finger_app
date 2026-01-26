import '../../data/models/fingerprint_rule_model.dart';
import '../../data/models/attendance_record_model.dart';
import '../../core/utils/polygon_utils.dart';

class AttendanceEngine {
  // التحقق من البصمة: وقت + داخل حدود المضلع
  bool validate({
    required FingerprintRuleModel rule,
    required DateTime timestamp,
    required double latitude,
    required double longitude,
    required List<List<double>> polygon, // حدود المنطقة (Polygon)
  }) {
    // تحويل وقت البداية إلى DateTime
    final start = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
      rule.startTime.hour,
      rule.startTime.minute,
    );

    // تحويل وقت النهاية إلى DateTime
    final end = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
      rule.endTime.hour,
      rule.endTime.minute,
    );

    // فحص الوقت
    if (timestamp.isBefore(start) || timestamp.isAfter(end)) {
      return false;
    }

    // فحص الموقع داخل المضلع
    final inside = PolygonUtils.isPointInsidePolygon(
      lat: latitude,
      lng: longitude,
      polygon: polygon,
    );

    if (!inside) {
      return false;
    }

    return true;
  }

  // إنشاء سجل الحضور (دائماً يبدأ pending)
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
      status: 'pending', // لا موافقة ولا رفض هنا
    );
  }
}
