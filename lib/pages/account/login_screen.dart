import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:noted_mobile/components/common/custom_toast.dart';
import 'package:noted_mobile/components/common/google_button.dart';
import 'package:noted_mobile/components/common/loading_button.dart';
import 'package:noted_mobile/data/clients/tracker_client.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/pages/account/helper/account.dart';
import 'package:noted_mobile/utils/color.dart';
import 'package:noted_mobile/utils/string_extension.dart';
import 'package:noted_mobile/utils/theme_helper.dart';
import 'package:noted_mobile/utils/validator.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();

  SharedPreferences? prefs;
  bool _obscureText = true;

  Future<void> handleLogin(
    String email,
    String password,
  ) async {
    if (_formKey.currentState!.validate()) {
      try {
        LoginAction? loginRes = await AccountHelper().login(
          email: email,
          password: password,
          btnController: btnController,
          ref: ref,
          isRegistration: false,
        );

        if (!mounted) return;

        await AccountHelper().handleNavigation(
          action: loginRes,
          context: context,
          email: email,
          password: password,
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
    } else {
      btnController.error();
      resetButton(btnController);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.fromLTRB(32, 10, 32, 10),
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
                  'signin.title'.tr(),
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32.0),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: ThemeHelper.textInputDecoration(
                                'signin.email.label'.tr(),
                                'signin.email.hint'.tr())
                            .copyWith(
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
                      const SizedBox(height: 30.0),
                      TextFormField(
                          keyboardType: TextInputType.visiblePassword,
                          controller: _passwordController,
                          obscureText: _obscureText,
                          decoration: ThemeHelper.textInputDecoration(
                            'signin.password.label'.tr(),
                            'signin.password.hint'.tr(),
                          ).copyWith(
                            prefixIcon: const Icon(Icons.lock_outline_rounded,
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
                          textInputAction: TextInputAction.done,
                          onEditingComplete: () {
                            FocusScope.of(context).unfocus();
                          }),
                      const SizedBox(height: 16.0),
                      Container(
                        margin: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () async {
                            ref
                                .read(trackerProvider)
                                .trackPage(TrackPage.forgotPassword);

                            Navigator.pushNamed(context, '/forgot-password');
                          },
                          child: Text(
                            "signin.forgot".tr(),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      LoadingButton(
                        onPressed: () async => handleLogin(
                          _emailController.text,
                          _passwordController.text,
                        ),
                        btnController: btnController,
                        text: 'signin.button'.tr(),
                      ),
                      const SizedBox(height: 30.0),
                      Text(
                        "signin.other".tr(),
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                      const SizedBox(height: 24.0),
                      const GoogleButton(),
                      Container(
                        margin: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: "signin.signup".tr()),
                              const TextSpan(text: " "),
                              TextSpan(
                                text: 'signin.signupButton'.tr(),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    ref
                                        .read(trackerProvider)
                                        .trackPage(TrackPage.register);
                                    Navigator.pushNamed(context, '/register');
                                  },
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
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
        ),
      ),
    );
  }
}
