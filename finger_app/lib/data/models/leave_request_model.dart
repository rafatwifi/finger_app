enum LeaveType { fullDay, morning, evening, night }

class LeaveRequestModel {
  final String id;
  final String userId;
  final DateTime date;
  final LeaveType type;
  final bool approved;

  LeaveRequestModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.type,
    required this.approved,
  });
}
