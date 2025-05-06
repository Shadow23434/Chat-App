import 'package:chat_app/chat_app_ui/utils/app.dart';
import 'package:chat_app/chat_app_ui/models/models.dart';
import 'package:chat_app/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatelessWidget {
  static Route route(Chat chat) =>
      MaterialPageRoute(builder: (context) => ChatScreen(chat: chat));

  const ChatScreen({super.key, required this.chat});

  final Chat chat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        centerTitle: false,
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        leadingWidth: 54,
        leading: Align(
          alignment: Alignment.centerRight,
          child: IconBackGround(
            icon: CupertinoIcons.back,
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        title: _AppBarTitle(chat: chat),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: IconBorder(
                icon: CupertinoIcons.video_camera_solid,
                onTap: () {},
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: IconBorder(icon: CupertinoIcons.phone_solid, onTap: () {}),
            ),
          ),
        ],
      ),
      body: Column(
        children: [Expanded(child: _MessageList(chat: chat)), _ActionBar()],
      ),
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle({required this.chat});

  final Chat chat;

  UserModel _getReceiver() {
    var currentUserId = currentUser.id; // Replace with current userId
    return chat.participants.firstWhere((user) => user.id != currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    final receiver = _getReceiver();
    return Row(
      children: [
        Avatar.small(url: receiver.profilePic),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                receiver.username,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 2),
              const Text(
                'Online now',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MessageList extends StatefulWidget {
  const _MessageList({required this.chat});

  final Chat chat;

  @override
  State<_MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<_MessageList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Map<String, List<Message>> _groupMessagesByDate(List<Message> messages) {
    final grouped = <String, List<Message>>{};
    for (var message in messages) {
      final date = DateFormat('yyyy-MM-dd').format(message.createdAt);
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(message);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.chat.messages;
    if (messages.isEmpty) {
      return const Center(child: Text('No messages yet'));
    }

    final sortedMessages = List<Message>.from(messages)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final groupedMessages = _groupMessagesByDate(sortedMessages);
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      itemCount: groupedMessages.length,
      itemBuilder: (context, index) {
        final entry = groupedMessages.entries.elementAt(index);
        final date = entry.key;
        final messagesForDate = entry.value;
        return Column(
          children: [
            _DateLable(lable: date),
            ...messagesForDate.map((message) {
              final isOwnMessage =
                  message.senderId ==
                  currentUser.id; // Replace with current userId
              return isOwnMessage
                  ? _MessageOwnTile(
                    message: message.content,
                    messageDate: DateFormat(
                      'hh:mm a',
                    ).format(message.createdAt),
                  )
                  : _MessageTile(
                    message: message.content,
                    messageDate: DateFormat(
                      'hh:mm a',
                    ).format(message.createdAt),
                  );
            }),
          ],
        );
      },
    );
  }
}

class _DemoMessageList extends StatelessWidget {
  const _DemoMessageList();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView(
        children: const [
          _DateLable(lable: 'Yesterday'),
          _MessageTile(
            message: 'Hi, Lucy! How\'s your day going?',
            messageDate: '12:01 PM',
          ),
          _MessageOwnTile(
            message: 'You know how it goes...',
            messageDate: '12:02 PM',
          ),
          _MessageTile(
            message: 'Do you want Starbucks?',
            messageDate: '12:02 PM',
          ),
          _MessageOwnTile(
            message: 'Would be awesome!',
            messageDate: '12:03 PM',
          ),
          _MessageTile(message: 'Coming up!', messageDate: '12:03 PM'),
          _MessageOwnTile(message: 'YAY!!!', messageDate: '12:03 PM'),
        ],
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.message, required this.messageDate});

  final String message;
  final String messageDate;

  static const _borderRadius = 26.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(_borderRadius),
                  topRight: Radius.circular(_borderRadius),
                  bottomRight: Radius.circular(_borderRadius),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(message),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                messageDate,
                style: const TextStyle(
                  color: AppColors.textFaded,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageOwnTile extends StatelessWidget {
  const _MessageOwnTile({required this.message, required this.messageDate});

  final String message;
  final String messageDate;
  static const _borderRadius = 26.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(_borderRadius),
                  bottomRight: Radius.circular(_borderRadius),
                  bottomLeft: Radius.circular(_borderRadius),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(message),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                messageDate,
                style: const TextStyle(
                  color: AppColors.textFaded,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateLable extends StatelessWidget {
  const _DateLable({required this.lable});

  final String lable;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            child: Text(
              lable,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textFaded,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  width: 2,
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(Icons.attach_file_rounded),
            ),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: TextField(
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Type something...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: GlowingActionButton(
              color: AppColors.secondary,
              icon: Icons.send_rounded,
              onPressed: () {},
              size: 40,
            ),
          ),
        ],
      ),
    );
  }
}
