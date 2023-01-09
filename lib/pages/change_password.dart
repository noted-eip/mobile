import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:noted_mobile/utils/theme_helper.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final List<bool> _obscureText = [true, true];

  void resetButton(RoundedLoadingButtonController controller) async {
    Timer(const Duration(seconds: 3), () {
      controller.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final RoundedLoadingButtonController btnController =
        RoundedLoadingButtonController();

    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: SafeArea(
            child: Container(
              margin: const EdgeInsets.fromLTRB(32, 0, 32, 0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(width: 5, color: Colors.white),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 20,
                          offset: Offset(5, 5),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.key, size: 80, color: Colors.black),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    alignment: Alignment.topLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Create a New Password',
                          style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Enter a new password for your account.',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Password must be at least 8 characters long.',
                          style: TextStyle(
                            color: Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Container(
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                          child: TextFormField(
                            controller: passwordController,
                            obscureText: _obscureText[0],
                            decoration: ThemeHelper()
                                .textInputDecoration(
                                    'Password', 'Enter your password')
                                .copyWith(
                                  prefixIcon: const Icon(
                                      Icons.lock_outline_rounded,
                                      color: Colors.grey),
                                  suffixIcon: IconButton(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    icon: Icon(
                                      _obscureText[0]
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureText[0] = !_obscureText[0];
                                      });
                                    },
                                  ),
                                ),
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        Container(
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                          child: TextFormField(
                            controller: confirmPasswordController,
                            obscureText: _obscureText[1],
                            decoration: ThemeHelper()
                                .textInputDecoration('Confirm Password',
                                    'Confirm your new password')
                                .copyWith(
                                  prefixIcon: const Icon(
                                      Icons.lock_outline_rounded,
                                      color: Colors.grey),
                                  suffixIcon: IconButton(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    icon: Icon(
                                      _obscureText[1]
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureText[1] = !_obscureText[1];
                                      });
                                    },
                                  ),
                                ),
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 40.0),
                        RoundedLoadingButton(
                          color: Colors.grey.shade900,
                          errorColor: Colors.redAccent,
                          successColor: Colors.green.shade900,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              btnController.success();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Password Changed')));
                              Timer(const Duration(seconds: 3), () {
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/login', (route) => false);
                              });
                            } else {
                              btnController.error();
                              resetButton(btnController);
                            }
                          },
                          controller: btnController,
                          width: MediaQuery.of(context).size.width,
                          borderRadius: 16,
                          child: Text(
                            'Validate'.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 30.0),
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(text: "Remember your password? "),
                              TextSpan(
                                text: 'Login',
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, '/login', (route) => false);
                                  },
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
