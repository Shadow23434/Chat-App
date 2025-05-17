class User {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String status;
  final String lastSeen;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.status = 'offline',
    this.lastSeen = '',
  });
}

class Message {
  final String id;
  final String senderId;
  final String content;
  final String timestamp;
  final String type; // text, image, audio
  final bool isRead;

  Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.type = 'text',
    this.isRead = false,
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
                  'status': user.status,
                  'lastSeen': user.lastSeen,
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

// Sample users
final List<User> users = [
  User(
    id: 'u1',
    name: 'John Doe',
    email: 'john.doe@example.com',
    avatarUrl: 'https://via.placeholder.com/150',
    status: 'online',
  ),
  User(
    id: 'u2',
    name: 'Jane Smith',
    email: 'jane.smith@example.com',
    avatarUrl: 'https://via.placeholder.com/150',
    status: 'offline',
    lastSeen: '2 hours ago',
  ),
  User(
    id: 'u3',
    name: 'Alice Johnson',
    email: 'alice.johnson@example.com',
    avatarUrl: 'https://via.placeholder.com/150',
    status: 'online',
  ),
];

// Sample messages
final List<Message> johnMessages = [
  Message(
    id: 'm1',
    senderId: 'u1',
    content: 'Hey, how are you?',
    timestamp: '10:30 AM',
    isRead: true,
  ),
  Message(
    id: 'm2',
    senderId: 'admin',
    content: 'I\'m good, thanks for asking!',
    timestamp: '10:31 AM',
    isRead: true,
  ),
  Message(
    id: 'm3',
    senderId: 'u1',
    content: 'Do you have time to talk about the project?',
    timestamp: '10:32 AM',
    isRead: false,
  ),
];

// Sample list of chats
final List<Chat> chats = [
  Chat(
    id: '1',
    title: 'John Doe',
    lastMessage: 'Hey, how are you?',
    timestamp: '10:30 AM',
    avatarUrl: 'https://via.placeholder.com/150',
    unreadCount: 2,
    participants: [users[0]],
    messages: johnMessages,
  ),
  Chat(
    id: '2',
    title: 'Jane Smith',
    lastMessage: "Let's catch up later!",
    timestamp: '9:15 AM',
    avatarUrl: 'https://via.placeholder.com/150',
    participants: [users[1]],
    messages: [
      Message(
        id: 'm4',
        senderId: 'u2',
        content: "Let's catch up later!",
        timestamp: '9:15 AM',
        isRead: true,
      ),
    ],
  ),
  Chat(
    id: '3',
    title: 'Alice Johnson',
    lastMessage: 'Can you send me the file?',
    timestamp: 'Yesterday',
    avatarUrl: 'https://via.placeholder.com/150',
    unreadCount: 1,
    participants: [users[2]],
    messages: [
      Message(
        id: 'm5',
        senderId: 'u3',
        content: 'Can you send me the file?',
        timestamp: 'Yesterday',
        isRead: false,
      ),
    ],
  ),
];
