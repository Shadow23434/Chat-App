import 'dart:async';
import 'package:chat_app/app.dart';
import 'package:chat_app/helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
import '../theme.dart';
import '../widgets/widgets.dart';
import 'package:collection/collection.dart' show IterableExtension;

class ChatScreen extends StatefulWidget {
  static routeWithChannel(Channel channel) => MaterialPageRoute(
    builder:
        (context) => StreamChannel(channel: channel, child: const ChatScreen()),
  );

  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late StreamSubscription<int> unReadCountSubscription;

  @override
  void initState() {
    super.initState();
    unReadCountSubscription = StreamChannel.of(
      context,
    ).channel.state!.unreadCountStream.listen(_unReadCountHandle);
  }

  Future<void> _unReadCountHandle(int count) async {
    if (count > 0) {
      await StreamChannel.of(context).channel.markRead();
    }
  }

  @override
  void dispose() {
    unReadCountSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        centerTitle: false,
        backgroundColor: Colors.transparent,
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
        title: const _AppBarTitle(),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
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
        children: [
          Expanded(
            child: MessageListCore(
              loadingBuilder: (context) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.secondary),
                );
              },
              emptyBuilder:
                  (context) => const Center(
                    child: Text(
                      'No message. Type anything to start the conversation.',
                      textAlign: TextAlign.center,
                    ),
                  ),
              messageListBuilder:
                  (context, messages) => _MessageList(messages: messages),
              errorBuilder: (context, error) => DisplayErrorMessage(),
            ),
          ),
          const _ActionBar(),
        ],
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({required this.messages});

  final List<Message> messages;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListView.separated(
        itemBuilder: (context, index) {
          if (index < messages.length) {
            final message = messages[index];
            if (message.user?.id == context.currentUser?.id) {
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

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle();

  @override
  Widget build(BuildContext context) {
    final channel = StreamChannel.of(context).channel;

    return Row(
      children: [
        Avatar.small(
          url: Helpers.getChannelImage(channel, context.currentUser!),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Helpers.getChannelName(channel, context.currentUser!),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 2),
              BetterStreamBuilder<List<Member>>(
                stream: channel.state!.membersStream,
                initialData: channel.state!.members,
                builder:
                    (context, data) => ConnectionStatusBuilder(
                      statusBuilder: (context, status) {
                        switch (status) {
                          case ConnectionStatus.connected:
                            return _buildConnectedTitleState(context, data);
                          case ConnectionStatus.connecting:
                            return const Text(
                              'Connecting...',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            );
                          case ConnectionStatus.disconnected:
                            return const Text(
                              'Offline',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            );
                        }
                      },
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConnectedTitleState(
    BuildContext context,
    List<Member>? members,
  ) {
    Widget? alternativeWidget;
    final channel = StreamChannel.of(context).channel;
    final memberCount = channel.memberCount;
    if (memberCount != null && memberCount > 2) {
      var text = 'Members: $memberCount';
      final watcherCount = channel.state?.watcherCount ?? 0;
      if (watcherCount > 0) {
        text = 'watchers: $watcherCount';
      }
      alternativeWidget = Text(text);
    } else {
      final userId = StreamChatCore.of(context).currentUser?.id;
      final otherMember = members?.firstWhereOrNull(
        (element) => element.userId != userId,
      );
      if (otherMember != null) {
        if (otherMember.user?.online == true) {
          alternativeWidget = const Text(
            'Online',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          );
        } else {
          alternativeWidget = Text(
            'Last online: ${Jiffy.parseFromDateTime(otherMember.user?.lastActive ?? DateTime.now()).fromNow()}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          );
        }
      }
    }
    return TypingIndicator(alternativeWidget: alternativeWidget);
  }
}

class ConnectionStatusBuilder extends StatelessWidget {
  const ConnectionStatusBuilder({
    super.key,
    required this.statusBuilder,
    this.connectionStatusStream,
    this.errorBuilder,
    this.loadingBuilder,
  });

  /// The asynchronous computation to which this builder is currently connected.
  final Stream<ConnectionStatus>? connectionStatusStream;

  /// The builder that will be used in case of error
  final Widget Function(BuildContext context, Object? error)? errorBuilder;

  /// The builder that will be used in case of loading
  final WidgetBuilder? loadingBuilder;

  /// The builder that will be used in case of data
  final Widget Function(BuildContext context, ConnectionStatus status)
  statusBuilder;

  @override
  Widget build(BuildContext context) {
    final stream =
        connectionStatusStream ??
        StreamChatCore.of(context).client.wsConnectionStatusStream;
    final client = StreamChatCore.of(context).client;
    return BetterStreamBuilder<ConnectionStatus>(
      initialData: client.wsConnectionStatus,
      stream: stream,
      noDataBuilder: loadingBuilder,
      errorBuilder: (context, error) {
        if (errorBuilder != null) {
          return errorBuilder!(context, error);
        }
        return const Offstage();
      },
      builder: statusBuilder,
    );
  }
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key, this.alternativeWidget});

  final Widget? alternativeWidget;

  @override
  Widget build(BuildContext context) {
    final channelState = StreamChannel.of(context).channel.state!;
    final altWidget = alternativeWidget ?? const SizedBox.shrink();

    return BetterStreamBuilder<Iterable<User>>(
      initialData: channelState.typingEvents.keys,
      stream: channelState.typingEventsStream.map(
        (typing) => typing.entries.map((e) => e.key),
      ),
      builder: (context, data) {
        return Align(
          alignment: Alignment.centerLeft,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child:
                data.isNotEmpty == true
                    ? const Align(
                      alignment: Alignment.centerLeft,
                      key: ValueKey('typing-text'),
                      child: Text(
                        'Typing message',
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    : Align(
                      alignment: Alignment.centerLeft,
                      key: const ValueKey('widget'),
                      child: altWidget,
                    ),
          ),
        );
      },
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
  const _MessageTile({required this.message});

  final Message message;
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
                child: Text(message.text ?? 'Empty message'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
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

class _MessageOwnTile extends StatelessWidget {
  const _MessageOwnTile({required this.message});

  final Message message;
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
                child: Text(message.text ?? 'Empty message'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
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

class _ActionBar extends StatefulWidget {
  const _ActionBar();

  @override
  State<_ActionBar> createState() => __ActionBarState();
}

class __ActionBarState extends State<_ActionBar> {
  final StreamMessageInputController controller =
      StreamMessageInputController();

  Timer? _debounce;

  Future<void> _sendMessage() async {
    if (controller.text.isNotEmpty) {
      StreamChannel.of(context).channel.sendMessage(controller.message);
      controller.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _onTextChange() {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }
    _debounce = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        StreamChannel.of(context).channel.keyStroke();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    controller.removeListener(_onTextChange);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
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
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(CupertinoIcons.camera_fill),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 16),
                child: TextField(
                  controller: controller.textFieldController,
                  onChanged: (val) {
                    controller.text = val;
                  },
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Message',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 24),
              child: GlowingActionButton(
                color: AppColors.secondary,
                icon: Icons.send_rounded,
                size: 46,
                onPressed: () {
                  _sendMessage();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
