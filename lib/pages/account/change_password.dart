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
import 'package:tuple/tuple.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final List<bool> _obscureText = [true, true];

  @override
  Widget build(BuildContext context) {
    final RoundedLoadingButtonController btnController =
        RoundedLoadingButtonController();
    Tuple3? data = ModalRoute.of(context)!.settings.arguments as Tuple3?;

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
                      children: [
                        Text(
                          'change-password.title'.tr(),
                          style: const TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          'change-password.description'.tr(),
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
                        Container(
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                          child: TextFormField(
                            controller: passwordController,
                            obscureText: _obscureText[0],
                            decoration: ThemeHelper()
                                .textInputDecoration(
                                    'signup.password.label'.tr(),
                                    'signup.password.hint'.tr())
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
                                return 'signup.password.validator'.tr();
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
                                .textInputDecoration(
                                    'signup.confirmPassword.label'.tr(),
                                    'signup.confirmPassword.hint'.tr())
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
                                return 'signup.confirmPassword.validator'.tr();
                              }
                              if (val != passwordController.text) {
                                return 'signup.confirmPassword.validator2'.tr();
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
                              bool res = await changePassword(
                                password: passwordController.text,
                                resetToken: data!.item1,
                                authToken: data.item2,
                                accountId: data.item3,
                              );

                              if (res && mounted) {
                                CustomToast.show(
                                  message: 'change-password.success'.tr(),
                                  type: ToastType.success,
                                  context: context,
                                  gravity: ToastGravity.TOP,
                                );
                                btnController.success();
                                resetButton(btnController);
                                ref
                                    .read(trackerProvider)
                                    .trackPage(TrackPage.login);
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/login', (route) => false);
                              } else {
                                btnController.error();
                                resetButton(btnController);
                              }
                            } else {
                              btnController.error();
                              resetButton(btnController);
                            }
                          },
                          text: "change-password.button".tr(),
                        ),
                        const SizedBox(height: 30.0),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: "change-password.remember".tr()),
                              TextSpan(
                                text: 'change-password.signin'.tr(),
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

  Future<bool> changePassword({
    required String password,
    required String resetToken,
    required String authToken,
    required String accountId,
  }) async {
    try {
      final isSucces = await ref.read(accountClientProvider).resetPassword(
            password: password,
            accountId: accountId,
            resetToken: resetToken,
            authToken: authToken,
          );
      return isSucces;
    } catch (e) {
      if (mounted) {
        CustomToast.show(
          message: e.toString(),
          type: ToastType.error,
          context: context,
          gravity: ToastGravity.TOP,
        );
      }

      return false;
    }
  }
}

// AZERTYUIOPAZERTYUIOPAZERTYUIOPAZERTYUIOPAZERTYUIOPAZERTYUIOP