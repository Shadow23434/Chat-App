import 'package:flutter/material.dart';
import 'package:chat_app/admin_panel_ui/models/chats.dart';
import 'package:chat_app/admin_panel_ui/screens/chat_details.dart';
import 'package:chat_app/admin_panel_ui/services/demo_data_service.dart';
import 'package:chat_app/chat_app_ui/widgets/icon_buttons.dart';
import 'package:chat_app/chat_app_ui/widgets/avatar.dart';
import 'package:chat_app/admin_panel_ui/widget/card.dart';
import 'package:chat_app/theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:file_saver/file_saver.dart';

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
  final DemoDataService _dataService = DemoDataService();
  String _searchQuery = '';
  List<Chat> _chats = [];
  bool _isLoading = true;
  String _filterOption = 'all';
  bool _isFocused = false;
  bool _isClicked = false;

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
      final chats = await _dataService.getChats();
      setState(() {
        _chats = chats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load chats: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
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
      await _dataService.deleteChat(chatId);
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
                      hintText: 'Search',
                      hintStyle: TextStyle(color: AppColors.textFaded),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(8),
                        child: IconBorder(
                          icon: Icons.search_rounded,
                          color: AppColors.secondary,
                          size: 20,
                          onTap: () {},
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
        chats: _filterChats(),
        isLoading: _isLoading,
        onDelete: _deleteChat,
        onFilterChange: (String filter) {
          setState(() {
            _filterOption = filter;
          });
        },
        currentFilter: _filterOption,
        onRefresh: _loadChats,
      ),
    );
  }

  List<Chat> _filterChats() {
    // First filter by search query
    var filtered =
        _chats.where((chat) {
          return chat.title.toLowerCase().contains(_searchQuery) ||
              chat.lastMessage.toLowerCase().contains(_searchQuery);
        }).toList();

    // Then apply additional filters
    switch (_filterOption) {
      case 'unread':
        filtered = filtered.where((chat) => chat.unreadCount > 0).toList();
        break;
      case 'recent':
        filtered.sort((a, b) {
          // For demo purposes, we'll just sort by ID
          // In a real app, you would sort by timestamp
          return b.id.compareTo(a.id);
        });
        break;
      case 'oldest':
        filtered.sort((a, b) {
          // For demo purposes, we'll just sort by ID
          // In a real app, you would sort by timestamp
          return a.id.compareTo(b.id);
        });
        break;
      default:
        // Default sorting for 'all' option
        filtered.sort((a, b) {
          // Sort by unread first, then by timestamp
          if (a.unreadCount > 0 && b.unreadCount == 0) {
            return -1;
          } else if (a.unreadCount == 0 && b.unreadCount > 0) {
            return 1;
          } else {
            return b.id.compareTo(a.id); // Sort by most recent
          }
        });
    }

    return filtered;
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.chats,
    required this.isLoading,
    required this.onDelete,
    required this.onFilterChange,
    required this.currentFilter,
    required this.onRefresh,
  });

  final List<Chat> chats;
  final bool isLoading;
  final Function(String) onDelete;
  final Function(String) onFilterChange;
  final String currentFilter;
  final VoidCallback onRefresh;

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
                  // Header and refresh button
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
                    chats: chats,
                    onFilterChange: onFilterChange,
                    currentFilter: currentFilter,
                  ),
                  SizedBox(height: 12),
                  // Chat's table
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
                              ? Center(child: CircularProgressIndicator())
                              : chats.isEmpty
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
                                        label: Text('User'),
                                        columnWidth: FlexColumnWidth(0.2),
                                      ),
                                      DataColumn(
                                        label: Text('Last Message'),
                                        columnWidth: FlexColumnWidth(0.35),
                                      ),
                                      DataColumn(
                                        label: Text('Time'),
                                        columnWidth: FlexColumnWidth(0.15),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                        columnWidth: FlexColumnWidth(0.2),
                                      ),
                                    ],
                                    rows:
                                        chats.asMap().entries.map((entry) {
                                          int index = entry.key;
                                          Chat chat = entry.value;
                                          return DataRow(
                                            cells: [
                                              DataCell(Text('${index + 1}')),
                                              DataCell(
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Avatar.small(
                                                      url: chat.avatarUrl,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Flexible(
                                                      child: Text(
                                                        chat.title,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                    ),
                                                    if (chat.unreadCount > 0)
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                          left: 4,
                                                        ),
                                                        padding: EdgeInsets.all(
                                                          4,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                              color: Colors.red,
                                                              shape:
                                                                  BoxShape
                                                                      .circle,
                                                            ),
                                                        child: Text(
                                                          chat.unreadCount
                                                              .toString(),
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  chat.lastMessage,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                                      MainAxisAlignment
                                                          .spaceAround,
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
                                ],
                              ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            // Chat statistics
            Expanded(
              flex: 2,
              child: Container(
                height: 600,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.cardView,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Center(
                    child: Column(
                      children: [
                        _buildChatStats(),
                        SizedBox(height: 12),
                        _buildMessageTypeStats(),
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
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              color: Colors.blue,
              value: 60,
              radius: 50,
              title: '60%',
              titleStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: Colors.red,
              value: 40,
              radius: 50,
              title: '40%',
              titleStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildMessageTypeStats() {
    return Expanded(
      child: ListView.separated(
        itemCount: 3,
        separatorBuilder: (context, index) => SizedBox(height: 12),
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return ProcessCard(
                title: 'Text',
                subtile: '75 Messages',
                icon: Icons.message,
                value: 0.75,
                color: Colors.blue,
                hasBorder: true,
              );
            case 1:
              return ProcessCard(
                title: 'Images',
                subtile: '15 Messages',
                icon: Icons.image,
                value: 0.15,
                color: Colors.green,
                hasBorder: true,
              );
            case 2:
              return ProcessCard(
                title: 'Audio',
                subtile: '10 Messages',
                icon: Icons.mic,
                value: 0.10,
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

  void _showDeleteConfirmation(
    BuildContext context,
    Chat chat,
    Function(String) onDelete,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Chat'),
            content: Text(
              'Are you sure you want to delete the chat with ${chat.title}?',
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
  const _CardList({
    required this.chats,
    required this.onFilterChange,
    required this.currentFilter,
  });

  final List<Chat> chats;
  final Function(String) onFilterChange;
  final String currentFilter;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: 3,
          separatorBuilder: (context, index) => SizedBox(width: 12),
          itemBuilder: (context, index) {
            int unreadCount = chats.fold(
              0,
              (sum, chat) => sum + chat.unreadCount,
            );

            switch (index) {
              case 0:
                return InkWell(
                  onTap: () => onFilterChange('all'),
                  child: ProcessCard(
                    title: 'All Chats',
                    subtile: '${chats.length} Chats',
                    icon: Icons.chat,
                    value: 1,
                    color: AppColors.secondary,
                  ),
                );
              case 1:
                return InkWell(
                  onTap: () => onFilterChange('unread'),
                  child: ProcessCard(
                    title: 'Unread',
                    subtile: '$unreadCount Messages',
                    icon: Icons.mark_chat_unread,
                    value: unreadCount / (chats.isEmpty ? 1 : chats.length),
                    color: Colors.red,
                  ),
                );
              case 2:
                return InkWell(
                  onTap: () => onFilterChange('recent'),
                  child: ProcessCard(
                    title: 'Recent',
                    subtile: '${chats.length} Chats',
                    icon: Icons.history,
                    value: 0.8,
                    color: Colors.green,
                  ),
                );
              default:
                return Container();
            }
          },
        ),
      ),
    );
  }
}
