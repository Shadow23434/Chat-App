import 'package:chat_app/chat_app_ui/features/call/domain/entities/call.dart';
import 'package:chat_app/chat_app_ui/features/call/domain/repositories/call_repository.dart';

class GetCallsUseCase {
  final CallRepository repository;

  GetCallsUseCase({required this.repository});

  Future<List<CallEntity>> call() {
    return repository.getCalls();
  }
}
