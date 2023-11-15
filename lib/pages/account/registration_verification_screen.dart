import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:noted_mobile/components/common/custom_toast.dart';
import 'package:noted_mobile/components/common/loading_button.dart';
import 'package:noted_mobile/data/clients/tracker_client.dart';
import 'package:noted_mobile/data/models/account/account.dart';
import 'package:noted_mobile/data/models/account/account_data.dart';
import 'package:noted_mobile/data/providers/account_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/utils/string_extension.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:tuple/tuple.dart';

class RegistrationVerificationPage extends ConsumerStatefulWidget {
  const RegistrationVerificationPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RegistrationVerificationPageState();
}

class _RegistrationVerificationPageState
    extends ConsumerState<RegistrationVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController textEditingController = TextEditingController();
  final RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();

  Timer? countdownTimer;
  Duration myDuration = const Duration(seconds: 30);

  void _startTimer() {
    _resetTimer();
    setState(() {
      isResend = true;
    });
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => _setCountDown());
  }

  void _resetTimer() {
    if (countdownTimer != null && countdownTimer!.isActive) {
      countdownTimer!.cancel();
    }

    setState(() => myDuration = const Duration(seconds: 30));
  }

  void _setCountDown() {
    const reduceSecondsBy = 1;
    setState(() {
      final seconds = myDuration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        countdownTimer!.cancel();
        isResend = false;
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }

  bool isResend = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTimer();
    });
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');
    final hours = strDigits(myDuration.inHours.remainder(24));
    final minutes = strDigits(myDuration.inMinutes.remainder(60));
    final seconds = strDigits(myDuration.inSeconds.remainder(60));

    final Tuple2<String, String> emailPassword =
        ModalRoute.of(context)!.settings.arguments as Tuple2<String, String>;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back, color: Colors.black)),
        ),
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
                        children: [
                          Text(
                            'forgot.step2.title'.tr(),
                            style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            'forgot.step2.description'.tr(),
                            style: const TextStyle(
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
                                return 'forgot.step2.validator'.tr();
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
                                TextSpan(
                                  text: "forgot.step2.not-received".tr(),
                                  style: const TextStyle(
                                    color: Colors.black38,
                                  ),
                                ),
                                const TextSpan(
                                  text: ' ',
                                ),
                                TextSpan(
                                  text: 'forgot.step2.resend'.tr(),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      _startTimer();

                                      if (isResend) {
                                        return;
                                      }
//TODO: uncomment this when backend is ready
                                      await handleResentToken(
                                        emailPassword: emailPassword,
                                      );
                                    },
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isResend ? Colors.grey : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40.0),
                          Text(
                            isResend ? '$hours:$minutes:$seconds' : '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 40.0),
                          LoadingButton(
                            btnController: btnController,
                            onPressed: () async {
                              await handleVerification(
                                emailPassword: emailPassword,
                                token: textEditingController.text,
                              );
                            },
                            text: 'forgot.step2.button'.tr(),
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

  Future<void> handleVerification({
    required Tuple2<String, String> emailPassword,
    required String token,
  }) async {
    if (_formKey.currentState!.validate()) {
      try {
        Account? account =
            await ref.read(accountClientProvider).validateAccount(
                  token: token,
                  email: emailPassword.item1,
                  password: emailPassword.item2,
                );

        if (account != null) {
          try {
            final loginRes = await ref.read(accountClientProvider).login(
                  email: emailPassword.item1,
                  password: emailPassword.item2,
                );
            if (loginRes) {
              ref.read(trackerProvider).trackPage(TrackPage.home);
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/home');
              }
            }
          } catch (e) {
            if (mounted) {
              CustomToast.show(
                message: e.toString().capitalize(),
                type: ToastType.error,
                context: context,
                gravity: ToastGravity.BOTTOM,
              );
            }
          }
        }
      } catch (e) {
        btnController.error();
        resetButton(btnController);
        if (mounted) {
          CustomToast.show(
            message: e.toString().capitalize(),
            type: ToastType.error,
            context: context,
            gravity: ToastGravity.BOTTOM,
          );
        }
      }
    } else {
      btnController.error();
      resetButton(btnController);
    }
  }

  Future<void> handleResentToken({
    required Tuple2<String, String> emailPassword,
  }) async {
    try {
      await ref.read(accountClientProvider).resendValidateToken(
            email: emailPassword.item1,
            password: emailPassword.item2,
          );
      if (mounted) {
        CustomToast.show(
          message: 'forgot.step2.resend-success'.tr(),
          type: ToastType.success,
          context: context,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      if (mounted) {
        CustomToast.show(
          message: e.toString().capitalize(),
          type: ToastType.error,
          context: context,
          gravity: ToastGravity.BOTTOM,
        );
      }
    }
  }
}
