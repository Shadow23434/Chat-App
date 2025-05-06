import 'dart:async';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_event.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_state.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static Route get route =>
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen());

  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _emailFormKey = GlobalKey<FormState>();
  bool _showErrors = false;

  Future<void> _send() async {
    setState(() {
      _showErrors = true;
    });

    if (_emailFormKey.currentState!.validate()) {
      // Call backend
      BlocProvider.of<AuthBloc>(
        context,
      ).add(ForgotPasswordEvent(email: _emailController.text.trim()));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Header(
                heading: 'Forgot password',
                subtitle:
                    'Please enter your email to reset the password. We will send a reset link to your email',
                crossAxisAlignment: CrossAxisAlignment.start,
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 16),
              InputForm(
                label: 'Email',
                isEmail: true,
                controller: _emailController,
                formKey: _emailFormKey,
                showErrors: _showErrors,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 36),
                child: BlocConsumer<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.secondary,
                        ),
                      );
                    }
                    return ButtonBackground(
                      onTap: () => _send(),
                      string: 'Send',
                    );
                  },
                  listener: (context, state) {
                    if (state is AuthSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        customSnackBar(
                          'Success!',
                          'A reset link sent. Check your email.',
                          Icons.check_circle_outline_rounded,
                          Colors.green,
                        ),
                      );
                      Navigator.pushNamed(context, '/login');
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
