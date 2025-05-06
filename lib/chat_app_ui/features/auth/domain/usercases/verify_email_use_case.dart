import 'package:chat_app/chat_app_ui/features/auth/domain/entities/user_entity.dart';
import 'package:chat_app/chat_app_ui/features/auth/domain/repositories/auth_repository.dart';

class VerifyEmailUseCase {
  final AuthRepository repository;

  VerifyEmailUseCase({required this.repository});

  Future<UserEntity> call(String verificationToken) {
    return repository.verifyEmail(verificationToken);
  }
}
