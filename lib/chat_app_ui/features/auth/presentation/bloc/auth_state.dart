import 'package:chat_app/chat_app_ui/features/auth/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String message;
  final UserEntity user;
  const AuthSuccess({required this.message, required this.user});

  @override
  List<Object> get props => [message, user];
}

class AuthFailure extends AuthState {
  final String error;
  const AuthFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class ResetTokenValid extends AuthState {
  final String token;
  const ResetTokenValid({required this.token});

  @override
  List<Object> get props => [token];
}

class ResetTokenInvalid extends AuthState {
  final String error;
  const ResetTokenInvalid({required this.error});

  @override
  List<Object> get props => [error];
}

class ForgotPasswordSuccess extends AuthState {
  final String message;
  const ForgotPasswordSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class ResetPasswordSuccess extends AuthState {
  final String message;
  const ResetPasswordSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class EmailVerificationSuccess extends AuthState {
  const EmailVerificationSuccess();
}

class AuthSignedOut extends AuthState {
  const AuthSignedOut();
}
