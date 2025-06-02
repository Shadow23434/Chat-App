import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_state.dart';
import 'package:chat_app/chat_app_ui/features/chat/domain/entities/chat_entity.dart';
import 'package:chat_app/chat_app_ui/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:chat_app/chat_app_ui/features/chat/presentation/bloc/chat_event.dart';
import 'package:chat_app/chat_app_ui/features/chat/presentation/bloc/chat_state.dart';
import 'package:chat_app/chat_app_ui/models/models.dart';
import 'package:chat_app/chat_app_ui/screens/screens.dart';
import 'package:chat_app/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jiffy/jiffy.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    super.initState();
    // Dispatch the GetChatsEvent when the page is initialized
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      BlocProvider.of<ChatBloc>(context).add(GetChatsEvent(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.secondary),
          );
        } else if (state is ChatLoaded) {
          final sortedChats = state.chats;
          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: _Stories()),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final chat = sortedChats[index];
                  return _MessageTitle(chat: chat);
                }, childCount: sortedChats.length),
              ),
            ],
          );
        } else if (state is ChatError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is ChatInitial) {
          return const Center(
            child: Text('Loading chats...'),
          ); // Initial loading state
        }
        return const Center(
          child: Text('Unknown state'),
        ); // Fallback for any other state
      },
    );
  }
}

class _MessageTitle extends StatelessWidget {
  // Updated to accept ChatEntity
  const _MessageTitle({required this.chat});

  final ChatEntity chat;

  @override
  Widget build(BuildContext context) {
    final latestMessageAt = chat.lastMessageAt;
    final isRead = chat.isRead;

    final unreadCount = isRead ? 0 : 1;

    return InkWell(
      onTap: () {
        // Pass the ChatEntity to ChatScreen
        Navigator.of(context).push(
          MessageScreen.route(chat),
        ); // Assuming ChatScreen can handle a ChatEntity
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
                url:
                    chat.participantProfilePic, // Use participantProfilePic from ChatEntity
                onTap:
                    () => Navigator.of(context).push(
                      ProfileScreen.route(
                        UserModel(
                          id: chat.participantId,
                          username: chat.participantName,
                          email: '',
                          password: '',
                          profilePic: chat.participantProfilePic,
                        ),
                      ),
                    ), // Create a dummy UserModel for ProfileScreen if needed
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Receiver Name
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      chat.participantName, // Use participantName from ChatEntity
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        letterSpacing: 0.2,
                        wordSpacing: 1.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  // Last Message
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      height: 20,
                      child: Text(
                        chat.lastMessage, // Use lastMessage from ChatEntity
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              unreadCount > 0
                                  ? AppColors.secondary
                                  : AppColors.textFaded, // Highlight if unread
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Date and Unread Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 4),
                  if (chat.lastMessageAt != null)
                    Text(
                      Jiffy.parse(chat.lastMessageAt.toString()).fromNow(),
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: -0.2,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textFaded,
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (unreadCount > 0)
                    Center(
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
                            '${unreadCount > 99 ? '99+' : unreadCount}',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textLight,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
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
                itemCount: 0,
                itemBuilder: (BuildContext context, int index) {
                  return const SizedBox.shrink();
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

  final dynamic story;
  final int index;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
