import 'package:chat_app/chat_app_ui/features/message/data/models/message_model.dart';
import 'package:equatable/equatable.dart';

abstract class MessageEvent extends Equatable {
  const MessageEvent();

  @override
  List<Object> get props => [];
}

class GetMessagesEvent extends MessageEvent {
  final String chatId;

  const GetMessagesEvent({required this.chatId});

  @override
  List<Object> get props => [chatId];
}

class SendMessageEvent extends MessageEvent {
  final MessageModel message;

  const SendMessageEvent({required this.message});

  @override
  List<Object> get props => [message];
}

class MarkMessageAsReadEvent extends MessageEvent {
  final String messageId;

  const MarkMessageAsReadEvent({required this.messageId});

  @override
  List<Object> get props => [messageId];
}
