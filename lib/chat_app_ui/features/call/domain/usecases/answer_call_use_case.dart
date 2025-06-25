import 'package:chat_app/chat_app_ui/features/call/domain/repositories/call_repository.dart';

class AnswerCallUseCase {
  final CallRepository repository;

  AnswerCallUseCase({required this.repository});

  Future<void> call(String callId) {
    return repository.answerCall(callId);
  }
}
