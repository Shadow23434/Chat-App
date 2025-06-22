import 'package:chat_app/chat_app_ui/features/message/domain/usecases/get_messages.dart';
import 'package:chat_app/chat_app_ui/features/message/presentation/bloc/message_bloc.dart';
import 'package:chat_app/chat_app_ui/features/message/presentation/widgets/message_input.dart';
import 'package:chat_app/chat_app_ui/features/message/presentation/widgets/message_list.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
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

class MessageScreen extends StatelessWidget {
  static Route route(ChatEntity chatEntity) => MaterialPageRoute(
    builder: (context) => MessageScreen(chatEntity: chatEntity),
  );

  const MessageScreen({super.key, required this.chatEntity});

  final ChatEntity chatEntity;

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
              (context) =>
                  MessageBloc(getMessages: context.read<GetMessages>())
                    ..add(GetMessagesEvent(chatId: chatEntity.id)),
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
                return _AppBarTitle(
                  participantName: chatEntity.participantName,
                  onlineStatus: 'Offline',
                );
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
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is MessageLoaded) {
                    return MessageList(messages: state.messages);
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
                                GetMessagesEvent(chatId: chatEntity.id),
                              );
                            },
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            MessageInput(chatId: chatEntity.id),
          ],
        ),
      ),
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle({
    required this.participantName,
    required this.onlineStatus,
  });

  final String participantName;
  final String onlineStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          participantName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          onlineStatus,
          style: const TextStyle(fontSize: 12, color: Colors.green),
        ),
      ],
    );
  }
}
