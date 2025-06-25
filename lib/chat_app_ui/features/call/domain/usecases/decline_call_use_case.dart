import 'package:chat_app/chat_app_ui/features/call/domain/repositories/call_repository.dart';

class DeclineCallUseCase {
  final CallRepository repository;

  DeclineCallUseCase({required this.repository});

  Future<void> call(String callId) {
    return repository.declineCall(callId);
  }
}
