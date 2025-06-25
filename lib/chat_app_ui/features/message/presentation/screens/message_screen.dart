import 'package:chat_app/chat_app_ui/features/contact/presentation/bloc/contact_bloc.dart';
import 'package:chat_app/chat_app_ui/features/message/domain/usecases/get_messages.dart';
import 'package:chat_app/chat_app_ui/features/message/presentation/bloc/message_bloc.dart';
import 'package:chat_app/chat_app_ui/features/message/presentation/widgets/message_input.dart';
import 'package:chat_app/chat_app_ui/features/message/presentation/widgets/message_list.dart';
import 'package:chat_app/chat_app_ui/screens/screens.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:chat_app/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/chat_app_ui/features/chat/domain/entities/chat_entity.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/chat_app_ui/features/message/domain/repositories/message_repository.dart';
import 'package:chat_app/chat_app_ui/features/message/data/repositories/message_repository_impl.dart';
import 'package:chat_app/chat_app_ui/features/message/data/datasources/message_remote_data_source.dart';

class MessageScreen extends StatefulWidget {
  static Route route(ChatEntity chatEntity) => MaterialPageRoute(
    builder: (context) => MessageScreen(chatEntity: chatEntity),
  );

  static Route routeWithContactBloc(
    ChatEntity chatEntity,
    BuildContext parentContext,
  ) => MaterialPageRoute(
    builder:
        (context) => BlocProvider.value(
          value: parentContext.read<ContactBloc>(),
          child: MessageScreen(chatEntity: chatEntity),
        ),
  );

  const MessageScreen({super.key, required this.chatEntity});
  final ChatEntity chatEntity;

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<MessageRemoteDataSource>(
          create: (context) => MessageRemoteDataSourceImpl(),
        ),
        Provider<MessageRepository>(
          create:
              (context) => MessageRepositoryImpl(
                remoteDataSource: context.read<MessageRemoteDataSource>(),
              ),
        ),
        Provider<GetMessages>(
          create: (context) => GetMessages(context.read<MessageRepository>()),
        ),
        BlocProvider(
          create:
              (context) => MessageBloc(
                getMessages: context.read<GetMessages>(),
                repository: context.read<MessageRepository>(),
              )..add(GetMessagesEvent(chatId: widget.chatEntity.id)),
        ),
      ],
      child: Scaffold(
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
          title: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthSuccess) {
                return _AppBarTitle(chatEntity: widget.chatEntity);
              } else {
                return const Text('Loading...');
              }
            },
          ),
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
                child: IconBorder(
                  icon: CupertinoIcons.phone_solid,
                  onTap: () {},
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<MessageBloc, MessageState>(
                builder: (context, state) {
                  if (state is MessageLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.secondary,
                      ),
                    );
                  } else if (state is MessageLoaded) {
                    if (state.messages.isEmpty) {
                      return Center(
                        child: Text(
                          'No messages yet.',
                          style: TextStyle(
                            color: Theme.of(context).hintColor,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }
                    return MessageList(
                      messages: state.messages,
                      chatEntity: widget.chatEntity,
                    );
                  } else if (state is MessageError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<MessageBloc>().add(
                                GetMessagesEvent(chatId: widget.chatEntity.id),
                              );
                            },
                            child: const Text('Try again'),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            MessageInput(chatId: widget.chatEntity.id),
          ],
        ),
      ),
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle({required this.chatEntity});

  final ChatEntity chatEntity;

  bool _isOnline(DateTime? lastLogin) {
    if (lastLogin == null) return false;
    final now = DateTime.now();
    return now.difference(lastLogin).inMinutes < 2;
  }

  String _lastSeenText(DateTime? lastLogin) {
    if (lastLogin == null) return 'Offline';
    final now = DateTime.now();
    final diff = now.difference(lastLogin);
    if (diff.inMinutes < 2) return 'Online';
    if (diff.inMinutes < 60) return 'Last login ${diff.inMinutes} min ago';
    if (diff.inHours < 24) return 'Last login ${diff.inHours} hr ago';
    return 'Last login on ${lastLogin.day}/${lastLogin.month}/${lastLogin.year}';
  }

  @override
  Widget build(BuildContext context) {
    final lastLogin = chatEntity.participantLastLogin;
    final isOnline = _isOnline(lastLogin);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Avatar.small(
          url: chatEntity.participantProfilePic,
          onTap:
              () => Navigator.of(context).push(
                ProfileScreen.routeWithBloc(
                  chatEntity.participantId,
                  contactBloc: context.read<ContactBloc>(),
                ),
              ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text(chatEntity.participantName),
                      content: Text(_lastSeenText(lastLogin)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  chatEntity.participantName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _lastSeenText(lastLogin),
                  style: TextStyle(
                    fontSize: 12,
                    color: isOnline ? Colors.green : AppColors.textFaded,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
