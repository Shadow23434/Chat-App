import 'package:chat_app/chat_app_ui/features/auth/domain/repositories/auth_repository.dart';

class VerifyResetTokenUseCase {
  final AuthRepository repository;

  VerifyResetTokenUseCase(this.repository);

  Future<bool> call(String token) async {
    try {
      await repository.resetPasword(token, 'dummy_password');
      return true;
    } catch (e) {
      return false;
    }
  }
}
