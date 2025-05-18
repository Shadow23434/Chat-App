import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:chat_app/admin_panel_ui/models/chats.dart' as chat_models;
import 'package:chat_app/admin_panel_ui/screens/chat_details.dart';
import 'package:chat_app/admin_panel_ui/services/demo_data.dart';
import 'package:chat_app/chat_app_ui/widgets/icon_buttons.dart';
import 'package:chat_app/chat_app_ui/widgets/avatar.dart';
import 'package:chat_app/admin_panel_ui/widget/card.dart';
import 'package:chat_app/theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:chat_app/admin_panel_ui/widget/pagination_controls.dart';

enum SortOption { ascending, descending }

enum AccountOption { signOut, info }

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final DemoData _demoData = DemoData();
  String _searchQuery = '';
  List<chat_models.Chat> _chats = [];
  bool _isLoading = true;
  final String _filterOption = 'all';
  bool _isFocused = false;
  bool _isClicked = false;

  // Pagination variables
  int _currentPage = 1;
  final int _itemsPerPage = 20;
  List<chat_models.Chat> _paginatedChats = [];

  // Analytics data
  int _totalMessages = 0;
  int _textMessages = 0;
  int _imageMessages = 0;
  int _audioMessages = 0;
  int _totalUnreadMessages = 0;

  @override
  void initState() {
    super.initState();
    _loadChats();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  Future<void> _loadChats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final chats = await _demoData.getChats();
      setState(() {
        _chats = chats;
        _isLoading = false;
        _updateAnalytics();
        _updatePaginatedChats();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load chats: $e');
    }
  }

  void _updateAnalytics() {
    _totalMessages = 0;
    _textMessages = 0;
    _imageMessages = 0;
    _audioMessages = 0;
    _totalUnreadMessages = 0;
    int readMessages = 0;

    for (var chat in _chats) {
      _totalMessages += chat.messages.length;

      for (var message in chat.messages) {
        // Count by message type
        switch (message.type) {
          case 'text':
            _textMessages++;
            break;
          case 'image':
            _imageMessages++;
            break;
          case 'audio':
            _audioMessages++;
            break;
        }

        // Count read/unread messages based on isRead property
        if (message.isRead) {
          readMessages++;
        } else {
          _totalUnreadMessages++;
        }
      }
    }
  }

  void _updatePaginatedChats() {
    final filteredChats = _filterChats();
    final int startIndex = (_currentPage - 1) * _itemsPerPage;
    final int endIndex =
        startIndex + _itemsPerPage > filteredChats.length
            ? filteredChats.length
            : startIndex + _itemsPerPage;

    if (startIndex >= filteredChats.length && _currentPage > 1) {
      // If current page has no items (e.g., after filtering), go to first page
      _currentPage = 1;
      _updatePaginatedChats();
      return;
    }

    setState(() {
      _paginatedChats = filteredChats.sublist(startIndex, endIndex);
    });
  }

  void _changePage(int page) {
    setState(() {
      _currentPage = page;
      _updatePaginatedChats();
    });
  }

  int get _totalPages {
    return (_filterChats().length / _itemsPerPage).ceil();
  }

  Future<void> _downloadChatData(chat_models.Chat? chat) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      String fileName;
      String jsonData;

      if (chat != null) {
        // Download specific chat
        jsonData = jsonEncode(chat.toJson());
        fileName =
            'chat_${chat.id}_${DateTime.now().millisecondsSinceEpoch}.json';
      } else {
        // Download all chats
        jsonData = jsonEncode(_chats.map((chat) => chat.toJson()).toList());
        fileName = 'all_chats_${DateTime.now().millisecondsSinceEpoch}.json';
      }

      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chat data downloaded to ${file.path}')),
      );
    } catch (e) {
      _showErrorSnackBar('Failed to download chat data: $e');
    }
  }

  Future<void> _deleteMessage(chat_models.Chat chat, String messageId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _demoData.deleteMessage(chat.id, messageId);
      await _loadChats();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message deleted successfully')),
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
      SnackBar(content: Text(message), backgroundColor: Colors.red),
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
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _deleteChat(String chatId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _demoData.deleteChat(chatId);
      await _loadChats();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat deleted successfully')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to delete chat: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        leadingWidth: 100,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Center(
            child: const Text(
              'Chats',
              style: TextStyle(color: AppColors.textLight, fontSize: 24),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 12, right: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search bar
                SizedBox(
                  width: 400,
                  child: TextFormField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    textAlign: TextAlign.start,
                    decoration: InputDecoration(
                      hintText: 'Search by name, or email',
                      hintStyle: TextStyle(color: AppColors.textFaded),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(8),
                        child: IconBorder(
                          icon: Icons.search_rounded,
                          color: AppColors.secondary,
                          size: 20,
                          onTap: () {
                            _currentPage = 1;
                            _updatePaginatedChats();
                          },
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.cardView,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                // Avatar container
                PopupMenuButton<AccountOption>(
                  borderRadius: BorderRadius.circular(12),
                  offset: Offset(0, 58),
                  tooltip: '',
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.cardView,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Avatar.small(
                            url:
                                'https://th.bing.com/th/id/OIP.V1Pj5o3-zDgGCehHF2UFggHaHa?w=185&h=185&c=7&r=0&o=5&pid=1.7',
                            onTap: () {},
                          ),
                          SizedBox(width: 6),
                          Text('Admin', style: TextStyle(fontSize: 14)),
                          _isClicked
                              ? Icon(Icons.keyboard_arrow_up_rounded)
                              : Icon(Icons.keyboard_arrow_down_rounded),
                        ],
                      ),
                    ),
                  ),
                  onOpened:
                      () => setState(() {
                        _isClicked = !_isClicked;
                      }),
                  onCanceled:
                      () => setState(() {
                        _isClicked = !_isClicked;
                      }),
                  onSelected: (AccountOption option) {
                    // Handle account options
                  },
                  itemBuilder:
                      (BuildContext context) => <PopupMenuEntry<AccountOption>>[
                        PopupMenuItem<AccountOption>(
                          value: AccountOption.info,
                          child: Row(
                            children: [
                              Icon(Icons.person, size: 20),
                              SizedBox(width: 8),
                              Text('Your Account'),
                            ],
                          ),
                        ),
                        PopupMenuItem<AccountOption>(
                          value: AccountOption.signOut,
                          child: Row(
                            children: [
                              Icon(Icons.logout_rounded, size: 20),
                              SizedBox(width: 8),
                              Text('Sign out'),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
          ),
        ],
      ),
      body: _Body(
        chats: _paginatedChats,
        allChats: _filterChats(),
        isLoading: _isLoading,
        onDelete: _deleteChat,
        onRefresh: _loadChats,
        onDeleteMessage: _deleteMessage,
        onViewUserDetails: _showUserDetails,
        downloadChatData: _downloadChatData,
        // Pass analytics data
        totalMessages: _totalMessages,
        textMessages: _textMessages,
        imageMessages: _imageMessages,
        audioMessages: _audioMessages,
        totalUnreadMessages: _totalUnreadMessages,
        // Pagination
        currentPage: _currentPage,
        totalPages: _totalPages,
        onPageChanged: _changePage,
        itemsPerPage: _itemsPerPage,
      ),
    );
  }

  List<chat_models.Chat> _filterChats() {
    // First filter by search query
    var filtered = _chats;

    if (_searchQuery.isNotEmpty) {
      filtered =
          _chats.where((chat) {
            // Search by participant name or email
            bool participantMatch = chat.participants.any((participant) {
              return participant.name.toLowerCase().contains(_searchQuery) ||
                  participant.email.toLowerCase().contains(_searchQuery);
            });

            return participantMatch;
          }).toList();
    }
    return filtered;
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.chats,
    required this.allChats,
    required this.isLoading,
    required this.onDelete,
    required this.onRefresh,
    required this.onDeleteMessage,
    required this.onViewUserDetails,
    required this.downloadChatData,
    required this.totalMessages,
    required this.textMessages,
    required this.imageMessages,
    required this.audioMessages,
    required this.totalUnreadMessages,
    // Pagination
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.itemsPerPage,
  });

  final List<chat_models.Chat> chats;
  final List<chat_models.Chat> allChats;
  final bool isLoading;
  final Function(String) onDelete;
  final VoidCallback onRefresh;
  final Function(chat_models.Chat, String) onDeleteMessage;
  final Function(chat_models.User) onViewUserDetails;
  final Function(chat_models.Chat?) downloadChatData;
  final int totalMessages;
  final int textMessages;
  final int imageMessages;
  final int audioMessages;
  final int totalUnreadMessages;
  // Pagination
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final int itemsPerPage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header and action buttons
                  SizedBox(
                    height: 70,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Chats',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 0),
                          child: Row(
                            children: [
                              IconNoBorder(
                                icon: Icons.download,
                                onTap: () => downloadChatData(null),
                              ),
                              SizedBox(width: 8),
                              IconNoBorder(
                                icon: Icons.refresh,
                                onTap: onRefresh,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _CardList(
                    chats: allChats,
                    totalUnreadMessages: totalUnreadMessages,
                  ),
                  SizedBox(height: 12),
                  // Chat's table with enhanced functionality
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.cardView,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                      child:
                          isLoading
                              ? Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.secondary,
                                ),
                              )
                              : allChats.isEmpty
                              ? Text('There are no chats to display.')
                              : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'All Chats',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  DataTable(
                                    columnSpacing: 10,
                                    columns: [
                                      DataColumn(
                                        label: Text('#'),
                                        columnWidth: FlexColumnWidth(0.1),
                                      ),
                                      DataColumn(
                                        label: Text('Chat ID'),
                                        columnWidth: FlexColumnWidth(0.2),
                                      ),
                                      DataColumn(
                                        label: Text('Participants'),
                                        columnWidth: FlexColumnWidth(0.3),
                                      ),
                                      DataColumn(
                                        label: Text('Last message at'),
                                        columnWidth: FlexColumnWidth(0.2),
                                      ),
                                      DataColumn(
                                        label: Text('Actions'),
                                        columnWidth: FlexColumnWidth(0.2),
                                      ),
                                    ],
                                    rows:
                                        chats.asMap().entries.map((entry) {
                                          int index = entry.key;
                                          chat_models.Chat chat = entry.value;
                                          return DataRow(
                                            cells: [
                                              DataCell(
                                                Text(
                                                  '${(currentPage - 1) * itemsPerPage + index + 1}',
                                                ),
                                              ),
                                              DataCell(
                                                Tooltip(
                                                  message: chat.id,
                                                  child: Text(
                                                    '${chat.id.substring(0, 8)}...',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                              // Participants cell
                                              DataCell(
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      '${chat.participants.length}',
                                                    ),
                                                    SizedBox(width: 4),
                                                    SizedBox(
                                                      width: 80,
                                                      child: ListView.builder(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        shrinkWrap: true,
                                                        padding:
                                                            EdgeInsets.only(
                                                              right: 4,
                                                            ),
                                                        itemCount:
                                                            chat
                                                                .participants
                                                                .length,
                                                        itemBuilder: (
                                                          context,
                                                          index,
                                                        ) {
                                                          final participant =
                                                              chat.participants[index];
                                                          return InkWell(
                                                            onTap: () {
                                                              onViewUserDetails(
                                                                participant,
                                                              );
                                                            },
                                                            child: Tooltip(
                                                              message:
                                                                  participant
                                                                      .name,
                                                              child: CircleAvatar(
                                                                radius: 12,
                                                                backgroundImage:
                                                                    NetworkImage(
                                                                      participant
                                                                          .avatarUrl,
                                                                    ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  chat.timestamp,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              DataCell(
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    IconNoBorder(
                                                      icon: Icons.visibility,
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    ChatDetails(
                                                                      chat:
                                                                          chat,
                                                                    ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    IconNoBorder(
                                                      icon: Icons.download,
                                                      onTap:
                                                          () =>
                                                              downloadChatData(
                                                                chat,
                                                              ),
                                                    ),
                                                    IconNoBorder(
                                                      icon:
                                                          Icons.delete_rounded,
                                                      onTap: () {
                                                        _showDeleteConfirmation(
                                                          context,
                                                          chat,
                                                          onDelete,
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                  ),
                                  // Pagination controls
                                  if (allChats.length > itemsPerPage)
                                    PaginationControls(
                                      currentPage: currentPage,
                                      totalPages: totalPages,
                                      onPageChanged: onPageChanged,
                                      itemsPerPage: itemsPerPage,
                                      totalItems: allChats.length,
                                    ),
                                ],
                              ),
                    ),
                  ),
                  SizedBox(height: 12),
                ],
              ),
            ),
            SizedBox(width: 12),
            // Chat statistics
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.cardView,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chat Analytics',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        _buildChatStats(),
                        SizedBox(height: 12),
                        Text(
                          'Message Types',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        _buildMessageTypeStats(),
                        SizedBox(height: 12),
                        Text(
                          'Activity Metrics',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        _buildActivityMetrics(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatStats() {
    // Calculate percentages
    final totalMsgs = totalMessages > 0 ? totalMessages : 1;
    final textPercentage = (textMessages / totalMsgs) * 100;
    final imagePercentage = (imageMessages / totalMsgs) * 100;
    final audioPercentage = (audioMessages / totalMsgs) * 100;

    return SizedBox(
      height: 180,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              color: Colors.blue,
              value: textPercentage,
              radius: 50,
              title: '${textPercentage.toStringAsFixed(0)}%',
              titleStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: Colors.green,
              value: imagePercentage,
              radius: 50,
              title: '${imagePercentage.toStringAsFixed(0)}%',
              titleStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: Colors.orange,
              value: audioPercentage,
              radius: 50,
              title: '${audioPercentage.toStringAsFixed(0)}%',
              titleStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          centerSpaceColor: AppColors.cardView,
        ),
      ),
    );
  }

  Widget _buildMessageTypeStats() {
    return SizedBox(
      height: 390,
      child: ListView.separated(
        itemCount: 3,
        separatorBuilder: (context, index) => SizedBox(height: 12),
        itemBuilder: (context, index) {
          final totalMsgs = totalMessages > 0 ? totalMessages : 1;
          switch (index) {
            case 0:
              return ProcessCard(
                title: 'Text',
                subtile: '$textMessages Messages',
                icon: Icons.message,
                value: textMessages / totalMsgs,
                color: Colors.blue,
                hasBorder: true,
              );
            case 1:
              return ProcessCard(
                title: 'Images',
                subtile: '$imageMessages Messages',
                icon: Icons.image,
                value: imageMessages / totalMsgs,
                color: Colors.green,
                hasBorder: true,
              );
            case 2:
              return ProcessCard(
                title: 'Audio',
                subtile: '$audioMessages Messages',
                icon: Icons.mic,
                value: audioMessages / totalMsgs,
                color: Colors.orange,
                hasBorder: true,
              );
            default:
              return Container();
          }
        },
      ),
    );
  }

  Widget _buildActivityMetrics() {
    return SizedBox(
      height: 130,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: totalMessages > 0 ? totalMessages.toDouble() : 10,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  String text;
                  switch (value.toInt()) {
                    case 0:
                      text = 'Messages';
                      break;
                    case 1:
                      text = 'Read';
                      break;
                    case 2:
                      text = 'Unread';
                      break;
                    default:
                      text = '';
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: totalMessages.toDouble(),
                  color: Colors.blue,
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: (totalMessages - totalUnreadMessages).toDouble(),
                  color: Colors.green,
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: totalUnreadMessages.toDouble(),
                  color: Colors.red,
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    chat_models.Chat chat,
    Function(String) onDelete,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Chat'),
            content: Text(
              'Are you sure you want to delete the chat with ID:${chat.id}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onDelete(chat.id);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}

class _CardList extends StatelessWidget {
  const _CardList({required this.chats, required this.totalUnreadMessages});

  final List<chat_models.Chat> chats;
  final int totalUnreadMessages;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: 2,
          separatorBuilder: (context, index) => SizedBox(width: 12),
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return ProcessCard(
                  title: 'Chats',
                  subtile: '${chats.length} Chats',
                  icon: Icons.chat,
                  value: 1,
                  color: AppColors.secondary,
                );
              case 1:
                // Get total count of all messages across all chats
                int totalMessages = chats.fold(
                  0,
                  (sum, chat) => sum + chat.messages.length,
                );
                return ProcessCard(
                  title: 'Messages',
                  subtile: '$totalMessages Messages',
                  icon: Icons.message,
                  value: 1,
                  color: Colors.blue,
                );
              default:
                return Container();
            }
          },
        ),
      ),
    );
  }

  // Helper method to calculate total messages
  int totalMessages() {
    return chats.fold(0, (sum, chat) => sum + chat.messages.length);
  }
}
