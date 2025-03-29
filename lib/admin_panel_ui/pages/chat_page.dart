import 'package:chat_app/admin_panel_ui/models/chats.dart';
import 'package:chat_app/admin_panel_ui/screens/chat_details.dart';
import 'package:chat_app/chat_app_ui/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/material.dart';

enum SortOption { ascending, descending }

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Chat> _filteredChats = [];
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _filteredChats = List.from(chats);
    _focusNode.addListener(() {
      setState(() {});
    });
    _searchController.addListener(() {
      _filterChats();
    });
  }

  void _filterChats() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredChats = List.from(chats);
      } else {
        _filteredChats =
            chats.where((chat) {
              return chat.title.toLowerCase().contains(query) ||
                  chat.lastMessage.toLowerCase().contains(query);
            }).toList();
      }
      _sortChats();
    });
  }

  void _sortChats() {
    setState(() {
      _filteredChats.sort((a, b) {
        return _sortAscending
            ? a.title.compareTo(b.title)
            : b.title.compareTo(a.title);
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
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
                SizedBox(
                  width: 400,
                  child: TextFormField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    textAlign: TextAlign.start,
                    decoration: InputDecoration(
                      hintText: 'Search Chats',
                      hintStyle: TextStyle(color: AppColors.textFaded),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(8),
                        child: IconBorder(
                          icon: Icons.search_rounded,
                          color: AppColors.secondary,
                          size: 20,
                          onTap: () => _filterChats(),
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
              ],
            ),
          ),
        ],
      ),
      body: _Body(
        chats: _filteredChats,
        onSort: (SortOption option) {
          setState(() {
            _sortAscending = (option == SortOption.ascending);
            _sortChats();
          });
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.chats, required this.onSort});
  final List<Chat> chats;
  final void Function(SortOption) onSort;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Chats',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [IconNoBorder(icon: Icons.refresh, onTap: () {})],
                  ),
                ],
              ),
            ),
            _ChatList(chats: chats),
          ],
        ),
      ),
    );
  }
}

class _ChatList extends StatelessWidget {
  const _ChatList({required this.chats});

  final List<Chat> chats;

  @override
  Widget build(BuildContext context) {
    return chats.isEmpty
        ? Center(child: Text('No chats available.'))
        : ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: chats.length,
          separatorBuilder: (context, index) => SizedBox(height: 12),
          itemBuilder: (context, index) {
            final chat = chats[index];
            return ListTile(
              leading: Avatar.small(url: chat.avatarUrl),
              title: Text(chat.title),
              subtitle: Text(chat.lastMessage),
              trailing: Text(chat.timestamp),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChatDetails(chat: chat),
                  ),
                );
              },
            );
          },
        );
  }
}
