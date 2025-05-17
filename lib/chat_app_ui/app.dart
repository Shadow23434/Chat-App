import 'package:chat_app/chat_app_ui/features/auth/domain/repositories/auth_repository.dart';
import 'package:chat_app/chat_app_ui/features/auth/domain/usercases/usecases.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/screens/reset_password_token_screen.dart';
import 'package:chat_app/chat_app_ui/screens/screens.dart';
import 'package:chat_app/chat_app_ui/services/context_utility.dart';
import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Main client application widget
class MyApp extends StatelessWidget {
  final AppTheme appTheme;
  final AuthRepository authRepository;

  const MyApp({
    super.key,
    required this.appTheme,
    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (_) => AuthBloc(
                registerUseCase: RegisterUseCase(repository: authRepository),
                loginUseCase: LoginUseCase(repository: authRepository),
                signoutUseCase: SignoutUseCase(repository: authRepository),
                verifyEmailUseCase: VerifyEmailUseCase(
                  repository: authRepository,
                ),
                forgotPasswordUseCase: ForgotPasswordUseCase(
                  repository: authRepository,
                ),
                resetPasswordUseCase: ResetPasswordUseCase(
                  repository: authRepository,
                ),
                verifyResetTokenUseCase: VerifyResetTokenUseCase(
                  authRepository,
                ),
              ),
        ),
      ],
      child: MaterialApp(
        theme: appTheme.light,
        darkTheme: appTheme.dark,
        themeMode: ThemeMode.system,
        title: "Chat App",
        navigatorKey: ContextUtility.navigatorKey,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          // Extract the real path from URL if possible
          final String routeName = settings.name ?? '/';
          final Uri uri = Uri.parse(routeName);
          final String path = uri.path.isEmpty ? '/' : uri.path;

          // Handle client app routes
          switch (path) {
            case '/':
              return MaterialPageRoute(
                builder: (_) => const LogInScreen(),
                settings: settings,
              );
            case '/signup':
              return MaterialPageRoute(
                builder: (_) => const SignUpScreen(),
                settings: settings,
              );
            case '/home':
              return MaterialPageRoute(
                builder: (_) => HomeScreen(),
                settings: settings,
              );
            case '/verify-email':
              return MaterialPageRoute(
                builder: (_) => const OtpVerificationScreen(),
                settings: settings,
              );
            case '/forgot-password':
              return MaterialPageRoute(
                builder: (_) => const ForgotPasswordScreen(),
                settings: settings,
              );
            case '/reset-password':
              // Lấy token từ path hoặc arguments
              String token = '';
              if (settings.arguments != null && settings.arguments is String) {
                token = settings.arguments as String;
              }
              return MaterialPageRoute(
                builder: (_) => ResetPasswordTokenScreen(token: token),
                settings: settings,
              );
            // Xử lý deep link dạng /reset-password/<token>
            default:
              if (path.startsWith('/reset-password/')) {
                String token = '';
                if (uri.pathSegments.length > 1) {
                  token = uri.pathSegments[1];
                }
                return MaterialPageRoute(
                  builder: (_) => ResetPasswordTokenScreen(token: token),
                  settings: settings,
                );
              }
              return MaterialPageRoute(
                builder: (_) => const NotFoundScreen(),
                settings: settings,
              );
          }
        },
      ),
    );
  }
}
