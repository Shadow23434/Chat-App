import 'package:chat_app/chat_app_ui/features/message/data/models/message_model.dart';
import 'package:chat_app/chat_app_ui/features/message/domain/repositories/message_repository.dart';
import 'package:equatable/equatable.dart';

class SendMessageParams extends Equatable {
  final String chatId;
  final String content;
  final String type;
  final String? mediaUrl;

  const SendMessageParams({
    required this.chatId,
    required this.content,
    required this.type,
    this.mediaUrl,
  });

  @override
  List<Object?> get props => [chatId, content, type, mediaUrl];
}

class SendMessage {
  final MessageRepository repository;

  SendMessage(this.repository);

  Future<MessageModel> call(SendMessageParams params) async {
    return await repository.sendMessage(
      chatId: params.chatId,
      content: params.content,
      type: params.type,
      mediaUrl: params.mediaUrl,
    );
  }
}
