import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chat_app/admin_panel_ui/models/chats.dart' as chat_models;
import 'package:chat_app/admin_panel_ui/models/messages.dart';
import 'package:chat_app/admin_panel_ui/models/users.dart';
import 'package:intl/intl.dart';

class DemoDataService {
  // Singleton pattern
  static final DemoDataService _instance = DemoDataService._internal();
  factory DemoDataService() => _instance;
  DemoDataService._internal();

  // Cache data
  List<Map<String, dynamic>>? _rawChats;
  List<Map<String, dynamic>>? _rawUsers;
  List<Map<String, dynamic>>? _rawMessages;

  List<chat_models.Chat>? _processedChats;
  List<User>? _processedUsers;
  Map<String, List<Message>>? _processedMessages;

  // Get correct asset path for demo data
  String _getAssetPath(String fileName) {
    return 'assets/demo_data/$fileName';
  }

  // Load raw data from JSON files
  Future<List<Map<String, dynamic>>> _loadJsonData(String fileName) async {
    try {
      final assetPath = _getAssetPath(fileName);
      final jsonString = await rootBundle.loadString(assetPath);
      final jsonData = jsonDecode(jsonString) as List;
      return jsonData.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error loading data: $e');
      return [];
    }
  }

  // Get user data by ID
  Map<String, dynamic>? _getUserById(String userId) {
    if (_rawUsers == null) return null;

    try {
      return _rawUsers!.firstWhere((user) => user['_id']['\$oid'] == userId);
    } catch (e) {
      return null;
    }
  }

  // Format date for display
  String _formatTimestamp(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 7) {
        return DateFormat('MMM d, yyyy').format(date);
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  // Get the latest message from a chat
  Map<String, dynamic>? _getLatestMessage(String chatId) {
    if (_rawMessages == null) return null;

    try {
      final chatMessages =
          _rawMessages!
              .where((msg) => msg['chatId']['\$oid'] == chatId)
              .toList();

      if (chatMessages.isEmpty) return null;

      chatMessages.sort((a, b) {
        final dateA = DateTime.parse(a['createdAt']['\$date']);
        final dateB = DateTime.parse(b['createdAt']['\$date']);
        return dateB.compareTo(
          dateA,
        ); // Sort in descending order (latest first)
      });

      return chatMessages.first;
    } catch (e) {
      debugPrint('Error getting latest message: $e');
      return null;
    }
  }

  // Load all required data
  Future<void> loadAllData() async {
    // Load raw data
    _rawChats = await _loadJsonData('chats.json');
    _rawUsers = await _loadJsonData('users.json');
    _rawMessages = await _loadJsonData('messages.json');

    // Process data
    _processUsers();
    _processChats();
    _processMessages();
  }

  // Process users into User objects
  void _processUsers() {
    if (_rawUsers == null) return;

    _processedUsers =
        _rawUsers!.map((userData) {
          return User(
            id: userData['_id']['\$oid'],
            username: userData['username'] ?? 'Unknown',
            email: userData['email'] ?? '',
            gender: userData['gender'] ?? 'unknown',
            profilePic:
                userData['profilePic'] ?? 'https://via.placeholder.com/150',
            phoneNumber: userData['phoneNumber'] ?? '',
            isVerified: userData['isVerified'] ?? false,
            lastLogin: _formatTimestamp(userData['lastLogin']['\$date']),
            createdAt: _formatTimestamp(userData['createdAt']['\$date']),
          );
        }).toList();
  }

  // Create chat_models.User from original User
  chat_models.User _createChatUser(User user) {
    return chat_models.User(
      id: user.id,
      name: user.username,
      email: user.email,
      avatarUrl: user.profilePic,
      lastLogin: user.lastLogin,
    );
  }

  // Process chats into Chat objects
  void _processChats() {
    if (_rawChats == null ||
        _rawUsers == null ||
        _rawMessages == null ||
        _processedUsers == null ||
        _processedMessages == null) {
      debugPrint('Missing required data for processing chats');
      return;
    }

    _processedChats =
        _rawChats!.map((chatData) {
          // Get chat ID
          final chatId = chatData['_id']['\$oid'];

          // Get participant IDs
          final participant1Id = chatData['participantOneId']['\$oid'];
          final participant2Id = chatData['participantTwoId']['\$oid'];

          // Get user data
          final user1 = _getUserById(participant1Id);
          final user2 = _getUserById(participant2Id);

          // Get latest message
          final latestMessage = _getLatestMessage(chatId);

          // Get participants
          List<chat_models.User> participants = [];
          if (_processedUsers != null) {
            try {
              final user1Model = _processedUsers!.firstWhere(
                (u) => u.id == participant1Id,
              );
              final user2Model = _processedUsers!.firstWhere(
                (u) => u.id == participant2Id,
              );
              participants = [
                _createChatUser(user1Model),
                _createChatUser(user2Model),
              ];
            } catch (e) {
              debugPrint('Error finding participants: $e');
            }
          }

          // Get messages for this chat
          List<chat_models.Message> chatMessages = [];
          if (_processedMessages != null &&
              _processedMessages!.containsKey(chatId)) {
            chatMessages =
                _processedMessages![chatId]!
                    .map(
                      (m) => chat_models.Message(
                        id: m.id,
                        senderId: m.senderId,
                        content: m.content,
                        timestamp: m.timestamp,
                        type: m.type,
                        isRead: m.isRead,
                      ),
                    )
                    .toList();
          }

          // Create Chat object
          return chat_models.Chat(
            id: chatId,
            title: user2 != null ? user2['username'] : 'Unknown User',
            lastMessage:
                latestMessage != null
                    ? (latestMessage['type'] == 'image'
                        ? '📷 Image'
                        : latestMessage['content'])
                    : 'No messages yet',
            timestamp:
                latestMessage != null
                    ? _formatTimestamp(latestMessage['createdAt']['\$date'])
                    : _formatTimestamp(chatData['createdAt']['\$date']),
            avatarUrl:
                user2 != null
                    ? user2['profilePic']
                    : 'https://via.placeholder.com/150',
            unreadCount: _getUnreadCount(chatId, participant1Id),
            participants: participants,
            messages: chatMessages,
          );
        }).toList();
  }

  // Get unread message count
  int _getUnreadCount(String chatId, String userId) {
    if (_rawMessages == null) return 0;

    try {
      return _rawMessages!
          .where(
            (msg) =>
                msg['chatId']['\$oid'] == chatId &&
                msg['senderId']['\$oid'] != userId &&
                msg['isRead'] == false,
          )
          .length;
    } catch (e) {
      return 0;
    }
  }

  // Process messages into Message objects
  void _processMessages() {
    if (_rawMessages == null || _rawUsers == null) return;

    _processedMessages = {};

    for (var msgData in _rawMessages!) {
      try {
        final chatId = msgData['chatId']['\$oid'];
        final senderId = msgData['senderId']['\$oid'];
        final sender = _getUserById(senderId);

        final message = Message(
          id: msgData['_id']['\$oid'],
          senderId: senderId,
          content: msgData['content'] ?? '',
          timestamp: _formatTimestamp(msgData['createdAt']['\$date']),
          isRead: msgData['isRead'] ?? false,
          type: msgData['type'] ?? 'text',
          mediaUrl: msgData['mediaUrl'] ?? '',
          senderName: sender != null ? sender['username'] : 'Unknown',
          senderAvatar:
              sender != null
                  ? sender['profilePic']
                  : 'https://via.placeholder.com/150',
        );

        if (!_processedMessages!.containsKey(chatId)) {
          _processedMessages![chatId] = [];
        }

        _processedMessages![chatId]!.add(message);
      } catch (e) {
        debugPrint('Error processing message: $e');
      }
    }

    // Sort messages by timestamp (oldest first)
    _processedMessages!.forEach((chatId, messages) {
      messages.sort((a, b) {
        // This is a simplified sort since we're using formatted timestamps
        // In a real app, you would store the DateTime and sort using that
        return a.id.compareTo(b.id);
      });
    });
  }

  // Get all chats
  Future<List<chat_models.Chat>> getChats() async {
    if (_processedChats == null) {
      await loadAllData();
    }
    return _processedChats ?? [];
  }

  // Get all users
  Future<List<User>> getUsers() async {
    if (_processedUsers == null) {
      await loadAllData();
    }
    return _processedUsers ?? [];
  }

  // Get a specific user
  Future<User?> getUserById(String userId) async {
    if (_processedUsers == null) {
      await loadAllData();
    }
    try {
      return _processedUsers!.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  // Get messages for a specific chat
  Future<List<Message>> getMessages(String chatId) async {
    if (_processedMessages == null) {
      await loadAllData();
    }
    return _processedMessages?[chatId] ?? [];
  }

  // Mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    // In a real app, this would update the database
    // For demo purposes, we'll just update our local data
    if (_rawMessages == null) return;

    for (var i = 0; i < _rawMessages!.length; i++) {
      if (_rawMessages![i]['_id']['\$oid'] == messageId) {
        _rawMessages![i]['isRead'] = true;
        break;
      }
    }

    // Re-process messages
    _processMessages();
  }

  // Delete a chat
  Future<void> deleteChat(String chatId) async {
    // In a real app, this would be an API call
    await Future.delayed(const Duration(milliseconds: 500));

    if (_processedChats != null) {
      _processedChats!.removeWhere((chat) => chat.id == chatId);
    }

    if (_processedMessages != null) {
      _processedMessages!.remove(chatId);
    }
  }

  // Delete a message
  Future<void> deleteMessage(String chatId, String messageId) async {
    // In a real app, this would be an API call
    await Future.delayed(const Duration(milliseconds: 500));

    if (_processedMessages != null && _processedMessages!.containsKey(chatId)) {
      _processedMessages![chatId]!.removeWhere(
        (message) => message.id == messageId,
      );

      // Update the last message in the chat if needed
      if (_processedChats != null) {
        final chatIndex = _processedChats!.indexWhere(
          (chat) => chat.id == chatId,
        );
        if (chatIndex >= 0 && _processedMessages![chatId]!.isNotEmpty) {
          final lastMsg = _processedMessages![chatId]!.last;
          _processedChats![chatIndex] = chat_models.Chat(
            id: _processedChats![chatIndex].id,
            title: _processedChats![chatIndex].title,
            lastMessage: lastMsg.type == 'image' ? '📷 Image' : lastMsg.content,
            timestamp: lastMsg.timestamp,
            avatarUrl: _processedChats![chatIndex].avatarUrl,
            unreadCount: _processedChats![chatIndex].unreadCount,
            participants: _processedChats![chatIndex].participants,
            messages: _processedChats![chatIndex].messages,
          );
        }
      }
    }
  }
}
