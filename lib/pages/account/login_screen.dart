import 'dart:async';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:noted_mobile/components/common/custom_toast.dart';
import 'package:noted_mobile/components/common/loading_button.dart';
import 'package:noted_mobile/data/clients/tracker_client.dart';
import 'package:noted_mobile/data/providers/account_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/utils/string_extension.dart';
import 'package:noted_mobile/utils/theme_helper.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

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

  final List<dynamic> oAuth = [
    {
      'name': 'Google',
      'icon': FontAwesomeIcons.google,
      'color': Colors.red,
      'controller': RoundedLoadingButtonController(),
      'onPressed': () {},
    },
  ];

  Future<bool> handleSignIn() async {
    try {
      GoogleSignInAccount? gAccount =
          await _googleSignIn.signIn().onError((error, stackTrace) => null);
      if (gAccount == null) {
        return false;
      }
      String? googleToken = await gAccount.authHeaders
          .then((value) => value['Authorization']?.substring(7));

      if (googleToken == null) {
        return false;
      }

      try {
        bool loginRes =
            await ref.read(accountClientProvider).loginWithGoogle(googleToken);

        if (!loginRes) {
          return false;
        }

        if (mounted) {
          ref.read(trackerProvider).trackPage(TrackPage.home);
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } catch (error) {
        if (mounted) {
          CustomToast.show(
            message: error.toString().capitalize(),
            type: ToastType.error,
            context: context,
            gravity: ToastGravity.BOTTOM,
          );
        }
        return false;
      }

      return true;
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      return false;
    }
  }

  Future<void> handleSignOut() async {
    _googleSignIn.disconnect();
  }

  List<Widget> buildOAuthButtons() {
    List<Widget> buttons = [];

    for (int i = 0; i < oAuth.length; i++) {
      buttons.add(
        Expanded(
          child: LoadingButton(
            color: oAuth[i]['color'],
            btnController: oAuth[i]['controller'],
            onPressed: () async {
              bool res = await handleSignIn();

              if (res) {
                (oAuth[i]['controller'] as RoundedLoadingButtonController)
                    .success();
                resetButton(oAuth[i]['controller']);
                handleSignOut();
                return;
              } else {
                (oAuth[i]['controller'] as RoundedLoadingButtonController)
                    .error();
                resetButton(oAuth[i]['controller']);
                return;
              }
            },
            child: oAuth.length < 3
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        oAuth[i]['icon'],
                        color: Colors.white,
                      ),
                      const SizedBox(width: 16.0),
                      Text(
                        oAuth[i]['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Icon(
                    oAuth[i]['icon'],
                    color: Colors.white,
                  ),
          ),
        ),
      );
      if (i < oAuth.length - 1) {
        buttons.add(
          const SizedBox(
            width: 10,
          ),
        );
      }
    }

    return buttons;
  }

  Future<void> login(
    String email,
    String password,
  ) async {
    if (_formKey.currentState!.validate()) {
      try {
        final loginRes = await ref.read(accountClientProvider).login(
              email: _emailController.text,
              password: _passwordController.text,
            );
        if (loginRes && mounted) {
          ref.read(trackerProvider).trackPage(TrackPage.home);
          Navigator.of(context).pushReplacementNamed('/home');
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

        btnController.error();
        resetButton(btnController);
        return;
      }
    } else {
      btnController.error();
      resetButton(btnController);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  style: const TextStyle(color: Colors.grey, fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32.0),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: ThemeHelper()
                            .textInputDecoration('signin.email.label'.tr(),
                                'signin.email.hint'.tr())
                            .copyWith(
                              prefixIcon: const Icon(
                                Icons.mail_outline,
                                color: Colors.grey,
                              ),
                            ),
                        validator: (val) {
                          if (val!.isEmpty) {
                            return "signin.email.validator".tr();
                          }
                          // TODO: Uncomment this when email validation is fixed
                          //  else if (!val.isEmail()) {
                          //   return "Enter a valid email address";
                          // }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30.0),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        decoration: ThemeHelper()
                            .textInputDecoration(
                              'signin.password.label'.tr(),
                              'signin.password.hint'.tr(),
                            )
                            .copyWith(
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
                        validator: (val) {
                          if (val!.isEmpty) {
                            return 'signin.password.validator'.tr();
                          }
                          return null;
                        },
                      ),
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
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      LoadingButton(
                        onPressed: () async => login(
                          _emailController.text,
                          _passwordController.text,
                        ),
                        btnController: btnController,
                        text: 'signin.button'.tr(),
                      ),
                      const SizedBox(height: 30.0),
                      Text(
                        "signin.other".tr(),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ...buildOAuthButtons(),
                        ],
                      ),
                      const SizedBox(height: 32.0),
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
        ),
      ),
    );
  }
}
