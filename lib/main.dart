import 'package:chat_app/admin_panel_ui/admin.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/screens/reset_password_token_screen.dart';
import 'package:chat_app/chat_app_ui/screens/screens.dart';
import 'package:chat_app/chat_app_ui/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:chat_app/chat_app_ui/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:chat_app/chat_app_ui/features/auth/domain/repositories/auth_repository.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/responsive/desktop_scaffold.dart';
import 'package:chat_app/responsive/mobile_scaffold.dart';
import 'package:chat_app/responsive/responsive_layout.dart';
import 'package:chat_app/responsive/tablet_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uni_links/uni_links.dart';
import 'chat_app_ui/features/auth/domain/usercases/usecases.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  final authRepository = AuthRepositoryImpl(
    authRemoteDataSource: AuthRemoteDataSource(),
  );

  WidgetsFlutterBinding.ensureInitialized();

  await _handleInitialDeepLink();
  _setupDeepLinkListener();

  runApp(MyApp(appTheme: AppTheme(), authRepository: authRepository));
}

Future<void> _handleInitialDeepLink() async {
  try {
    final initialUri = await getInitialUri();
    if (initialUri != null) {
      _processDeepLink(initialUri);
    }
  } catch (e) {
    print('Error handling initial deep link: $e');
  }
}

void _setupDeepLinkListener() {
  uriLinkStream.listen(
    (Uri? uri) {
      if (uri != null) {
        _processDeepLink(uri);
      }
    },
    onError: (err) {
      print('Deep link listener error: $err');
    },
  );
}

void _processDeepLink(Uri uri) {
  if (uri.path.startsWith('/reset-password/')) {
    final token = uri.path.split('/reset-password/').last;
    navigatorKey.currentState?.pushNamed('/reset-password', arguments: token);
  }
}

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
        navigatorKey: navigatorKey,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => const LogInScreen());
            case '/login':
              return MaterialPageRoute(builder: (_) => const LogInScreen());
            case '/signup':
              return MaterialPageRoute(builder: (_) => const SignUpScreen());
            case '/home':
              return MaterialPageRoute(builder: (_) => HomeScreen());
            case '/verify-email':
              return MaterialPageRoute(
                builder: (_) => const OtpVerificationScreen(),
              );
            case '/reset-password':
              final token = settings.arguments as String;
              return MaterialPageRoute(
                builder: (_) => ResetPasswordTokenScreen(token: token),
              );
            case '/create-new-password':
              return MaterialPageRoute(
                builder: (_) => const CreateNewPasswordScreen(),
              );
            case '/admin':
              return MaterialPageRoute(
                builder: (_) => Admin(appTheme: appTheme),
              );
            default:
              return MaterialPageRoute(builder: (_) => const NotFoundScreen());
          }
        },
        routes: {
          '/responsive':
              (_) => ResponsiveLayout(
                mobileScafford: MobileScaffold(),
                tabletScafford: TabletScaffold(),
                desktopScafford: DesktopScaffold(),
              ),
        },
      ),
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: const Center(child: Text('The requested page was not found.')),
    );
  }
}
