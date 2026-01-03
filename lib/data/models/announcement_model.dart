class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String createdBy;
  final bool commentsEnabled;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.createdBy,
    required this.commentsEnabled,
  });
}
