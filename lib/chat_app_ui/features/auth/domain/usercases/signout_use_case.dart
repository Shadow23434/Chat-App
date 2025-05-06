import 'package:chat_app/chat_app_ui/features/auth/domain/repositories/auth_repository.dart';

class SignoutUseCase {
  final AuthRepository repository;

  SignoutUseCase({required this.repository});

  Future<void> call() {
    return repository.signout();
  }
}
