class FingerprintRuleModel {
  final String id;
  final String name;
  final DateTime startTime;
  final DateTime endTime;
  final bool required;
  final List<String> allowedShiftIds;

  FingerprintRuleModel({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.required,
    required this.allowedShiftIds,
  });
}
