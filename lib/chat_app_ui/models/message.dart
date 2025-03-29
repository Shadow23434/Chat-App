class Message {
  final String id;
  final String senderId;
  final String chatId;
  final String content;
  final String type;
  final DateTime createdAt;
  final bool isRead;

  Message({
    required this.id,
    required this.senderId,
    required this.chatId,
    required this.content,
    required this.type,
    required this.createdAt,
    required this.isRead,
  });
}
