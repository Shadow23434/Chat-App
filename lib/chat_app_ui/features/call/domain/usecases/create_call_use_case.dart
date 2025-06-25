import 'package:chat_app/chat_app_ui/features/call/domain/entities/call.dart';
import 'package:chat_app/chat_app_ui/features/call/domain/repositories/call_repository.dart';

class CreateCallUseCase {
  final CallRepository repository;

  CreateCallUseCase({required this.repository});

  Future<CallEntity> call(String participantId, String callType) {
    return repository.createCall(participantId, callType);
  }
}
