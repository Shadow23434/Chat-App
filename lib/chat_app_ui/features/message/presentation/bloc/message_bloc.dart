import 'package:chat_app/chat_app_ui/features/message/data/models/message_model.dart';
import 'package:chat_app/chat_app_ui/features/message/domain/usecases/get_messages.dart';
import 'package:chat_app/chat_app_ui/features/message/domain/repositories/message_repository.dart';
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

class AddMessageEvent extends MessageEvent {
  final MessageModel message;

  const AddMessageEvent({required this.message});

  @override
  List<Object> get props => [message];
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
  final MessageRepository repository;

  MessageBloc({required this.getMessages, required this.repository})
    : super(MessageInitial()) {
    on<GetMessagesEvent>(_onGetMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<MarkMessageAsReadEvent>(_onMarkMessageAsRead);
    on<AddMessageEvent>(_onAddMessage);
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
    try {
      await repository.sendMessage(
        chatId: event.message.chatId,
        content: event.message.content,
        type: event.message.type,
        mediaUrl: event.message.mediaUrl,
      );
      // Reload messages after sending
      final messages = await repository.getMessages(event.message.chatId);
      emit(MessageLoaded(messages: messages));
    } catch (e) {
      emit(MessageError(message: 'Failed to send message'));
    }
  }

  Future<void> _onMarkMessageAsRead(
    MarkMessageAsReadEvent event,
    Emitter<MessageState> emit,
  ) async {
    // TODO: Implement mark message as read
  }

  void _onAddMessage(AddMessageEvent event, Emitter<MessageState> emit) {
    if (state is MessageLoaded) {
      final currentMessages = List<MessageModel>.from(
        (state as MessageLoaded).messages,
      );
      currentMessages.insert(0, event.message);
      emit(MessageLoaded(messages: currentMessages));
    }
  }
}
