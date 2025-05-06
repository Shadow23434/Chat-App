import 'package:chat_app/chat_app_ui/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register(String username, String email, String password);
  Future<void> signout();
  Future<UserEntity> verifyEmail(String verificationToken);
  Future<void> forgotPassword(String email);
  Future<UserEntity> resetPasword(String token, String password);
}
