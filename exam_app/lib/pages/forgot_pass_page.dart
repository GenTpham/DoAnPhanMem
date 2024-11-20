import 'dart:async';

import 'package:exam_app/components/my_text_field.dart';
import 'package:exam_app/pages/change_pass_page.dart';
import 'package:exam_app/services/auth/otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class ForgotPassPage extends StatefulWidget {
  const ForgotPassPage({super.key});

  @override
  State<ForgotPassPage> createState() => _ForgotPassPageState();
}

class _ForgotPassPageState extends State<ForgotPassPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  String? otpValue;
  Color emailFieldColor = Colors.blue.withOpacity(.5);
  Color otpFieldColor = Colors.blue.withOpacity(.5);
  int _seconds = 0;
  Timer? _timer;
  void startTimer() {
    _seconds = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future passWordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              content: Text('Đã gửi link đổi mật khẩu! Xem tại Email của bạn'),
            );
          });
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          });
    }
  }

  bool isValidEmail(String email) {
    final RegExp emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  bool isValidOTP(String otp) {
    if (otp.length != 6) return false;
    for (int i = 0; i < otp.length; i++) {
      if (!isDigit(otp[i])) return false;
    }
    return true;
  }

  bool isDigit(String char) {
    return RegExp(r'^[0-9]$').hasMatch(char);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Center(child: Text("Quên mật khẩu")),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/logo.png",
                    width: 250,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  MyTextField(
                    controller: emailController,
                    hintText: "Email",
                    obscureText: false,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  MyTextField(
                    controller: otpController,
                    hintText: "Mã OTP",
                    obscureText: false,
                  ),
                  TextButton(
                    onPressed: _seconds == 0
                        ? () async {
                            String? generateOTP =
                                await getOTP(emailController.text);
                            if (generateOTP != null) {
                              setState(() {
                                otpValue = generateOTP;
                              });
                              startTimer();
                            }
                          }
                        : null,
                    child: Text(
                      _seconds > 0 ? '$_seconds giây' : "Lấy mã",
                      style: TextStyle(
                        fontSize: 20,
                        color: _seconds == 0
                            ? Theme.of(context).colorScheme.onPrimary
                            : Colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    width: 200,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.blue),
                        foregroundColor: WidgetStateProperty.all(Colors.blue),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (!isValidEmail(emailController.text.trim())) {
                            setState(() {
                              emailFieldColor = Colors.red.withOpacity(.5);
                            });
                            return;
                          }

                          if (otpController.text.isEmpty ||
                              otpValue != otpController.text) {
                            setState(() {
                              otpFieldColor = Colors.red.withOpacity(.5);
                            });
                            return;
                          }

                          // Gửi yêu cầu reset mật khẩu nếu email và OTP đều hợp lệ
                          passWordReset();
                        }
                      },
                      child: Text(
                        "Xác nhận",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
