import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_event.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_state.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/widgets/auth_prompt.dart';
import 'package:chat_app/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LogInScreen extends StatefulWidget {
  // static Route get route =>s
  //     MaterialPageRoute(builder: (context) => const LogInScreen());

  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showErrors = false;

  Future<void> _logIn() async {
    setState(() {
      _showErrors = true;
    });

    if (_emailFormKey.currentState!.validate() &&
        _passwordFormKey.currentState!.validate()) {
      // Call backend
      BlocProvider.of<AuthBloc>(context).add(
        LoginEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
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
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Header(
                heading: 'Log in to ChatApp',
                subtitle:
                    'Welcome back! Log in using your social account or email to continue us',
                crossAxisAlignment: CrossAxisAlignment.center,
                textAlign: TextAlign.center,
              ),
              // Option row
              AuthOptionRow(),
              // Divider
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
              // Input
              InputColumn(
                emailController: _emailController,
                emailFormKey: _emailFormKey,
                showErrors: _showErrors,
                passwordController: _passwordController,
                passwordFormKey: _passwordFormKey,
              ),
              // Button + Prompt
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Button
                    BlocConsumer<AuthBloc, AuthState>(
                      builder: (context, state) {
                        if (state is AuthLoading) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: AppColors.secondary,
                            ),
                          );
                        }
                        return ButtonBackground(
                          onTap: () => _logIn(),
                          string: 'Log in',
                        );
                      },
                      listener: (context, state) {
                        if (state is AuthSuccess) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/home',
                            (route) => false,
                          );
                        } else if (state is AuthFailure) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            customSnackBar(
                              'Auth Error',
                              state.error,
                              Icons.info_outline,
                              AppColors.accent,
                            ),
                          );
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    // Prompt
                    AuthPrompt(
                      title: "Don't have an account?",
                      subtile: 'Sign up',
                      onTap: () => Navigator.pushNamed(context, '/signup'),
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

class AuthOptionRow extends StatelessWidget {
  const AuthOptionRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconImage(
            src: 'assets/images/facebook.png',
            scale: 1.3,
            onTap: () {},
          ),
          IconImage(src: 'assets/images/google.png', scale: 1.3, onTap: () {}),
          IconImage(src: 'assets/images/apple.png', scale: 1.3, onTap: () {}),
        ],
      ),
    );
  }
}

class InputColumn extends StatelessWidget {
  const InputColumn({
    super.key,
    required TextEditingController emailController,
    required GlobalKey<FormState> emailFormKey,
    required bool showErrors,
    required TextEditingController passwordController,
    required GlobalKey<FormState> passwordFormKey,
  }) : _emailController = emailController,
       _emailFormKey = emailFormKey,
       _showErrors = showErrors,
       _passwordController = passwordController,
       _passwordFormKey = passwordFormKey;

  final TextEditingController _emailController;
  final GlobalKey<FormState> _emailFormKey;
  final bool _showErrors;
  final TextEditingController _passwordController;
  final GlobalKey<FormState> _passwordFormKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                Navigator.pushNamed(context, '/forgot-password');
              },
              child: Text(
                'Forgot password?',
                style: TextStyle(color: AppColors.secondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
