import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/chat_app_ui/features/message/presentation/bloc/message_bloc.dart';
import 'package:chat_app/chat_app_ui/features/message/data/models/message_model.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';

class MessageInput extends StatefulWidget {
  const MessageInput({super.key, required this.chatId});

  final String chatId;

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onTextChange() {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }
    _debounce = Timer(const Duration(seconds: 1), () {
      // TODO: Implement typing indicator
    });
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      context.read<MessageBloc>().add(
        SendMessageEvent(
          message: MessageModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            chatId: widget.chatId,
            senderId: 'current_user_id', // TODO: Get from AuthBloc
            content: _controller.text,
            type: 'text',
            mediaUrl: '',
            isRead: false,
            createdAt: DateTime.now(),
          ),
        ),
      );
      _controller.clear();
      FocusScope.of(context).unfocus();
    }
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
                padding: const EdgeInsets.only(left: 16),
                child: TextField(
                  controller: _controller,
                  onChanged: (_) => _onTextChange(),
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
                color: Theme.of(context).primaryColor,
                icon: Icons.send_rounded,
                size: 46,
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
