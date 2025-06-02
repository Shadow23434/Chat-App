import 'package:equatable/equatable.dart';

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
