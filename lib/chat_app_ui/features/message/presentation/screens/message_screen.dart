import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/chat_app_ui/features/chat/domain/entities/chat_entity.dart';

class MessageScreen extends StatelessWidget {
  static Route route(ChatEntity chatEntity) => MaterialPageRoute(
    builder: (context) => MessageScreen(chatEntity: chatEntity),
  );

  const MessageScreen({super.key, required this.chatEntity});

  final ChatEntity chatEntity;

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
        title: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthSuccess) {
              return _AppBarTitle(
                participantName: chatEntity.participantName,
                onlineStatus: 'Offline',
              );
            } else {
              return Text(
                'Loading...',
              ); // Placeholder while loading or not authenticated
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
              child: IconBorder(icon: CupertinoIcons.phone_solid, onTap: () {}),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Chat Screen for ${chatEntity.participantName}'),
            Text('Last message: ${chatEntity.lastMessage}'),
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(onlineStatus, style: TextStyle(fontSize: 12, color: Colors.green)),
      ],
    );
  }
}
