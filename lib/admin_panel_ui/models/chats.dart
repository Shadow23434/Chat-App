class Chat {
  final String id;
  final String title;
  final String lastMessage;
  final String timestamp;
  final String avatarUrl;

  Chat({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.timestamp,
    required this.avatarUrl,
  });
}

// Sample list of chats
final List<Chat> chats = [
  Chat(
    id: '1',
    title: 'John Doe',
    lastMessage: 'Hey, how are you?',
    timestamp: '10:30 AM',
    avatarUrl: 'https://via.placeholder.com/150',
  ),
  Chat(
    id: '2',
    title: 'Jane Smith',
    lastMessage: 'Let’s catch up later!',
    timestamp: '9:15 AM',
    avatarUrl: 'https://via.placeholder.com/150',
  ),
  Chat(
    id: '3',
    title: 'Alice Johnson',
    lastMessage: 'Can you send me the file?',
    timestamp: 'Yesterday',
    avatarUrl: 'https://via.placeholder.com/150',
  ),
];
