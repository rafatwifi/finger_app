enum MessageType { text, voice, image, file }

class ChatMessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final MessageType type;
  final String content;
  final DateTime sentAt;

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.type,
    required this.content,
    required this.sentAt,
  });
}
