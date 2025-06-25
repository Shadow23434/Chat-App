import 'package:chat_app/chat_app_ui/features/call/domain/repositories/call_repository.dart';

class EndCallUseCase {
  final CallRepository repository;

  EndCallUseCase({required this.repository});

  Future<void> call(String callId, String status) {
    return repository.endCall(callId, status);
  }
}
