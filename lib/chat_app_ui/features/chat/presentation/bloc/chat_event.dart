import 'package:equatable/equatable.dart';
import 'package:chat_app/chat_app_ui/features/chat/domain/entities/chat_entity.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class GetChatsEvent extends ChatEvent {
  final String userId;

  const GetChatsEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class UpdateChatEvent extends ChatEvent {
  final ChatEntity updatedChat;

  const UpdateChatEvent(this.updatedChat);

  @override
  List<Object> get props => [updatedChat];
}

class RefreshChatsEvent extends ChatEvent {
  final String userId;

  const RefreshChatsEvent(this.userId);

  @override
  List<Object> get props => [userId];
}
