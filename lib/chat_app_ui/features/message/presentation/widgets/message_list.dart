import 'package:flutter/material.dart';
import 'package:chat_app/chat_app_ui/features/message/data/models/message_model.dart';
import 'package:jiffy/jiffy.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessageList extends StatelessWidget {
  const MessageList({super.key, required this.messages});

  final List<MessageModel> messages;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListView.separated(
        itemBuilder: (context, index) {
          if (index < messages.length) {
            final message = messages[index];
            final authState = context.read<AuthBloc>().state;
            final currentUserId =
                authState is AuthSuccess ? authState.user.id : null;
            if (message.senderId == currentUserId) {
              return _MessageOwnTile(message: message);
            } else {
              return _MessageTile(message: message);
            }
          } else {
            return const SizedBox.shrink();
          }
        },
        separatorBuilder: (context, index) {
          if (index == messages.length - 1) {
            return _DateLabel(dateTime: messages[index].createdAt);
          }
          if (messages.length == 1) {
            return const SizedBox.shrink();
          } else if (index >= messages.length - 1) {
            return const SizedBox.shrink();
          } else if (index <= messages.length) {
            final message = messages[index];
            final nextMessage = messages[index + 1];
            if (!Jiffy.parseFromDateTime(message.createdAt.toLocal()).isSame(
              Jiffy.parseFromDateTime(nextMessage.createdAt.toLocal()),
              unit: Unit.day,
            )) {
              return _DateLabel(dateTime: message.createdAt.toLocal());
            } else {
              return const SizedBox.shrink();
            }
          } else {
            return const SizedBox.shrink();
          }
        },
        itemCount: messages.length + 1,
        reverse: true,
      ),
    );
  }
}

class _DateLabel extends StatefulWidget {
  const _DateLabel({required this.dateTime});

  final DateTime dateTime;

  @override
  State<_DateLabel> createState() => __DateLabelState();
}

class __DateLabelState extends State<_DateLabel> {
  late String dayInfo;

  @override
  void initState() {
    super.initState();
    final createdAt = Jiffy.parseFromDateTime(widget.dateTime);
    final now = DateTime.now();

    if (createdAt.isSame(Jiffy.parseFromDateTime(now), unit: Unit.day)) {
      dayInfo = 'Today';
    } else if (createdAt.isSame(
      Jiffy.parseFromDateTime(now.subtract(const Duration(days: 1))),
      unit: Unit.day,
    )) {
      dayInfo = 'Yesterday';
    } else if (createdAt.isAfter(
      Jiffy.parseFromDateTime(now.subtract(const Duration(days: 7))),
      unit: Unit.day,
    )) {
      dayInfo = createdAt.EEEE;
    } else if (createdAt.isAfter(
      Jiffy.parseFromDateTime(now).subtract(years: 1),
      unit: Unit.day,
    )) {
      dayInfo = createdAt.MMMd;
    } else {
      dayInfo = createdAt.yMMMd;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Text(
              dayInfo,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.message});

  final MessageModel message;
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
                child: Text(message.content),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                Jiffy.parse(message.createdAt.toLocal().toString()).jm,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
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
  const _MessageOwnTile({required this.message});

  final MessageModel message;
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
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(_borderRadius),
                  bottomRight: Radius.circular(_borderRadius),
                  bottomLeft: Radius.circular(_borderRadius),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  message.content,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                Jiffy.parse(message.createdAt.toLocal().toString()).jm,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
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
