import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/common/loading_button.dart';
import 'package:noted_mobile/data/clients/tracker_client.dart';
import 'package:noted_mobile/data/providers/account_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/utils/theme_helper.dart';
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

  @override
  Widget build(BuildContext context) {
    final Tuple2<String, String> emailPassword =
        ModalRoute.of(context)!.settings.arguments as Tuple2<String, String>;
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
                                      await ref
                                          .read(accountClientProvider)
                                          .resendValidateToken(
                                            email: emailPassword.item1,
                                            password: emailPassword.item2,
                                          );
                                      if (mounted) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return ThemeHelper().alartDialog(
                                                "forgot.step2.resend-pop-up.title"
                                                    .tr(),
                                                "forgot.step2.resend-pop-up.description"
                                                    .tr(),
                                                context);
                                          },
                                        );
                                      }
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
                              // verifyAccount(
                              //   userId: userId,
                              //   token: textEditingController.text,
                              // );
                              ref
                                  .read(trackerProvider)
                                  .trackPage(TrackPage.login);
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/login', (route) => false);
                              // if (_formKey.currentState!.validate()) {
                              //   tokenVerification(
                              //     textEditingController.text,
                              //     accountId,
                              //   );
                              // } else {
                              //   btnController.error();
                              //   resetButton(btnController);
                              // }
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

  void verifyAccount(
      {required Tuple2<String, String> emailPassword,
      required String token}) async {
    ref.read(accountClientProvider).validateAccount(
          token: token,
          email: emailPassword.item1,
          password: emailPassword.item2,
        );
  }
}
