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

// Sample messages for demo
List<Message> generateSampleMessages(String chatId) {
  return [
    Message(
      id: '${chatId}_1',
      senderId: 'user_1',
      content: 'Hello, how are you?',
      timestamp: '10:30 AM',
      isRead: true,
      senderName: 'Admin',
      senderAvatar: 'https://via.placeholder.com/150',
    ),
    Message(
      id: '${chatId}_2',
      senderId: 'user_2',
      content: 'I\'m good, thanks! How about you?',
      timestamp: '10:32 AM',
      isRead: true,
      senderName: 'John Doe',
      senderAvatar: 'https://via.placeholder.com/150',
    ),
    Message(
      id: '${chatId}_3',
      senderId: 'user_1',
      content: 'Doing well. Do you have time to discuss the project?',
      timestamp: '10:35 AM',
      isRead: true,
      senderName: 'Admin',
      senderAvatar: 'https://via.placeholder.com/150',
    ),
    Message(
      id: '${chatId}_4',
      senderId: 'user_2',
      content:
          'Sure, I\'m available now. What specifically would you like to discuss?',
      timestamp: '10:40 AM',
      isRead: false,
      senderName: 'John Doe',
      senderAvatar: 'https://via.placeholder.com/150',
    ),
    Message(
      id: '${chatId}_5',
      senderId: 'user_1',
      content: 'I wanted to talk about the new feature we\'re planning to add.',
      timestamp: '10:42 AM',
      isRead: false,
      senderName: 'Admin',
      senderAvatar: 'https://via.placeholder.com/150',
    ),
    Message(
      id: '${chatId}_6',
      senderId: 'user_2',
      content: '',
      timestamp: '10:45 AM',
      isRead: false,
      type: 'image',
      mediaUrl: 'https://picsum.photos/500/300',
      senderName: 'John Doe',
      senderAvatar: 'https://via.placeholder.com/150',
    ),
  ];
}
