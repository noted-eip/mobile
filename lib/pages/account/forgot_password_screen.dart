import 'package:dio/dio.dart';
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
import 'package:noted_mobile/utils/validator.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      ForgotPasswordPageState();
}

class ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();
  final TextEditingController email = TextEditingController();

  Future<void> resetPassword(
      String email, RoundedLoadingButtonController btnController) async {
    if (_formKey.currentState!.validate()) {
      try {
        final accountId = await ref
            .read(accountClientProvider)
            .forgetAccountPassword(email: email);

        if (accountId != null && mounted) {
          ref
              .read(trackerProvider)
              .trackPage(TrackPage.forgotPasswordVerification);

          Navigator.pushReplacementNamed(
            context,
            '/forgot-password-verification',
            arguments: accountId,
          );
        }
      } on DioException catch (e) {
        if (e.response != null) {
          final error = e.response!.data['error'];
          if (mounted) {
            CustomToast.show(
              message: error.toString(),
              type: ToastType.error,
              context: context,
              gravity: ToastGravity.BOTTOM,
            );
          }
        }
        rethrow;
      }
    } else {
      btnController.error();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      borderRadius: BorderRadius.circular(32),
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
                    children: [
                      Text(
                        'forgot.step1.title'.tr(),
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        'forgot.step1.description'.tr(),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        'forgot.step1.description2'.tr(),
                        style: const TextStyle(
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
                            controller: email,
                            autofocus: true,
                            decoration: ThemeHelper()
                                .textInputDecoration(
                                  'forgot.step1.email.label'.tr(),
                                  'forgot.step1.email.hint'.tr(),
                                )
                                .copyWith(
                                  prefixIcon: const Icon(
                                    Icons.mail_outline,
                                    color: Colors.grey,
                                  ),
                                ),
                            validator: (val) => NotedValidator.validateEmail(
                              val?.trim(),
                            ),
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.emailAddress,
                            onEditingComplete: () async {
                              FocusScope.of(context).unfocus();
                              btnController.start();
                              await resetPassword(
                                  email.text.trim(), btnController);
                            },
                          ),
                        ),
                        const SizedBox(height: 40.0),
                        LoadingButton(
                          btnController: btnController,
                          onPressed: () async {
                            await resetPassword(
                                email.text.trim(), btnController);
                          },
                          text: 'forgot.step1.button'.tr(),
                        ),
                        const SizedBox(height: 32.0),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: "forgot.step1.remember".tr()),
                              const TextSpan(text: " "),
                              TextSpan(
                                text: 'forgot.step1.signin'.tr(),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    ref
                                        .read(trackerProvider)
                                        .trackPage(TrackPage.login);

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
