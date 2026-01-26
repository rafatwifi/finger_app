class ShiftModel {
  final String id;
  final String name;
  final bool isOnCall; // مناوب أو لا
  final int order; // للفرز

  ShiftModel({
    required this.id,
    required this.name,
    required this.isOnCall,
    required this.order,
  });
}
