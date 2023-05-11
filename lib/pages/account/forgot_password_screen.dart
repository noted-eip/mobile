import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:noted_mobile/components/common/loading_button.dart';
import 'package:noted_mobile/utils/string_extension.dart';
import 'package:noted_mobile/utils/theme_helper.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  ForgotPasswordPageState createState() => ForgotPasswordPageState();
}

class ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final RoundedLoadingButtonController btnController =
        RoundedLoadingButtonController();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SafeArea(
            child: Container(
              margin: const EdgeInsets.fromLTRB(32, 0, 32, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Forgot Password?',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        'Enter the email address associated with your account.',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        'We will email you a verification code to check your authenticity.',
                        style: TextStyle(
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40.0),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Container(
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                          child: TextFormField(
                            autofocus: true,
                            decoration: ThemeHelper()
                                .textInputDecoration(
                                    'Email', 'Enter your Email')
                                .copyWith(
                                  prefixIcon: const Icon(
                                    Icons.mail_outline,
                                    color: Colors.grey,
                                  ),
                                ),
                            validator: (val) {
                              if (val!.isEmpty) {
                                return "Please enter your email";
                              } else if (!val.isEmail()) {
                                return "Enter a valid email address";
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 40.0),
                        LoadingButton(
                          btnController: btnController,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              Navigator.pushReplacementNamed(
                                  context, '/forgot-password-verification');
                            } else {
                              btnController.error();
                              resetButton(btnController);
                            }
                          },
                          text: 'Send',
                        ),
                        const SizedBox(height: 32.0),
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
