import 'package:flutter/material.dart';
import 'package:chat_app/core/models/index.dart';
import 'package:chat_app/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/admin_panel_ui/services/index.dart';
import 'widgets/app_bar/chat_page_app_bar.dart';
import 'widgets/body/chat_page_body.dart';
import 'widgets/dialogs/user_details_dialog.dart';
import 'widgets/dialogs/delete_confirmation_dialog.dart';
import 'package:file_saver/file_saver.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = true;
  bool _isPageLoading = false;
  final String _filterOption = 'all';
  bool _isFocused = false;
  bool _isClicked = false;

  // Pagination variables
  int _currentPage = 1;
  final int _itemsPerPage = 20;
  List<ChatModel> _paginatedChats = [];

  // Analytics data
  int _totalMessages = 0;
  int _textMessages = 0;
  int _imageMessages = 0;
  int _audioMessages = 0;
  int _unreadMessages = 0;
  int _readMessages = 0;

  // New response structure
  int _totalPages = 0;
  int _totalChatsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadChats();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  Future<void> _loadChats() async {
    setState(() {
      _isLoading = true;
      _isPageLoading = true;
    });

    try {
      final chatService = Provider.of<ChatService>(context, listen: false);
      final response = await chatService.getChats(
        page: _currentPage,
        limit: _itemsPerPage,
        search: _searchController.text,
        sort: 'desc',
      );

      setState(() {
        _paginatedChats = (response['chats'] as List).cast<ChatModel>();
        _totalPages = response['pagination']?['pages'] ?? 0;
        _totalChatsCount = response['pagination']?['totalChat'] ?? 0;

        _isLoading = false;
        _isPageLoading = false;

        // Update analytics from stats
        final stats = response['stats'];
        if (stats != null) {
          _totalMessages = stats['totalMessages'] ?? 0;
          _textMessages = stats['textCount'] ?? 0;
          _imageMessages = stats['imageCount'] ?? 0;
          _readMessages = stats['readCount'] ?? 0;
          // Ensure operands are not null before subtraction
          _audioMessages =
              (_totalMessages ?? 0) -
              (_textMessages ?? 0) -
              (_imageMessages ?? 0);
          _unreadMessages = (_totalMessages ?? 0) - (_readMessages ?? 0);
        } else {
          // Reset stats to 0 if stats object is null
          _totalMessages = 0;
          _textMessages = 0;
          _imageMessages = 0;
          _readMessages = 0;
          _audioMessages = 0;
          _unreadMessages = 0;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isPageLoading = false;
      });
      _showErrorSnackBar('Failed to load chats: $e');
    }
  }

  void _changePage(int page) {
    setState(() {
      _currentPage = page;
    });
    _loadChats();
  }

  Future<void> _deleteChat(String chatId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final chatService = Provider.of<ChatService>(context, listen: false);
      await chatService.deleteChat(chatId);
      await _loadChats();
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackBar(
          'Success',
          'Chat deleted successfully',
          Icons.check_circle_outline,
          Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to delete chat: $e');
    }
  }

  Future<void> _downloadChatData(ChatModel? chat) async {
    if (chat == null) {
      _showErrorSnackBar('Please select a specific chat to download.');
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // Call the service to download chat data (CSV bytes)
      final chatService = Provider.of<ChatService>(context, listen: false);
      final responseBytes = await chatService.downloadChat(chat.id);

      // Use file_saver for cross-platform saving
      final fileName =
          'chat_${chat.id}_${DateTime.now().millisecondsSinceEpoch}';

      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: responseBytes,
        ext: 'csv', // Specify extension
        mimeType: MimeType.csv,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackBar(
          'Success',
          'Chat data downloaded.', // Generic message as path might not be relevant on web
          Icons.check_circle_outline_outlined,
          Colors.green,
        ),
      );
    } catch (e) {
      // Show error message
      _showErrorSnackBar('Failed to download chat data: $e');
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  Future<void> _downloadAllChatsData() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // Call the service to download all chats data (CSV bytes)
      final chatService = Provider.of<ChatService>(context, listen: false);
      final responseBytes = await chatService.downloadAllChats();

      // Use file_saver for cross-platform saving
      final fileName = 'all_chats_${DateTime.now().millisecondsSinceEpoch}';

      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: responseBytes,
        ext: 'csv', // Specify extension
        mimeType: MimeType.csv,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackBar(
          'Success',
          'All chat data downloaded.', // Generic message
          Icons.check_circle_outline_outlined,
          Colors.green,
        ),
      );
    } catch (e) {
      // Show error message
      _showErrorSnackBar('Failed to download all chat data: $e');
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final chatService = Provider.of<ChatService>(context, listen: false);
      await chatService.deleteMessage(messageId);
      await _loadChats();
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackBar(
          'Success',
          'Message deleted successfully',
          Icons.check_circle_outline,
          Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to delete message: $e');
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

  void _showUserDetails(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => UserDetailsDialog(user: user),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    ChatModel chat,
    Function(String) onDelete,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => DeleteConfirmationDialog(
            title: 'Delete Chat',
            content:
                'Are you sure you want to delete the chat with ID: ${chat.id}?',
            onDelete: () => onDelete(chat.id),
          ),
    );
  }

  List<ChatModel> _filterChats() {
    if (_searchController.text.isEmpty) {
      return _paginatedChats; // Return current page if no search
    }
    return []; // Or potentially filter _paginatedChats if needed, but API search is preferred.
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatPageAppBar(
        searchController: _searchController,
        focusNode: _focusNode,
        isFocused: _isFocused,
        isClicked: _isClicked,
        onSearch: () {
          setState(() {
            _currentPage = 1;
          });
          _loadChats();
        },
        onIsClickedChanged: (value) {
          setState(() {
            _isClicked = value;
          });
        },
        onOptionSelected: (option) {
          if (option == AccountOption.signOut) {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          } else if (option == AccountOption.info) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/account-info',
              (route) => false,
            );
          }
        },
      ),
      body: ChatPageBody(
        chats: _paginatedChats,
        allChats: _filterChats(),
        isLoading: _isLoading || _isPageLoading,
        onDelete: _deleteChat,
        onRefresh: _loadChats,
        onDeleteMessage: _deleteMessage,
        onViewUserDetails: _showUserDetails,
        downloadChatData: _downloadChatData,
        totalMessages: _totalMessages,
        textMessages: _textMessages,
        imageMessages: _imageMessages,
        audioMessages: _audioMessages,
        totalUnreadMessages: _unreadMessages,
        currentPage: _currentPage,
        totalPages: _totalPages,
        onPageChanged: _changePage,
        itemsPerPage: _itemsPerPage,
        onDeleteConfirmation: _showDeleteConfirmation,
        totalChatsCount: _totalChatsCount,
        onDownloadAllChats: _downloadAllChatsData,
      ),
    );
  }
}
