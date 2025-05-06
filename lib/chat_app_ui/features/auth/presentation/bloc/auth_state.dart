abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String message;
  AuthSuccess({required this.message});
}

class AuthFailure extends AuthState {
  final String error;
  AuthFailure({required this.error});
}

class ResetTokenValid extends AuthState {
  final String token;
  ResetTokenValid({required this.token});
}

class ResetTokenInvalid extends AuthState {
  final String error;
  ResetTokenInvalid({required this.error});
}
