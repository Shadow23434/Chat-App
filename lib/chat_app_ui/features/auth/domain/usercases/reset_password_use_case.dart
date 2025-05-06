import 'package:chat_app/chat_app_ui/features/auth/domain/entities/user_entity.dart';
import 'package:chat_app/chat_app_ui/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase({required this.repository});

  Future<UserEntity> call(String token, String password) {
    return repository.resetPasword(token, password);
  }
}
