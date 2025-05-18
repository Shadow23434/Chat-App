class User {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String lastLogin;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.lastLogin = '',
  });
}

class Message {
  final String id;
  final String senderId;
  final String content;
  final String timestamp;
  final String type; // text, image, audio
  final bool isRead;
  final String? mediaUrl;
  final String? senderName;
  final String? senderAvatar;

  Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.type = 'text',
    this.isRead = false,
    this.mediaUrl,
    this.senderName,
    this.senderAvatar,
  });
}

class Chat {
  final String id;
  final String title;
  final String lastMessage;
  final String timestamp;
  final String avatarUrl;
  final int unreadCount;
  final List<User> participants;
  final List<Message> messages;

  Chat({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.timestamp,
    required this.avatarUrl,
    this.unreadCount = 0,
    this.participants = const [],
    this.messages = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lastMessage': lastMessage,
      'timestamp': timestamp,
      'avatarUrl': avatarUrl,
      'unreadCount': unreadCount,
      'participants':
          participants
              .map(
                (user) => {
                  'id': user.id,
                  'name': user.name,
                  'email': user.email,
                  'avatarUrl': user.avatarUrl,
                  'lastLogin': user.lastLogin,
                },
              )
              .toList(),
      'messages':
          messages
              .map(
                (message) => {
                  'id': message.id,
                  'senderId': message.senderId,
                  'content': message.content,
                  'timestamp': message.timestamp,
                  'type': message.type,
                  'isRead': message.isRead,
                },
              )
              .toList(),
    };
  }
}
