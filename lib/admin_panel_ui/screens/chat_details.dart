import 'package:audioplayers/audioplayers.dart';
import 'package:chat_app/admin_panel_ui/widgets/widgets.dart';
import 'package:chat_app/chat_app_ui/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/theme.dart';
import 'package:chat_app/core/models/chat_model.dart';
import 'package:chat_app/core/models/message_model.dart';
import 'package:chat_app/core/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/admin_panel_ui/services/index.dart';

class ChatDetails extends StatefulWidget {
  final ChatModel chat;

  const ChatDetails({super.key, required this.chat});

  @override
  State<ChatDetails> createState() => _ChatDetailsState();
}

class _ChatDetailsState extends State<ChatDetails> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<MessageModel> messages = [];
  bool isLoading = true;
  bool isSending = false;
  String? currentlyPlayingMessageId;

  // Audio players management
  final Map<String, AudioPlayer> _audioPlayers = {};

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    // Dispose all audio players
    _audioPlayers.forEach((key, player) {
      player.dispose();
    });
    _audioPlayers.clear();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      isLoading = true;
    });

    try {
      final chatService = Provider.of<ChatService>(context, listen: false);
      final response = await chatService.getChatDetails(widget.chat.id);

      setState(() {
        if (response['messages'] is List) {
          messages =
              (response['messages'] as List).cast<MessageModel>().toList();
        } else {
          messages = [];
        }
        isLoading = false;
      });

      // Scroll to bottom after messages are loaded
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Failed to load messages: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      customSnackBar(
        'Error',
        message,
        Icons.info_outline_rounded,
        AppColors.accent,
      ),
    );
  }

  void _handleAudioPlayingChanged(String? messageId) {
    setState(() {
      // Stop all other audio players
      if (currentlyPlayingMessageId != null &&
          currentlyPlayingMessageId != messageId) {
        _audioPlayers[currentlyPlayingMessageId]?.pause();
      }
      currentlyPlayingMessageId = messageId;
    });
  }

  Future<void> _deleteMessage(String messageId) async {
    try {
      setState(() {
        isSending = true;
      });

      final chatService = Provider.of<ChatService>(context, listen: false);
      await chatService.deleteMessage(messageId);

      // Reload messages after deletion
      await _loadMessages();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          customSnackBar(
            'Success',
            'Message deleted successfully',
            Icons.check_circle_outline,
            Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to delete message: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          isSending = false;
        });
      }
    }
  }

  Future<void> _deleteChat() async {
    try {
      final chatService = Provider.of<ChatService>(context, listen: false);
      await chatService.deleteChat(widget.chat.id);
      Navigator.pop(context, 'deleted');
    } catch (e) {
      _showErrorSnackBar('Failed to delete chat: $e');
    }
  }

  void _showParticipantsList() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Participants'),
            content: SizedBox(
              width: 300,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.chat.participants.length,
                itemBuilder: (context, index) {
                  final participant = widget.chat.participants[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(participant.profilePic),
                    ),
                    title: Text(participant.username),
                    subtitle: Text(participant.lastLogin?.toString() ?? ''),
                    onTap: () {
                      Navigator.pop(context);
                      _showUserDetails(participant);
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showUserDetails(UserModel user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('User Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(user.profilePic),
                  ),
                ),
                SizedBox(height: 16),
                Text('Name: ${user.username}'),
                Text('Email: ${user.email}'),
                if (user.lastLogin != null)
                  Text('Last Login: ${user.lastLogin}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title: Text(
          'Chat Details',
          style: TextStyle(color: AppColors.textLight),
        ),
        actions: [_buildContextMenu()],
        actionsPadding: EdgeInsets.only(right: 16),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildMessageList(),
          ),
        ],
      ),
    );
  }

  Widget _buildContextMenu() {
    return Row(
      children: [
        Text(
          '${messages.length}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 4),
        Icon(Icons.message, color: Colors.white),
        SizedBox(width: 16),
        Text(
          '${widget.chat.participants.length}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 4),
        InkWell(
          onTap: _showParticipantsList,
          child: Icon(Icons.people, color: Colors.white),
        ),
        SizedBox(width: 16),
        InkWell(
          onTap: _showDeleteChatConfirmation,
          child: Icon(Icons.delete_outline, color: AppColors.accent),
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    return messages.isEmpty
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'No messages in this chat',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        )
        : ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16.0),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final bool showDateSeparator =
                index == 0 ||
                _shouldShowDateSeparator(messages[index - 1], message);

            return Column(
              children: [
                if (showDateSeparator) _buildDateSeparator(message),
                _buildMessageItem(message),
              ],
            );
          },
        );
  }

  bool _shouldShowDateSeparator(MessageModel previous, MessageModel current) {
    // This is a simplified implementation
    // In a real app, you would parse the timestamp and compare dates
    return previous.createdAt.day != current.createdAt.day ||
        previous.createdAt.month != current.createdAt.month ||
        previous.createdAt.year != current.createdAt.year;
  }

  Widget _buildDateSeparator(MessageModel message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${message.createdAt.day}/${message.createdAt.month}/${message.createdAt.year}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ],
      ),
    );
  }

  Widget _buildAudioMessage(MessageModel message) {
    return AudioMessageWidget(
      audioUrl: message.mediaUrl!,
      messageId: message.id,
      currentlyPlayingMessageId: currentlyPlayingMessageId,
      onPlayingChanged: _handleAudioPlayingChanged,
    );
  }

  Widget _buildMessageItem(MessageModel message) {
    final bool isCurrentUser = false;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            ImageService.avatarImage(
              url: message.sender.profilePic,
              radius: 16,
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color:
                    isCurrentUser
                        ? AppColors.secondary.withOpacity(0.1)
                        : AppColors.cardView,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser) ...[
                    Text(
                      message.sender.username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],

                  // Image Message
                  if (message.type == 'image' &&
                      message.mediaUrl != null &&
                      message.mediaUrl!.isNotEmpty) ...[
                    ImageService.optimizedNetworkImage(
                      url: message.mediaUrl,
                      height: 150,
                      width: 200,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(8),
                      placeholderColor: Colors.grey.shade300,
                    ),
                    if (message.content.isNotEmpty) const SizedBox(height: 8),
                  ],

                  // Audio Message
                  if (message.type == 'audio' &&
                      message.mediaUrl != null &&
                      message.mediaUrl!.isNotEmpty) ...[
                    _buildAudioMessage(message),
                    if (message.content.isNotEmpty) const SizedBox(height: 8),
                  ],

                  // Text Content
                  if (message.content.isNotEmpty) Text(message.content),
                  const SizedBox(height: 4),

                  // Timestamp and Read Status
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        message.isRead ? Icons.done_all : Icons.done,
                        size: 14,
                        color:
                            message.isRead ? AppColors.secondary : Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 16, color: Colors.grey.shade600),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteMessageConfirmation(message);
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: AppColors.accent,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Delete',
                          style: TextStyle(color: AppColors.accent),
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
    );
  }

  void _showDeleteMessageConfirmation(MessageModel message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Message'),
            content: const Text(
              'Are you sure you want to delete this message? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteMessage(message.id);
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.accent),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _showDeleteChatConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Chat'),
            content: Text(
              'Are you sure you want to delete the chat with ID: ${widget.chat.id}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteChat();
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: AppColors.accent),
                ),
              ),
            ],
          ),
    );
  }
}
