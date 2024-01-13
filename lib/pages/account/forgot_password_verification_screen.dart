import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:noted_mobile/components/common/custom_toast.dart';
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
                                    ..onTap = () {
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
                                tokenVerification(textEditingController.text,
                                    accountId, btnController);
                              } else {
                                btnController.error();
                                resetButton(btnController);
                              }
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

  Future<void> tokenVerification(String token, String accountId,
      RoundedLoadingButtonController controller) async {
    try {
      final Tuple3? resetToken = await ref
          .read(accountClientProvider)
          .verifyToken(token: token, accountId: accountId);

      if (resetToken != null && mounted) {
        ref.read(trackerProvider).trackPage(TrackPage.changePassword);
        Navigator.pushNamed(context, '/change-password', arguments: resetToken);
      }
    } catch (e) {
      if (mounted) {
        controller.error();
        resetButton(controller);
        CustomToast.show(
          message: e.toString(),
          type: ToastType.error,
          context: context,
          gravity: ToastGravity.TOP,
        );
      }
    }
  }
}
