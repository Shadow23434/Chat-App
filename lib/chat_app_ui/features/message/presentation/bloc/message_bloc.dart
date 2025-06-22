import 'package:chat_app/chat_app_ui/features/message/data/models/message_model.dart';
import 'package:chat_app/chat_app_ui/features/message/domain/usecases/get_messages.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
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

// States
abstract class MessageState extends Equatable {
  const MessageState();

  @override
  List<Object> get props => [];
}

class MessageInitial extends MessageState {}

class MessageLoading extends MessageState {}

class MessageLoaded extends MessageState {
  final List<MessageModel> messages;

  const MessageLoaded({required this.messages});

  @override
  List<Object> get props => [messages];
}

class MessageError extends MessageState {
  final String message;

  const MessageError({required this.message});

  @override
  List<Object> get props => [message];
}

// Bloc
class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final GetMessages getMessages;

  MessageBloc({required this.getMessages}) : super(MessageInitial()) {
    on<GetMessagesEvent>(_onGetMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<MarkMessageAsReadEvent>(_onMarkMessageAsRead);
  }

  Future<void> _onGetMessages(
    GetMessagesEvent event,
    Emitter<MessageState> emit,
  ) async {
    try {
      emit(MessageLoading());
      final messages = await getMessages(event.chatId);
      emit(MessageLoaded(messages: messages));
    } catch (e) {
      emit(MessageError(message: 'Failed to load messages'));
    }
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<MessageState> emit,
  ) async {
    // TODO: Implement send message
  }

  Future<void> _onMarkMessageAsRead(
    MarkMessageAsReadEvent event,
    Emitter<MessageState> emit,
  ) async {
    // TODO: Implement mark message as read
  }
}
