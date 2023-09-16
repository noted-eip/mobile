import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/common/loading_button.dart';
import 'package:noted_mobile/data/clients/tracker_client.dart';
import 'package:noted_mobile/data/providers/account_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/utils/theme_helper.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:tuple/tuple.dart';

class ForgotPasswordVerificationPage extends ConsumerStatefulWidget {
  const ForgotPasswordVerificationPage({Key? key}) : super(key: key);

  @override
  ForgotPasswordVerificationPageState createState() =>
      ForgotPasswordVerificationPageState();
}

class ForgotPasswordVerificationPageState
    extends ConsumerState<ForgotPasswordVerificationPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    TextEditingController textEditingController = TextEditingController();
    final RoundedLoadingButtonController btnController =
        RoundedLoadingButtonController();

    String accountId = ModalRoute.of(context)!.settings.arguments as String;

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
                            length: 4,
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
                          LoadingButton(
                            btnController: btnController,
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                tokenVerification(
                                  textEditingController.text,
                                  accountId,
                                );
                              } else {
                                btnController.error();
                                resetButton(btnController);
                              }
                            },
                            text: 'Verify',
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

  Future<void> tokenVerification(String token, String accountId) async {
    try {
      final Tuple3? resetToken = await ref
          .read(accountClientProvider)
          .verifyToken(token: token, accountId: accountId);

      if (resetToken != null && mounted) {
        ref.read(trackerProvider).trackPage(TrackPage.changePassword);
        Navigator.pushNamed(context, '/change-password', arguments: resetToken);
      }
    } on DioException catch (e) {
      if (e.response!.statusCode == 400) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ThemeHelper()
                .alartDialog("Error", "Verification code is invalid.", context);
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ThemeHelper()
                .alartDialog("Error", "Something went wrong.", context);
          },
        );
      }
      rethrow;
    }
  }
}
