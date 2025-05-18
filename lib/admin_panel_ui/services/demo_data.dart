import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chat_app/admin_panel_ui/models/chats.dart' as chat_models;
import 'package:intl/intl.dart';
import 'dart:async';

class DemoData {
  static final DemoData _instance = DemoData._internal();
  factory DemoData() => _instance;
  DemoData._internal();

  // Cache loaded data
  List<Map<String, dynamic>>? _usersData;
  List<Map<String, dynamic>>? _chatsData;
  List<Map<String, dynamic>>? _messagesData;

  List<chat_models.Chat>? _chats;
  List<chat_models.User>? _users;

  // Cache status
  bool _isInitializing = false;
  Completer<void>? _initCompleter;

  // Pre-processed data for better performance
  final Map<String, List<chat_models.Message>> _chatMessagesCache = {};
  final Map<String, chat_models.User> _userCache = {};

  // Load JSON data from assets with improved error handling and parsing
  Future<List<Map<String, dynamic>>> _loadJson(String filename) async {
    try {
      // Use rootBundle.load instead of loadString for better performance
      final ByteData data = await rootBundle.load('assets/demo_data/$filename');
      final buffer = data.buffer;
      final List<dynamic> jsonData = json.decode(
        utf8.decode(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes)),
      );
      return jsonData.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error loading $filename: $e');
      return [];
    }
  }

  // Format timestamp for display
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

  // Initialize data with improved concurrency handling
  Future<void> initialize() async {
    // Prevent multiple concurrent initializations
    if (_isInitializing) {
      return _initCompleter!.future;
    }

    if (_chats != null && _users != null) {
      return; // Already initialized
    }

    _isInitializing = true;
    _initCompleter = Completer<void>();

    try {
      // Load all data in parallel for better performance
      final futures = await Future.wait([
        _loadJson('users.json'),
        _loadJson('chats.json'),
        _loadJson('messages.json'),
      ]);

      _usersData = futures[0];
      _chatsData = futures[1];
      _messagesData = futures[2];

      // Process data concurrently
      await Future.wait([
        Future(() => _processUsers()),
        Future(() => _processChats()),
      ]);

      _isInitializing = false;
      _initCompleter!.complete();
    } catch (e) {
      _isInitializing = false;
      _initCompleter!.completeError(e);
      rethrow;
    }
  }

  // Process user data with optimized approach
  void _processUsers() {
    if (_usersData == null) return;

    // Build user cache for fast lookups
    for (final userData in _usersData!) {
      final userId = userData['_id']['\$oid'];
      final user = chat_models.User(
        id: userId,
        name: userData['username'] ?? 'Unknown',
        email: userData['email'] ?? '',
        avatarUrl: userData['profilePic'] ?? 'https://via.placeholder.com/150',
        lastLogin: _formatTimestamp(userData['lastLogin']['\$date']),
      );

      _userCache[userId] = user;
    }

    _users = _userCache.values.toList();
  }

  // Find user by ID with improved performance
  chat_models.User? _findUserById(String userId) {
    return _userCache[userId];
  }

  // Get messages for a chat with caching for better performance
  List<chat_models.Message> _getMessagesForChat(String chatId) {
    if (_messagesData == null) return [];

    // Return from cache if available
    if (_chatMessagesCache.containsKey(chatId)) {
      return _chatMessagesCache[chatId]!;
    }

    final chatMessages =
        _messagesData!
            .where((msg) => msg['chatId']['\$oid'] == chatId)
            .toList();

    final messages =
        chatMessages.map((msg) {
          final senderId = msg['senderId']['\$oid'];
          final user = _findUserById(senderId);

          return chat_models.Message(
            id: msg['_id']['\$oid'],
            senderId: senderId,
            content: msg['content'] ?? '',
            timestamp: _formatTimestamp(msg['createdAt']['\$date']),
            type: msg['type'] ?? 'text',
            isRead: msg['isRead'] ?? false,
            mediaUrl: msg['mediaUrl'] ?? '',
            senderName: user?.name ?? 'Unknown',
            senderAvatar: user?.avatarUrl ?? '',
          );
        }).toList();

    // Cache the messages
    _chatMessagesCache[chatId] = messages;

    return messages;
  }

  // Process chat data with optimized approach
  void _processChats() {
    if (_chatsData == null || _users == null) return;

    final processedChats = <chat_models.Chat>[];

    for (final chatData in _chatsData!) {
      final chatId = chatData['_id']['\$oid'];
      final participant1Id = chatData['participantOneId']['\$oid'];
      final participant2Id = chatData['participantTwoId']['\$oid'];

      // Get participants
      final participant1 = _findUserById(participant1Id);
      final participant2 = _findUserById(participant2Id);

      final List<chat_models.User> participants = [];
      if (participant1 != null) participants.add(participant1);
      if (participant2 != null) participants.add(participant2);

      // Get messages
      final messages = _getMessagesForChat(chatId);

      // Get unread count
      int unreadCount = 0;
      if (_messagesData != null) {
        unreadCount =
            _messagesData!
                .where(
                  (msg) =>
                      msg['chatId']['\$oid'] == chatId &&
                      msg['senderId']['\$oid'] != participant1Id &&
                      msg['isRead'] == false,
                )
                .length;
      }

      // Get last message
      String lastMessage = 'No messages';
      String timestamp = _formatTimestamp(chatData['createdAt']['\$date']);

      if (messages.isNotEmpty) {
        messages.sort((a, b) {
          // For simplicity, sorting by ID (in a real app, use timestamp)
          return b.id.compareTo(a.id);
        });

        final latestMsg = messages.first;
        lastMessage =
            latestMsg.type == 'image' ? '📷 Image' : latestMsg.content;
        timestamp = latestMsg.timestamp;
      }

      processedChats.add(
        chat_models.Chat(
          id: chatId,
          title: participant2?.name ?? 'Unknown User',
          lastMessage: lastMessage,
          timestamp: timestamp,
          avatarUrl:
              participant2?.avatarUrl ?? 'https://via.placeholder.com/150',
          unreadCount: unreadCount,
          participants: participants,
          messages: messages,
        ),
      );
    }

    _chats = processedChats;
  }

  // Get all chats
  Future<List<chat_models.Chat>> getChats() async {
    if (_chats == null) {
      await initialize();
    }
    return _chats ?? [];
  }

  // Get chat by ID
  Future<chat_models.Chat?> getChatById(String chatId) async {
    if (_chats == null) {
      await initialize();
    }

    try {
      return _chats!.firstWhere((chat) => chat.id == chatId);
    } catch (e) {
      return null;
    }
  }

  // Get messages for a chat
  Future<List<chat_models.Message>> getMessages(String chatId) async {
    if (_chats == null) {
      await initialize();
    }

    try {
      return _chatMessagesCache[chatId] ?? [];
    } catch (e) {
      return [];
    }
  }

  // Delete a chat
  Future<void> deleteChat(String chatId) async {
    if (_chats == null) return;

    // Simulate delay for API call
    await Future.delayed(const Duration(milliseconds: 500));

    _chats!.removeWhere((chat) => chat.id == chatId);
    // Also clear from cache
    _chatMessagesCache.remove(chatId);
  }

  // Delete a message
  Future<void> deleteMessage(String chatId, String messageId) async {
    if (_chats == null) return;

    // Simulate delay for API call
    await Future.delayed(const Duration(milliseconds: 500));

    final chatIndex = _chats!.indexWhere((chat) => chat.id == chatId);
    if (chatIndex >= 0) {
      // Remove message from the chat
      _chats![chatIndex].messages.removeWhere((msg) => msg.id == messageId);

      // Update cache
      if (_chatMessagesCache.containsKey(chatId)) {
        _chatMessagesCache[chatId]!.removeWhere((msg) => msg.id == messageId);
      }

      // Update last message if needed
      final messages = _chats![chatIndex].messages;
      if (messages.isNotEmpty) {
        messages.sort((a, b) => b.id.compareTo(a.id));
        final latestMsg = messages.first;

        // Update chat with new last message
        _chats![chatIndex] = chat_models.Chat(
          id: _chats![chatIndex].id,
          title: _chats![chatIndex].title,
          lastMessage:
              latestMsg.type == 'image' ? '📷 Image' : latestMsg.content,
          timestamp: latestMsg.timestamp,
          avatarUrl: _chats![chatIndex].avatarUrl,
          unreadCount: _chats![chatIndex].unreadCount,
          participants: _chats![chatIndex].participants,
          messages: _chats![chatIndex].messages,
        );
      }
    }
  }
}
