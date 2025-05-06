import 'package:chat_app/chat_app_ui/utils/helpers.dart';
import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/phone_input_formatter.dart';

class InputForm extends StatefulWidget {
  const InputForm({
    super.key,
    required this.label,
    this.value,
    required this.controller,
    required this.formKey,
    required this.showErrors,
    this.validator,
    this.isEmail = false,
    this.isPassword = false,
    this.isPhone = false,
  });

  final bool isEmail;
  final bool isPassword;
  final bool isPhone;
  final String label;
  final String? value;
  final TextEditingController controller;
  final GlobalKey<FormState> formKey;
  final bool showErrors;
  final FormFieldValidator<String?>? validator;

  @override
  State<InputForm> createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {
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

  String? _getErrorText() {
    if (!widget.showErrors) return '';
    if (widget.isEmail) {
      return Helpers.emailInputValidator(widget.controller.text);
    } else if (widget.isPassword) {
      return Helpers.passwordInputValidator(widget.controller.text);
    }
    return Helpers.nameInputValidator(widget.controller.text);
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
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              color:
                  widget.showErrors && !widget.formKey.currentState!.validate()
                      ? AppColors.accent
                      : (_isFocused)
                      ? AppColors.secondary
                      : null,
            ),
          ),
          TextFormField(
            focusNode: _focusNode,
            controller: widget.controller,
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
            obscureText: widget.isPassword && !_isPasswordVisible,
            cursorColor: AppColors.secondary,
            cursorErrorColor:
                widget.showErrors ? AppColors.accent : AppColors.secondary,
            validator: widget.validator ?? _validator(),
            decoration: InputDecoration(
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
              suffixIconColor: Colors.white,
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.secondary),
              ),
              errorBorder:
                  widget.showErrors
                      ? UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.accent,
                          width: 0.8,
                        ),
                      )
                      : UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
              focusedErrorBorder:
                  widget.showErrors
                      ? UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.accent,
                          width: 0.8,
                        ),
                      )
                      : UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.secondary),
                      ),
              errorText: _getErrorText(),
              errorStyle: TextStyle(fontSize: 12, color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}
