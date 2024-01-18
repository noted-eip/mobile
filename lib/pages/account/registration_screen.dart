import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:noted_mobile/components/common/custom_toast.dart';
import 'package:noted_mobile/components/common/google_button.dart';
import 'package:noted_mobile/components/common/loading_button.dart';
import 'package:noted_mobile/data/clients/tracker_client.dart';
import 'package:noted_mobile/data/providers/account_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/pages/account/helper/account.dart';
import 'package:noted_mobile/utils/color.dart';
import 'package:noted_mobile/utils/string_extension.dart';
import 'package:noted_mobile/utils/theme_helper.dart';
import 'package:noted_mobile/utils/validator.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class RegistrationPage extends ConsumerStatefulWidget {
  const RegistrationPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RegistrationPageState();
}

class _RegistrationPageState extends ConsumerState<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();

  bool checkedValue = false;
  bool checkboxValue = false;

  Future<void> createAccount(String name, String email, String password,
      RoundedLoadingButtonController btnController) async {
    if (_formKey.currentState!.validate()) {
      try {
        final loginRes = await ref.read(accountClientProvider).createAccount(
              name: name,
              email: email,
              password: password,
            );

        if (loginRes != null && mounted) {
          CustomToast.show(
            message: "signup.success".tr(),
            type: ToastType.success,
            context: context,
            gravity: ToastGravity.BOTTOM,
          );

          ref.read(trackerProvider).trackPage(TrackPage.login);

          try {
            LoginAction? loginRes = await AccountHelper().login(
              email: email,
              password: password,
              btnController: btnController,
              ref: ref,
              isRegistration: true,
            );

            if (!mounted) return;

            await AccountHelper().handleNavigation(
              action: loginRes,
              context: context,
              password: password,
              email: email,
            );
          } catch (e) {
            if (!mounted) return;
            CustomToast.show(
              message: e.toString().capitalize(),
              type: ToastType.error,
              context: context,
              gravity: ToastGravity.BOTTOM,
            );
            btnController.error();
            resetButton(btnController);
          }
        }
      } catch (e) {
        if (mounted) {
          CustomToast.show(
            message: e.toString().capitalize(),
            type: ToastType.error,
            context: context,
            gravity: ToastGravity.BOTTOM,
            duration: 4,
          );
        }

        if (kDebugMode) {
          print(e);
        }
        btnController.error();
        resetButton(btnController);
      }
    } else {
      btnController.error();
      resetButton(btnController);
    }
  }

  void resetButton(RoundedLoadingButtonController controller) async {
    Timer(const Duration(seconds: 3), () {
      controller.reset();
    });
  }

  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(25, 50, 25, 10),
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(width: 5, color: Colors.white),
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                  color: NotedColors.primary,
                                  blurRadius: 5,
                                  offset: Offset(5, 5),
                                ),
                              ],
                            ),
                            child: const Image(
                              image: AssetImage('./images/noted_logo.png'),
                              fit: BoxFit.fill,
                              height: 80.0,
                              width: 80.0,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'signup.title'.tr(),
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 24),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            decoration: ThemeHelper.inputBoxDecorationShaddow(),
                            child: TextFormField(
                              autofocus: true,
                              controller: _nameController,
                              decoration: ThemeHelper.textInputDecoration(
                                'signup.name.label'.tr(),
                                'signup.name.hint'.tr(),
                              ).copyWith(
                                prefixIcon: const Icon(
                                  Icons.person_outline,
                                  color: Colors.grey,
                                ),
                              ),
                              validator: (val) =>
                                  NotedValidator.validateName(val?.trim()),
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          Container(
                            decoration: ThemeHelper.inputBoxDecorationShaddow(),
                            child: TextFormField(
                              controller: _emailController,
                              decoration: ThemeHelper.textInputDecoration(
                                'signup.email.label'.tr(),
                                'signup.email.hint'.tr(),
                              ).copyWith(
                                prefixIcon: const Icon(
                                  Icons.mail_outline,
                                  color: Colors.grey,
                                ),
                              ),
                              validator: (val) =>
                                  NotedValidator.validateEmail(val?.trim()),
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          Container(
                            decoration: ThemeHelper.inputBoxDecorationShaddow(),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: _obscureText,
                              decoration: ThemeHelper.textInputDecoration(
                                "signup.password.label".tr(),
                                "signup.password.hint".tr(),
                              ).copyWith(
                                prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                    color: Colors.grey),
                                suffixIcon: IconButton(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),
                              ),
                              validator: (val) =>
                                  NotedValidator.validatePassword(val?.trim()),
                              onEditingComplete: () {
                                FocusScope.of(context).unfocus();
                              },
                              textInputAction: TextInputAction.done,
                            ),
                          ),
                          const SizedBox(height: 36.0),
                          LoadingButton(
                            onPressed: () async => createAccount(
                                _nameController.text.trim(),
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                                btnController),
                            btnController: btnController,
                            text: 'signup.button'.tr(),
                          ),
                          const SizedBox(height: 32.0),
                          Text(
                            "signup.other".tr(),
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 24.0),
                          const GoogleButton(),
                          const SizedBox(
                            width: 32.0,
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: "signup.signin".tr()),
                                  const TextSpan(text: " "),
                                  TextSpan(
                                    text: 'signup.signinButton'.tr(),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        ref
                                            .read(trackerProvider)
                                            .trackPage(TrackPage.login);
                                        Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            '/login',
                                            (route) => false);
                                      },
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
