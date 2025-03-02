import 'dart:async';
import 'package:chat_app/auth/auth_service.dart';
import 'package:chat_app/helpers.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:chat_app/theme.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class OtpVerificationScreen extends StatefulWidget {
  Route get route => MaterialPageRoute(
    builder: (context) => OtpVerificationScreen(email: email),
  );
  const OtpVerificationScreen({super.key, required this.email, this.name});

  final String email;
  final String? name;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final supabase.SupabaseClient _client = supabase.Supabase.instance.client;
  final authService = AuthService();
  String? _errorMessage;
  int _remainingSeconds = 300;
  late Timer _timer;
  bool _isTimerActive = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _remainingSeconds = 300;
    _isTimerActive = true;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        setState(() {
          _isTimerActive = false;
        });
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _verify() async {
    try {
      final otp = _otpControllers.map((controller) => controller.text).join();
      if (otp.length != 6) {
        setState(() {
          _errorMessage = 'Please enter a 6-digit OTP';
        });
        return;
      }

      await _client.auth.verifyOTP(
        email: widget.email,
        token: otp,
        type: supabase.OtpType.signup,
      );

      final client = StreamChatCore.of(context).client;
      await client.connectUser(
        User(id: authService.getCurrentUserID()!, name: widget.name),
        client.devToken(authService.getCurrentUserID()!).rawValue,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        customSnackBar(
          'Success!',
          'Email verified successfully.',
          Icons.check_circle_outline_rounded,
          Colors.green,
        ),
      );

      await Navigator.of(context).pushReplacement(HomeScreen.route);
    } on supabase.AuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
    }

    if (_errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackBar(
          'Opps error!',
          _errorMessage!,
          Icons.info_outline_rounded,
          AppColors.accent,
        ),
      );
    }
  }

  Future<void> _resend() async {
    try {
      _errorMessage = null;
      await _client.auth.resend(
        email: widget.email,
        type: supabase.OtpType.signup,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        customSnackBar(
          'Success!',
          'New OTP sent. Check your email.',
          Icons.check_circle_outline_rounded,
          Colors.green,
        ),
      );

      _startTimer();

      for (var controller in _otpControllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    } on supabase.AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to resend OTP';
      });
    }

    if (_errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackBar(
          'Opps error!',
          _errorMessage!,
          Icons.info_outline_rounded,
          AppColors.accent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(top: 20, left: 20),
          child: IconNoBorder(
            icon: Icons.arrow_back_ios_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 36),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Header(
                  heading: 'Check your email',
                  subtitle:
                      'We sent a reset link to ${widget.email}. Enter 6 digit code that mentioned in your email.',
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    return Container(
                      width: 40,
                      height: 40,
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        cursorColor: AppColors.secondary,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.secondary,
                              width: 2,
                            ),
                          ),
                        ),
                        style: TextStyle(fontSize: 16),
                        onChanged: (value) {
                          if (value.length == 1 && index < 5) {
                            _focusNodes[index].unfocus();
                            FocusScope.of(
                              context,
                            ).requestFocus(_focusNodes[index + 1]);
                          } else if (value.isEmpty && index > 0) {
                            _focusNodes[index].unfocus();
                            FocusScope.of(
                              context,
                            ).requestFocus(_focusNodes[index - 1]);
                          }
                        },
                      ),
                    );
                  }),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 36),
                  child: Column(
                    children: [
                      ButtonBackground(
                        onTap: () => _verify(),
                        string: 'Verify',
                      ),
                      SizedBox(height: 16.0),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Haven\'t got the email yet?'),
                          SizedBox(width: 4.0),
                          GestureDetector(
                            onTap: () {
                              _resend();
                            },
                            child: Text(
                              'Resend email',
                              style: TextStyle(color: AppColors.secondary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                Text(
                  _isTimerActive
                      ? 'OTP expired in: ${Helpers.formatTimer(_remainingSeconds)}'
                      : 'OTP expired!',
                  style: TextStyle(
                    color: _isTimerActive ? null : AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
