class AdminDashboard {
  final int totalUsers;
  final int totalChats;
  final int totalMessages;
  final List<Map<String, dynamic>> recentUsers;
  final List<Map<String, dynamic>> recentChats;
  final Map<String, int> userStats;
  final Map<String, int> chatStats;

  AdminDashboard({
    required this.totalUsers,
    required this.totalChats,
    required this.totalMessages,
    required this.recentUsers,
    required this.recentChats,
    required this.userStats,
    required this.chatStats,
  });

  factory AdminDashboard.fromJson(Map<String, dynamic> json) {
    return AdminDashboard(
      totalUsers: json['total_users'] as int,
      totalChats: json['total_chats'] as int,
      totalMessages: json['total_messages'] as int,
      recentUsers:
          (json['recent_users'] as List)
              .map((user) => user as Map<String, dynamic>)
              .toList(),
      recentChats:
          (json['recent_chats'] as List)
              .map((chat) => chat as Map<String, dynamic>)
              .toList(),
      userStats: Map<String, int>.from(json['user_stats'] as Map),
      chatStats: Map<String, int>.from(json['chat_stats'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_users': totalUsers,
      'total_chats': totalChats,
      'total_messages': totalMessages,
      'recent_users': recentUsers,
      'recent_chats': recentChats,
      'user_stats': userStats,
      'chat_stats': chatStats,
    };
  }
}
