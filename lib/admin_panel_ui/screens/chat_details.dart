import 'package:flutter/material.dart';
import 'package:chat_app/admin_panel_ui/models/chats.dart' as chat_models;
import 'package:chat_app/admin_panel_ui/services/demo_data.dart';
import 'package:chat_app/theme.dart';

class ChatDetails extends StatefulWidget {
  final chat_models.Chat chat;

  const ChatDetails({super.key, required this.chat});

  @override
  State<ChatDetails> createState() => _ChatDetailsState();
}

class _ChatDetailsState extends State<ChatDetails> {
  final DemoData _demoData = DemoData();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<chat_models.Message> messages = [];
  bool isLoading = true;
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      isLoading = true;
    });

    try {
      final chatMessages = await _demoData.getMessages(widget.chat.id);
      setState(() {
        messages = chatMessages;
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
      SnackBar(content: Text(message), backgroundColor: AppColors.accent),
    );
  }

  Future<void> _deleteMessage(String messageId) async {
    try {
      await _demoData.deleteMessage(widget.chat.id, messageId);
      await _loadMessages();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Message deleted')));
    } catch (e) {
      _showErrorSnackBar('Failed to delete message: $e');
    }
  }

  Future<void> _deleteChat() async {
    try {
      await _demoData.deleteChat(widget.chat.id);
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
                      backgroundImage: NetworkImage(participant.avatarUrl),
                    ),
                    title: Text(participant.name),
                    subtitle: Text(participant.lastLogin),
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

  void _showUserDetails(chat_models.User user) {
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
                    backgroundImage: NetworkImage(user.avatarUrl),
                  ),
                ),
                SizedBox(height: 16),
                Text('Name: ${user.name}'),
                Text('Email: ${user.email}'),
                if (user.lastLogin.isNotEmpty)
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
          '${widget.chat.messages.length}',
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

  bool _shouldShowDateSeparator(
    chat_models.Message previous,
    chat_models.Message current,
  ) {
    // This is a simplified implementation
    // In a real app, you would parse the timestamp and compare dates
    return previous.id.substring(0, 5) != current.id.substring(0, 5);
  }

  Widget _buildDateSeparator(chat_models.Message message) {
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
                message.timestamp,
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

  Widget _buildMessageItem(chat_models.Message message) {
    final bool isCurrentUser = message.senderId == 'user_1';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              backgroundImage: NetworkImage(
                message.senderAvatar ?? widget.chat.avatarUrl,
              ),
              radius: 16,
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
                      message.senderName ?? 'Unknown',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (message.type == 'image' &&
                      message.mediaUrl != null &&
                      message.mediaUrl!.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        message.mediaUrl!,
                        height: 150,
                        width: 200,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 150,
                            width: 200,
                            color: Colors.grey.shade300,
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                color: AppColors.secondary,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 150,
                            width: 200,
                            color: Colors.grey.shade300,
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (message.content.isNotEmpty) const SizedBox(height: 8),
                  ],
                  if (message.content.isNotEmpty) Text(message.content),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.timestamp,
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

  void _showDeleteMessageConfirmation(chat_models.Message message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Message'),
            content: const Text(
              'Are you sure you want to delete this message?',
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
                child: const Text(
                  'Delete',
                  style: TextStyle(color: AppColors.accent),
                ),
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
