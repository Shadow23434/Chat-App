import 'package:chat_app/chat_app_ui/features/auth/domain/usercases/forgot_password_use_case.dart';
import 'package:chat_app/chat_app_ui/features/auth/domain/usercases/reset_password_use_case.dart';
import 'package:chat_app/chat_app_ui/features/auth/domain/usercases/verify_email_use_case.dart';
import 'package:chat_app/chat_app_ui/features/auth/domain/usercases/login_use_case.dart';
import 'package:chat_app/chat_app_ui/features/auth/domain/usercases/register_use_case.dart';
import 'package:chat_app/chat_app_ui/features/auth/domain/usercases/signout_use_case.dart';
import 'package:chat_app/chat_app_ui/features/auth/domain/usercases/verify_reset_token_use_case.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_event.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUseCase registerUseCase;
  final LoginUseCase loginUseCase;
  final SignoutUseCase signoutUseCase;
  final VerifyEmailUseCase verifyEmailUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final VerifyResetTokenUseCase verifyResetTokenUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final _storage = FlutterSecureStorage();

  AuthBloc({
    required this.registerUseCase,
    required this.loginUseCase,
    required this.signoutUseCase,
    required this.verifyEmailUseCase,
    required this.forgotPasswordUseCase,
    required this.verifyResetTokenUseCase,
    required this.resetPasswordUseCase,
  }) : super(AuthInitial()) {
    on<RegisterEvent>(_onRegister);
    on<LoginEvent>(_onLogin);
    on<SignoutEvent>(_onSignout);
    on<VerifyEmailEvent>(_onVerifyEmail);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<VerifyResetTokenEvent>(_onVerifyResetToken);
    on<ResetPasswordEvent>(_onResetPassword);
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await registerUseCase.call(
        event.username,
        event.email,
        event.password,
      );
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure(error: 'Registration failed'));
      print(e.toString());
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await loginUseCase.call(event.email, event.password);
      await _storage.write(key: 'token', value: user.token);
      print(user.email);
      emit(AuthSuccess(message: 'Login successful', user: user));
    } catch (e) {
      emit(AuthFailure(error: 'Login failed'));
      print(e.toString());
    }
  }

  Future<void> _onSignout(SignoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _storage.delete(key: 'token');

      emit(AuthSignedOut());
    } catch (e) {
      emit(AuthFailure(error: 'Sign out failed'));
    }
  }

  Future<void> _onVerifyEmail(
    VerifyEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await verifyEmailUseCase.call(event.verificationToken);

      emit(EmailVerificationSuccess());
    } catch (e) {
      emit(AuthFailure(error: 'Verify email failed'));
      print(e.toString());
    }
  }

  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await forgotPasswordUseCase.call(event.email);

      emit(
        ForgotPasswordSuccess(message: 'Forgot password request successful'),
      );
    } catch (e) {
      emit(AuthFailure(error: 'Forgot password request failed'));
      print(e.toString());
    }
  }

  Future<void> _onVerifyResetToken(
    VerifyResetTokenEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final isValid = await verifyResetTokenUseCase.call(event.token);

      if (isValid) {
        emit(ResetTokenValid(token: event.token));
      } else {
        emit(ResetTokenInvalid(error: 'Invalid or expired token'));
      }
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await resetPasswordUseCase.call(event.token, event.newPassword);

      emit(ResetPasswordSuccess(message: 'Password reset successfully'));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }
}
