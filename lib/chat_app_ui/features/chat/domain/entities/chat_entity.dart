class ChatEntity {
  final String id;
  final String participantName;
  final String participantProfilePic;
  final String lastMessage;
  final String lastMessageAt;
  final bool isRead;

  ChatEntity({
    required this.id,
    required this.participantName,
    required this.participantProfilePic,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.isRead,
  });
}
