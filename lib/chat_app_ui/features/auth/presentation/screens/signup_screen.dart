import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_event.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_state.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/widgets/auth_prompt.dart';
import 'package:chat_app/theme.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameFormKey = GlobalKey<FormState>();
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _confirmPasswordFormKey = GlobalKey<FormState>();
  bool _showErrors = false;

  Future<void> _signUp() async {
    setState(() {
      _showErrors = true;
    });

    if (_nameFormKey.currentState!.validate() &&
        _emailFormKey.currentState!.validate() &&
        _passwordFormKey.currentState!.validate() &&
        _confirmPasswordFormKey.currentState!.validate()) {
      // Call backend
      BlocProvider.of<AuthBloc>(context).add(
        RegisterEvent(
          username: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Cannot be empty!';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Header(
                heading: 'Sign up with Email',
                subtitle:
                    'Get chatting with friends and family today by signing up for our chat app!',
                crossAxisAlignment: CrossAxisAlignment.center,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              // Input
              Column(
                children: [
                  InputForm(
                    label: 'Name',
                    controller: _nameController,
                    formKey: _nameFormKey,
                    showErrors: _showErrors,
                  ),
                  SizedBox(height: 12.0),
                  InputForm(
                    label: 'Email',
                    isEmail: true,
                    controller: _emailController,
                    formKey: _emailFormKey,
                    showErrors: _showErrors,
                  ),
                  SizedBox(height: 12.0),
                  InputForm(
                    label: 'Password',
                    isPassword: true,
                    controller: _passwordController,
                    formKey: _passwordFormKey,
                    showErrors: _showErrors,
                  ),
                  SizedBox(height: 12.0),
                  InputForm(
                    label: 'Confirm Password',
                    isPassword: true,
                    controller: _confirmPasswordController,
                    formKey: _confirmPasswordFormKey,
                    showErrors: _showErrors,
                    validator: _confirmPasswordValidator,
                  ),
                ],
              ),
              // Button + Prompt
              Padding(
                padding: const EdgeInsets.only(top: 28),
                child: Column(
                  children: [
                    //Button
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
                          onTap: () => _signUp(),
                          string: 'Create an account',
                        );
                      },
                      listener: (context, state) {
                        if (state is AuthSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            customSnackBar(
                              'Success!',
                              'Check your email inbox!',
                              Icons.check_circle_outline_rounded,
                              Colors.green,
                            ),
                          );
                          Navigator.pushNamed(
                            context,
                            '/verify-email',
                            arguments: {_emailController.text.trim(), false},
                          );
                        } else if (state is AuthFailure) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            customSnackBar(
                              'Error',
                              state.error,
                              Icons.info_outline,
                              AppColors.accent,
                            ),
                          );
                        }
                      },
                    ),
                    SizedBox(height: 16.0),
                    // Prompt
                    AuthPrompt(
                      title: 'You have an account?',
                      subtile: 'Log in',
                      onTap: () => Navigator.pushNamed(context, '/'),
                      // () => Navigator.of(
                      //   context,
                      // ).pushReplacement(LogInScreen.route),
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
