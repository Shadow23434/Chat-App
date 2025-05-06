import 'package:chat_app/chat_app_ui/widgets/widgets.dart';
import 'package:flutter/material.dart';

class AuthInputField extends StatelessWidget {
  final String lable;
  final TextEditingController controller;
  final GlobalKey<FormState> formKey;
  final bool isPassword;
  final bool isEmail;
  final bool showErrors;

  const AuthInputField({
    super.key,
    required this.lable,
    required this.controller,
    required this.formKey,
    required this.isPassword,
    required this.isEmail,
    required this.showErrors,
  });

  @override
  Widget build(BuildContext context) {
    return InputForm(
      label: lable,
      controller: controller,
      formKey: formKey,
      isEmail: isEmail,
      isPassword: isPassword,
      showErrors: showErrors,
    );
  }
}
