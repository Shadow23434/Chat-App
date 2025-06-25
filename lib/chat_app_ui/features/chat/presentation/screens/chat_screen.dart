import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_state.dart';
import 'package:chat_app/chat_app_ui/features/chat/domain/entities/chat_entity.dart';
import 'package:chat_app/chat_app_ui/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:chat_app/chat_app_ui/features/chat/presentation/bloc/chat_event.dart';
import 'package:chat_app/chat_app_ui/features/chat/presentation/bloc/chat_state.dart';
import 'package:chat_app/chat_app_ui/features/contact/presentation/bloc/contact_bloc.dart';
import 'package:chat_app/chat_app_ui/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:chat_app/chat_app_ui/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:chat_app/chat_app_ui/features/profile/domain/usecases/edit_profile_usecase.dart';
import 'package:chat_app/chat_app_ui/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:chat_app/chat_app_ui/features/profile/domain/usecases/search_profile_usecase.dart';
import 'package:chat_app/chat_app_ui/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:chat_app/chat_app_ui/features/story/presentation/bloc/story_bloc.dart';
import 'package:chat_app/chat_app_ui/features/story/presentation/bloc/story_event.dart';
import 'package:chat_app/chat_app_ui/features/story/presentation/bloc/story_state.dart';
import 'package:chat_app/chat_app_ui/features/story/domain/entities/story_entity.dart';
import 'package:chat_app/chat_app_ui/features/story/presentation/screens/story_screen.dart';
import 'package:chat_app/chat_app_ui/screens/screens.dart';
import 'package:chat_app/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jiffy/jiffy.dart';
import 'package:chat_app/core/utils/socket_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:chat_app/chat_app_ui/utils/helpers.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late SocketService socketService;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    socketService = SocketService();

    // Get current user ID
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      currentUserId = authState.user.id;
      print('ChatScreen: Current user ID: $currentUserId');

      // Initialize socket connection for chat list updates
      final socketUrl = dotenv.env['SOCKET_IO_URL'];
      print('ChatScreen: Socket URL: $socketUrl');

      if (socketUrl != null) {
        print('ChatScreen: Connecting to socket...');
        socketService.connect(
          serverUrl: socketUrl,
          chatId: 'chat_list_$currentUserId',
        );

        // Wait for socket to connect before joining rooms and setting up listeners
        socketService.onConnect(() {
          print('ChatScreen: Socket connected, joining user chats room');
          socketService.joinUserChats(currentUserId!);

          // Set up socket listeners for real-time updates
          print('ChatScreen: Setting up socket listeners');
          socketService.onChatUpdate(_onChatUpdate);
          socketService.onNewChat(_onNewChat);
          print('ChatScreen: Socket listeners set up successfully');
        });

        // Also set up listeners immediately in case socket is already connected
        print('ChatScreen: Setting up socket listeners immediately');
        socketService.onChatUpdate(_onChatUpdate);
        socketService.onNewChat(_onNewChat);
      } else {
        print('ChatScreen: ERROR - Socket URL is null!');
      }

      // Dispatch the GetChatsEvent when the page is initialized
      print('ChatScreen: Dispatching GetChatsEvent');
      BlocProvider.of<ChatBloc>(context).add(GetChatsEvent(currentUserId!));
    } else {
      print(
        'ChatScreen: ERROR - Auth state is not AuthSuccess: ${authState.runtimeType}',
      );
    }
  }

  @override
  void dispose() {
    // Clean up socket listeners
    socketService.offChatUpdate(_onChatUpdate);
    socketService.offNewChat(_onNewChat);
    if (currentUserId != null) {
      socketService.leaveUserChats(currentUserId!);
    }
    socketService.disconnect();
    super.dispose();
  }

  void _onChatUpdate(dynamic data) {
    try {
      final chatEntity = ChatEntity.fromJson(data);
      BlocProvider.of<ChatBloc>(context).add(UpdateChatEvent(chatEntity));
    } catch (e) {}
  }

  void _onNewChat(dynamic data) {
    try {
      final chatEntity = ChatEntity.fromJson(data);
      BlocProvider.of<ChatBloc>(context).add(UpdateChatEvent(chatEntity));
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        print('ChatScreen: Building with state: ${state.runtimeType}');

        if (state is ChatLoading) {
          print('ChatScreen: Showing loading state');
          return const Center(
            child: CircularProgressIndicator(color: AppColors.secondary),
          );
        } else if (state is ChatLoaded) {
          final sortedChats = state.chats;
          print(
            'ChatScreen: Showing loaded state with ${sortedChats.length} chats',
          );
          return RefreshIndicator(
            color: AppColors.secondary,
            onRefresh: () async {
              if (currentUserId != null) {
                // Refresh chats
                BlocProvider.of<ChatBloc>(
                  context,
                ).add(RefreshChatsEvent(currentUserId!));

                // Refresh stories
                BlocProvider.of<StoryBloc>(context).add(GetStories());
              }
            },
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: _Stories()),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final chat = sortedChats[index];
                    return _MessageTitle(
                      chat: chat,
                      currentUserId: currentUserId!,
                    );
                  }, childCount: sortedChats.length),
                ),
              ],
            ),
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
  const _MessageTitle({required this.chat, required this.currentUserId});

  final ChatEntity chat;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final latestMessageAt = chat.lastMessageAt;
    final isRead = chat.isRead;

    final bool isUnreadForCurrentUser =
        !isRead && chat.lastMessageSenderId != currentUserId;
    final unreadCount = isUnreadForCurrentUser ? 1 : 0;
    final hasMessage = chat.lastMessage.trim().isNotEmpty;

    return InkWell(
      onTap: () {
        Navigator.of(
          context,
        ).push(MessageScreen.routeWithContactBloc(chat, context));
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
                url: chat.participantProfilePic,
                onTap:
                    () => Navigator.of(context).push(
                      ProfileScreen.routeWithBloc(
                        chat.participantId,
                        contactBloc: context.read<ContactBloc>(),
                      ),
                    ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      chat.participantName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        letterSpacing: 0.2,
                        wordSpacing: 1.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      height: 20,
                      child: Text(
                        chat.lastMessage,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              unreadCount > 0
                                  ? AppColors.secondary
                                  : AppColors.textFaded,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                  if (hasMessage && unreadCount > 0)
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
              child: BlocBuilder<StoryBloc, StoryState>(
                builder: (context, state) {
                  if (state is StoryLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.secondary,
                        strokeWidth: 2,
                      ),
                    );
                  } else if (state is StoriesLoaded) {
                    if (state.stories.isEmpty) {
                      return const Center(
                        child: Text(
                          'No stories available',
                          style: TextStyle(
                            color: AppColors.textFaded,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: state.stories.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _StoryCard(
                          story: state.stories[index],
                          index: index,
                        );
                      },
                    );
                  } else if (state is StoryError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.textFaded,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Error loading stories',
                            style: TextStyle(
                              color: AppColors.textFaded,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const Center(
                    child: Text(
                      'Loading stories...',
                      style: TextStyle(
                        color: AppColors.textFaded,
                        fontSize: 12,
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

  final StoryEntity story;
  final int index;

  @override
  Widget build(BuildContext context) {
    final user = story.user;
    final isExpired = story.expiresAt.isBefore(DateTime.now());

    return GestureDetector(
      onTap: () {
        if (!isExpired) {
          // Navigate to story screen
          Navigator.of(context).push(StoryScreen.route());
        }
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isExpired ? Colors.grey.shade400 : AppColors.secondary,
                  width: 2,
                ),
                gradient:
                    isExpired
                        ? null
                        : const LinearGradient(
                          colors: [AppColors.secondary, AppColors.accent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
              ),
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image:
                        user?.profilePic != null && user!.profilePic!.isNotEmpty
                            ? NetworkImage(user.profilePic!)
                            : const AssetImage('assets/images/app_logo.png')
                                as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user?.username ?? 'Unknown',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textFaded,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            if (isExpired)
              const Text(
                'Expired',
                style: TextStyle(fontSize: 9, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
