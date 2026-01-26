import 'package:flutter/material.dart';

class FingerprintRuleModel {
  final String id;
  final String name;

  // وقت البداية والنهاية كنص (لأنها إعدادات مرنة)
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  FingerprintRuleModel({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
  });

  // تحويل إلى Map للتخزين
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'startHour': startTime.hour,
      'startMinute': startTime.minute,
      'endHour': endTime.hour,
      'endMinute': endTime.minute,
    };
  }

  // إنشاء من Firestore
  factory FingerprintRuleModel.fromMap(String id, Map<String, dynamic> map) {
    return FingerprintRuleModel(
      id: id,
      name: map['name'],
      startTime: TimeOfDay(hour: map['startHour'], minute: map['startMinute']),
      endTime: TimeOfDay(hour: map['endHour'], minute: map['endMinute']),
    );
  }
}
