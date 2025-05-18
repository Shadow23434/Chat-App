class Message {
  final String id;
  final String senderId;
  final String content;
  final String timestamp;
  final bool isRead;
  final String? mediaUrl;
  final String type;
  final String? senderName;
  final String? senderAvatar;

  Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.isRead,
    this.mediaUrl,
    this.type = 'text',
    this.senderName,
    this.senderAvatar,
  });
}
