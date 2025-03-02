import 'package:chat_app/auth/auth_service.dart';
import 'package:chat_app/screens/forgot_password_screen.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:chat_app/screens/sign_up_screen.dart';
import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
import '../app.dart';
import '../widgets/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class LogInScreen extends StatefulWidget {
  static Route get route =>
      MaterialPageRoute(builder: (context) => const LogInScreen());

  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _showErrors = false;
  final authService = AuthService();

  Future<void> _logIn() async {
    setState(() {
      _showErrors = true;
    });

    if (_emailFormKey.currentState!.validate() &&
        _passwordFormKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });
      try {
        await authService.logInWithEmailPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        final client = StreamChatCore.of(context).client;
        await client.connectUser(
          User(id: authService.getCurrentUserID()!),
          client.devToken(authService.getCurrentUserID()!).rawValue,
        );

        await Navigator.of(context).pushReplacement(HomeScreen.route);
      } on supabase.AuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          customSnackBar(
            'Opps Error!',
            e.message,
            Icons.info_outline_rounded,
            AppColors.accent,
          ),
        );
        await Navigator.of(context).pushReplacement(LogInScreen.route);
      } catch (e) {
        logger.e('Log in error', error: e);
        ScaffoldMessenger.of(context).showSnackBar(
          customSnackBar(
            'Opps, Error!',
            'An error occurred.',
            Icons.error_outline_rounded,
            AppColors.accent,
          ),
        );
        await Navigator.of(context).pushReplacement(LogInScreen.route);
      }
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(top: 20, left: 20),
          // child: IconNoBorder(icon: Icons.arrow_back_ios_rounded, onTap: () {}),
        ),
      ),
      body:
          _loading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.secondary),
              )
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 28),
                        child: Header(
                          heading: 'Log in to ChatApp',
                          subtitle:
                              'Welcome back! Log in using your social account or email to continue us',
                          crossAxisAlignment: CrossAxisAlignment.center,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 32,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconImage(
                              src: 'assets/images/facebook.png',
                              onTap: () {},
                            ),
                            IconImage(
                              src: 'assets/images/google.png',
                              onTap: () {},
                            ),
                            IconImage(
                              src: 'assets/images/apple.png',
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey,
                              thickness: 0.5,
                              height: 20,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: AppColors.textFaded,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey,
                              thickness: 0.5,
                              height: 20,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 42),
                        child: Column(
                          children: [
                            InputForm(
                              label: 'Email',
                              isEmail: true,
                              controller: _emailController,
                              formKey: _emailFormKey,
                              showErrors: _showErrors,
                            ),
                            SizedBox(height: 16),
                            InputForm(
                              label: 'Password',
                              isPassword: true,
                              controller: _passwordController,
                              formKey: _passwordFormKey,
                              showErrors: _showErrors,
                            ),
                            SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(
                                    context,
                                  ).push(ForgotPasswordScreen.route);
                                },
                                child: Text(
                                  'Forgot password?',
                                  style: TextStyle(color: AppColors.secondary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 80),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ButtonBackground(
                              onTap: () => _logIn(),
                              string: 'Log in',
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Don’t have an account?'),
                                SizedBox(width: 4.0),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(
                                      context,
                                    ).push(SignUpScreen.route);
                                  },
                                  child: Text(
                                    'Sign up',
                                    style: TextStyle(
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
