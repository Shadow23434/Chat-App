import 'package:chat_app/chat_app_ui/app.dart';
import 'package:chat_app/chat_app_ui/screens/screens.dart';
import 'package:chat_app/chat_app_ui/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/material.dart';

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
  // final authService = AuthService();

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
        // sync backend
        await Navigator.of(
          context,
        ).pushAndRemoveUntil(HomeScreen.route, (Route<dynamic> route) => false);
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
        leading: Padding(padding: const EdgeInsets.only(top: 16, left: 16)),
      ),
      body:
          _loading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.secondary),
              )
              : Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Header(
                        heading: 'Log in to ChatApp',
                        subtitle:
                            'Welcome back! Log in using your social account or email to continue us',
                        crossAxisAlignment: CrossAxisAlignment.center,
                        textAlign: TextAlign.center,
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
                              scale: 1.3,
                              onTap: () {},
                            ),
                            IconImage(
                              src: 'assets/images/google.png',
                              scale: 1.3,
                              onTap: () {},
                            ),
                            IconImage(
                              src: 'assets/images/apple.png',
                              scale: 1.3,
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
                        padding: const EdgeInsets.only(top: 40),
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
