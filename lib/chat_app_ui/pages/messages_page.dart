import 'dart:math';
import 'package:chat_app/admin_panel_ui/models/users.dart';
import 'package:chat_app/chat_app_ui/app.dart';
import 'package:chat_app/chat_app_ui/helpers.dart';
import 'package:chat_app/chat_app_ui/models/models.dart';
import 'package:chat_app/chat_app_ui/screens/screens.dart';
import 'package:chat_app/chat_app_ui/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:faker/faker.dart' as faker_pkg;
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  List<Chat> _generateSortedChatData() {
    var currentUserId = currentUser.id;

    List<Chat> chats = List.generate(20, (index) {
      final chatId = faker_pkg.faker.guid.guid();
      // Generate participants (two users per chat)
      final participant1 = users[Random().nextInt(users.length)];
      User participant2;
      do {
        participant2 = users[Random().nextInt(users.length)];
      } while (participant2.id == participant1.id ||
          participant2.id == currentUserId);
      final participants = [participant1, participant2];
      if (!participants.any((user) => user.id == currentUserId)) {
        participants[1] = users.firstWhere((user) => user.id == currentUserId);
      }

      final messages = <Message>[];

      messages.add(
        Message(
          id: faker_pkg.faker.guid.guid(),
          senderId: currentUserId,
          chatId: chatId,
          content: faker_pkg.faker.lorem.sentence(),
          type: 'text',
          createdAt: Helpers.randomDate(),
          isRead: faker_pkg.faker.randomGenerator.boolean(),
        ),
      );

      final additionalMessages = List.generate(
        Random().nextInt(5),
        (_) => Message(
          id: faker_pkg.faker.guid.guid(),
          senderId: participants[Random().nextInt(participants.length)].id,
          chatId: chatId,
          content: faker_pkg.faker.lorem.sentence(),
          type: 'text',
          createdAt: Helpers.randomDate(),
          isRead: faker_pkg.faker.randomGenerator.boolean(),
        ),
      );

      messages.addAll(additionalMessages);

      messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return Chat(id: chatId, participants: participants, messages: messages);
    });

    chats.sort((a, b) {
      final aLatestMessage =
          a.messages.isNotEmpty ? a.messages.last.createdAt : DateTime(1970);
      final bLatestMessage =
          b.messages.isNotEmpty ? b.messages.last.createdAt : DateTime(1970);
      return bLatestMessage.compareTo(aLatestMessage);
    });

    return chats;
  }

  @override
  Widget build(BuildContext context) {
    final sortedChats = _generateSortedChatData();

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: _Stories()),
        SliverList(
          delegate: SliverChildListDelegate(
            sortedChats.map((chat) => _MessageTitle(chat: chat)).toList(),
          ),
        ),
      ],
    );
  }
}

class _MessageTitle extends StatelessWidget {
  const _MessageTitle({required this.chat});

  final Chat chat;
  User _getReceiver() {
    var currentUserId = currentUser.id; // Replace with current userId
    return chat.participants.firstWhere((user) => user.id != currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    final receiver = _getReceiver();
    final latestMessage = chat.messages.isNotEmpty ? chat.messages.last : null;
    final randomNumber = Random().nextInt(5);

    return InkWell(
      onTap: () {
        Navigator.of(context).push(ChatScreen.route(chat));
      },
      child: Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey, width: 0.2),
            bottom: BorderSide(color: Colors.grey, width: 0.2),
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Avatar.medium(
                url: receiver.profileUrl,
                onTap:
                    () => Navigator.of(
                      context,
                    ).push(ProfileScreen.route(receiver)),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Receiver
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      receiver.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        letterSpacing: 0.2,
                        wordSpacing: 1.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  // Message
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      height: 20,
                      child: Text(
                        latestMessage!.content,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              randomNumber != 0
                                  ? AppColors.secondary
                                  : AppColors.textFaded,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Date
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    Jiffy.parse(latestMessage.createdAt.toString()).fromNow(),
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: -0.2,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textFaded,
                    ),
                  ),
                  const SizedBox(height: 8),
                  randomNumber != 0
                      ? Center(
                        child: Material(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.secondary,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 5,
                              right: 5,
                              top: 2,
                              bottom: 1,
                            ),
                            child: Text(
                              '${randomNumber > 99 ? '99+' : randomNumber}',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textLight,
                              ),
                            ),
                          ),
                        ),
                      )
                      : SizedBox(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stories extends StatelessWidget {
  const _Stories();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 0,
      child: SizedBox(
        height: 146,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 8, bottom: 16),
              child: Text(
                'Stories',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: AppColors.textFaded,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: generateDemoStories().length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 60,
                      child: _StoryCard(
                        story: generateDemoStories()[index],
                        index: index,
                        // Story(
                        //   id: faker.guid.guid(),
                        //   caption: faker.lorem.sentence(),
                        //   mediaName: faker.lorem.sentence(),
                        //   type: 'image',
                        //   mediaUrl: Helpers.randomPictureUrl(),
                        //   storyUrl: 'test',
                        //   createdAt: DateTime.now(),
                        //   expiresAt: DateTime.now(),
                        //   userId: '',
                        // ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.story, required this.index});

  final Story story;
  final int index;

  @override
  Widget build(BuildContext context) {
    final user = Helpers.getUserById(story.userId);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Avatar.medium(
          url: user!.profileUrl,
          onTap:
              () => Navigator.of(
                context,
              ).push(StoryScreen.route(generateDemoStories(), index)),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              user.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textFaded,
                fontSize: 11,
                letterSpacing: 0.3,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
