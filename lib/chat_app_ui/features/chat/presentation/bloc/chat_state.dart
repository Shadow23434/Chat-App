import 'package:chat_app/chat_app_ui/features/chat/domain/entities/chat_entity.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatEntity> chats;

  ChatLoaded(this.chats);
}

class ChatError extends ChatState {
  final String message;

  ChatError(this.message);
}
