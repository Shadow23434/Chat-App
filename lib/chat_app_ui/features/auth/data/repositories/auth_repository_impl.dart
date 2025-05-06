import 'package:chat_app/chat_app_ui/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:chat_app/chat_app_ui/features/auth/domain/entities/user_entity.dart';
import 'package:chat_app/chat_app_ui/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;

  AuthRepositoryImpl({required this.authRemoteDataSource});

  @override
  Future<UserEntity> login(String email, String password) async {
    return await authRemoteDataSource.login(email: email, password: password);
  }

  @override
  Future<UserEntity> register(
    String username,
    String email,
    String password,
  ) async {
    return await authRemoteDataSource.signup(
      username: username,
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signout() {
    return authRemoteDataSource.signout();
  }

  @override
  Future<UserEntity> verifyEmail(String verificationToken) {
    return authRemoteDataSource.verifyEmail(
      verificationToken: verificationToken,
    );
  }

  @override
  Future<void> forgotPassword(String email) {
    return authRemoteDataSource.forgotPassword(email: email);
  }

  @override
  Future<UserEntity> resetPasword(String token, String password) {
    return authRemoteDataSource.resetPassword(token: token, password: password);
  }
}
