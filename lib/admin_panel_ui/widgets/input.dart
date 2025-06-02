import 'package:chat_app/chat_app_ui/utils/helpers.dart';
import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class Input extends StatefulWidget {
  const Input({
    super.key,
    required this.lable,
    this.value,
    required this.icon,
    required this.controller,
    required this.formkey,
    this.validator,
    required this.showErrors,
    this.isEmail = false,
    this.isPassword = false,
    this.isPhone = false,
  });

  final String lable;
  final String? value;
  final IconData icon;
  final TextEditingController controller;
  final GlobalKey<FormState> formkey;
  final FormFieldValidator<String?>? validator;
  final bool showErrors;
  final bool isEmail;
  final bool isPassword;
  final bool isPhone;

  @override
  _InputState createState() => _InputState();
}

class _InputState extends State<Input> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    if (widget.value != null) {
      widget.controller.text = widget.value!;
    }
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  FormFieldValidator<String?>? _validator() {
    if (widget.isEmail) {
      return Helpers.emailInputValidator;
    } else if (widget.isPassword) {
      return Helpers.passwordInputValidator;
    }
    return Helpers.nameInputValidator;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formkey,
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        validator: widget.validator ?? _validator(),
        keyboardType: widget.isPhone ? TextInputType.phone : null,
        inputFormatters:
            widget.isPhone
                ? [
                  PhoneInputFormatter(
                    allowEndlessPhone: false,
                    defaultCountryCode: 'US',
                  ),
                ]
                : null,
        obscureText: widget.isPassword ? !_isPasswordVisible : false,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.secondary),
          ),
          filled: true,
          fillColor: AppColors.cardView,
          label: Text(
            widget.lable,
            style: TextStyle(
              color: (_isFocused) ? Colors.white : AppColors.textFaded,
            ),
          ),
          hintStyle: TextStyle(color: AppColors.textFaded),
          prefixIcon: Icon(widget.icon, color: AppColors.textFaded),
          suffixIcon:
              widget.isPassword
                  ? IconButton(
                    onPressed:
                        () => setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        }),
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  )
                  : null,
        ),
      ),
    );
  }
}
