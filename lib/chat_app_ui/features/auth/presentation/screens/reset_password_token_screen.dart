import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_event.dart';
import 'package:chat_app/chat_app_ui/features/auth/presentation/bloc/auth_state.dart';
import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResetPasswordTokenScreen extends StatelessWidget {
  final String token;

  const ResetPasswordTokenScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<AuthBloc>(
        context,
      ).add(VerifyResetTokenEvent(token: token));
    });

    return Scaffold(
      appBar: DefaultAppBar(),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ResetTokenValid) {
            Navigator.pushNamed(
              context,
              '/create-new-password',
              arguments: state.token,
            );
          } else if (state is ResetTokenInvalid || state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              customSnackBar(
                'Error',
                state is ResetTokenInvalid
                    ? state.error
                    : (state as AuthFailure).error,
                Icons.error_outline,
                AppColors.accent,
              ),
            );
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return const Center(child: Text('Verifying token...'));
        },
      ),
    );
  }
}
