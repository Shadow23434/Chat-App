import 'package:chat_app/chat_app_ui/features/chat/domain/entities/chat_entity.dart';
import 'package:chat_app/chat_app_ui/screens/screens.dart' show ProfileScreen;
import 'package:chat_app/chat_app_ui/widgets/avatar.dart';
import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/chat_app_ui/features/message/data/models/message_model.dart';
import 'package:jiffy/jiffy.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:chat_app/chat_app_ui/features/contact/presentation/bloc/contact_bloc.dart';

class MessageList extends StatelessWidget {
  const MessageList({
    super.key,
    required this.messages,
    required this.chatEntity,
  });

  final List<MessageModel> messages;
  final ChatEntity chatEntity;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final currentUserId = authState is AuthSuccess ? authState.user.id : null;
    if (currentUserId == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.secondary),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListView.separated(
        itemBuilder: (context, index) {
          if (index < messages.length) {
            final message = messages[index];
            if (message.senderId == currentUserId) {
              return _MessageOwnTile(message: message);
            } else {
              return _MessageTile(message: message, chatEntity: chatEntity);
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
                color: AppColors.textFaded,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.message, required this.chatEntity});

  final MessageModel message;
  final ChatEntity chatEntity;
  static const _borderRadius = 26.0;

  @override
  Widget build(BuildContext context) {
    Widget contentWidget;
    if (message.type == 'image' && message.mediaUrl.isNotEmpty) {
      contentWidget = Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 180,
            height: 180,
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                message.mediaUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 80),
              ),
            ),
          ),
        ),
      );
    } else if (message.type == 'audio' && message.mediaUrl.isNotEmpty) {
      contentWidget = _AudioPlayerWidget(url: message.mediaUrl, isOwn: false);
    } else {
      contentWidget = Container(
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
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.bottomLeft,
            child: Avatar.small(
              url: chatEntity.participantProfilePic,
              onTap:
                  () => Navigator.of(context).push(
                    ProfileScreen.routeWithBloc(
                      chatEntity.participantId,
                      contactBloc: context.read<ContactBloc>(),
                    ),
                  ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  contentWidget,
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      Jiffy.parse(message.createdAt.toLocal().toString()).jm,
                      style: TextStyle(
                        color: AppColors.textFaded,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
    Widget contentWidget;
    if (message.type == 'image' && message.mediaUrl.isNotEmpty) {
      contentWidget = Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            message.mediaUrl,
            width: 220,
            height: 220,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 80),
          ),
        ),
      );
    } else if (message.type == 'audio' && message.mediaUrl.isNotEmpty) {
      contentWidget = _AudioPlayerWidget(url: message.mediaUrl, isOwn: true);
    } else {
      contentWidget = Container(
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
          child: Text(
            message.content,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            contentWidget,
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                Jiffy.parse(message.createdAt.toLocal().toString()).jm,
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

class _AudioPlayerWidget extends StatefulWidget {
  final String url;
  final bool isOwn;
  const _AudioPlayerWidget({required this.url, required this.isOwn});

  @override
  State<_AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<_AudioPlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onDurationChanged.listen((d) {
      setState(() => _duration = d);
    });
    _audioPlayer.onPositionChanged.listen((p) {
      setState(() => _position = p);
    });
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      await _audioPlayer.play(UrlSource(widget.url));
      setState(() => _isPlaying = true);
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isOwn ? Colors.white : AppColors.textFaded;
    final bgColor =
        widget.isOwn ? AppColors.secondary : Theme.of(context).cardColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: color,
              size: 36,
            ),
            onPressed: _togglePlay,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 7,
                    ),
                  ),
                  child: Slider(
                    value: _position.inMilliseconds.toDouble().clamp(
                      0,
                      _duration.inMilliseconds.toDouble(),
                    ),
                    min: 0,
                    max:
                        _duration.inMilliseconds.toDouble() > 0
                            ? _duration.inMilliseconds.toDouble()
                            : 1,
                    onChanged: (value) async {
                      final seek = Duration(milliseconds: value.toInt());
                      await _audioPlayer.seek(seek);
                    },
                    activeColor: color,
                    inactiveColor: color.withOpacity(0.3),
                    thumbColor: color,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: TextStyle(fontSize: 12, color: color),
                    ),
                    Text(
                      _formatDuration(_duration),
                      style: TextStyle(fontSize: 12, color: color),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
