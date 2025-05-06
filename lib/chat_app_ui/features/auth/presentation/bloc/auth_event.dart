abstract class AuthEvent {}

class RegisterEvent extends AuthEvent {
  final String username;
  final String email;
  final String password;

  RegisterEvent({
    required this.username,
    required this.email,
    required this.password,
  });
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});
}

class SignoutEvent extends AuthEvent {
  SignoutEvent();
}

class VerifyEmailEvent extends AuthEvent {
  final String verificationToken;

  VerifyEmailEvent({required this.verificationToken});
}

class ForgotPasswordEvent extends AuthEvent {
  final String email;

  ForgotPasswordEvent({required this.email});
}

class VerifyResetTokenEvent extends AuthEvent {
  final String token;
  VerifyResetTokenEvent({required this.token});
}

class ResetPasswordEvent extends AuthEvent {
  final String token;
  final String newPassword;
  ResetPasswordEvent({required this.token, required this.newPassword});
}
