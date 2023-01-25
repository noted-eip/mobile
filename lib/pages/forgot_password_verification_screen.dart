import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:noted_mobile/utils/theme_helper.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class ForgotPasswordVerificationPage extends StatefulWidget {
  const ForgotPasswordVerificationPage({Key? key}) : super(key: key);

  @override
  ForgotPasswordVerificationPageState createState() =>
      ForgotPasswordVerificationPageState();
}

class ForgotPasswordVerificationPageState
    extends State<ForgotPasswordVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  // bool _pinSuccess = false;

  void resetButton(RoundedLoadingButtonController controller) async {
    Timer(const Duration(seconds: 3), () {
      controller.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController textEditingController = TextEditingController();
    final RoundedLoadingButtonController btnController =
        RoundedLoadingButtonController();

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
                      child:
                          const Icon(Icons.key, size: 80, color: Colors.black),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      alignment: Alignment.topLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Verification',
                            style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Enter the verification code we just sent you on your email address.',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40.0),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          PinCodeTextField(
                            autoFocus: true,
                            autoDismissKeyboard: true,
                            keyboardType: TextInputType.number,
                            length: 6,
                            obscureText: false,
                            animationType: AnimationType.fade,
                            pinTheme: PinTheme(
                                shape: PinCodeFieldShape.box,
                                borderRadius: BorderRadius.circular(5),
                                fieldHeight: 50,
                                fieldWidth: 40,
                                activeFillColor: Colors.white,
                                activeColor:
                                    Theme.of(context).colorScheme.primary,
                                inactiveColor:
                                    Theme.of(context).colorScheme.secondary,
                                inactiveFillColor: Colors.white,
                                selectedColor: Colors.blueGrey,
                                selectedFillColor: Colors.grey),
                            animationDuration:
                                const Duration(milliseconds: 300),
                            enableActiveFill: true,
                            controller: textEditingController,
                            onCompleted: (v) {
                              debugPrint("Completed");
                            },
                            onChanged: (value) {
                              debugPrint(value);
                            },
                            beforeTextPaste: (text) {
                              return true;
                            },
                            validator: (val) {
                              if (val!.length < 4) {
                                return 'Please enter a valid code';
                              } else {
                                return null;
                              }
                            },
                            appContext: context,
                          ),
                          const SizedBox(height: 50.0),
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: "If you didn't receive a code! ",
                                  style: TextStyle(
                                    color: Colors.black38,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Resend',
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return ThemeHelper().alartDialog(
                                              "Successful",
                                              "Verification code resend successful.",
                                              context);
                                        },
                                      );
                                    },
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40.0),
                          RoundedLoadingButton(
                            color: Colors.grey.shade900,
                            errorColor: Colors.redAccent,
                            successColor: Colors.green.shade900,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                Navigator.pushNamed(
                                    context, '/change-password');
                              } else {
                                btnController.error();
                                resetButton(btnController);
                              }
                            },
                            controller: btnController,
                            width: MediaQuery.of(context).size.width,
                            borderRadius: 16,
                            child: Text(
                              'Verify'.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
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
        ));
  }
}
