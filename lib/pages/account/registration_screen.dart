import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:noted_mobile/components/common/custom_toast.dart';
import 'package:noted_mobile/components/common/loading_button.dart';
import 'package:noted_mobile/data/providers/account_provider.dart';
import 'package:noted_mobile/utils/string_extension.dart';
import 'package:noted_mobile/utils/theme_helper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

  final List<dynamic> oAuth = [
    {
      'name': 'Google',
      'icon': FontAwesomeIcons.google,
      'color': Colors.red,
      'controller': RoundedLoadingButtonController(),
      'onPressed': () {},
    },
    {
      'name': 'Facebook',
      'icon': FontAwesomeIcons.facebook,
      'color': Colors.blue,
      'controller': RoundedLoadingButtonController(),
      'onPressed': () {},
    },
    {
      'name': 'Github',
      'icon': FontAwesomeIcons.apple,
      'color': Colors.black,
      'controller': RoundedLoadingButtonController(),
      'onPressed': () {},
    },
  ];

  List<Widget> buildOAuthButtons() {
    List<Widget> buttons = [];

    for (int i = 0; i < oAuth.length; i++) {
      buttons.add(
        LoadingButton(
          width: 48,
          color: oAuth[i]['color'],
          onPressed: () async {
            (oAuth[i]['controller'] as RoundedLoadingButtonController).error();
            resetButton(oAuth[i]['controller']);
          },
          btnController: oAuth[i]['controller'],
          child: Icon(
            oAuth[i]['icon'],
            color: Colors.white,
          ),
        ),
      );
    }

    return buttons;
  }

  Future<void> createAccount(String name, String email, String password) async {
    if (_formKey.currentState!.validate()) {
      try {
        final loginRes = await ref
            .read(accountClientProvider)
            .createAccount(name, email, password);

        if (loginRes != null && mounted) {
          CustomToast.show(
            message: "Account created",
            type: ToastType.success,
            context: context,
            gravity: ToastGravity.BOTTOM,
          );

          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (Route<dynamic> route) => false);
        }
      } catch (e) {
        CustomToast.show(
          message: e.toString().capitalize(),
          type: ToastType.error,
          context: context,
          gravity: ToastGravity.BOTTOM,
          duration: 4,
        );

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
                          const Text(
                            'Create your Noted Account',
                            style: TextStyle(color: Colors.grey, fontSize: 24),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            decoration:
                                ThemeHelper().inputBoxDecorationShaddow(),
                            child: TextFormField(
                              autofocus: true,
                              controller: _nameController,
                              decoration: ThemeHelper()
                                  .textInputDecoration(
                                      'Name', 'Enter your name')
                                  .copyWith(
                                    prefixIcon: const Icon(
                                      Icons.person_outline,
                                      color: Colors.grey,
                                    ),
                                  ),
                              validator: (val) {
                                if ((val!.isEmpty)) {
                                  return "Enter an name";
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          Container(
                            decoration:
                                ThemeHelper().inputBoxDecorationShaddow(),
                            child: TextFormField(
                              controller: _emailController,
                              decoration: ThemeHelper()
                                  .textInputDecoration(
                                      'Email', 'Enter your Email')
                                  .copyWith(
                                    prefixIcon: const Icon(
                                      Icons.mail_outline,
                                      color: Colors.grey,
                                    ),
                                  ),
                              validator: (val) {
                                if (val!.isEmpty) {
                                  return "Please enter an email adress";
                                } else if (!RegExp(
                                        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                                    .hasMatch(val)) {
                                  return "Enter a valid email address";
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          Container(
                            decoration:
                                ThemeHelper().inputBoxDecorationShaddow(),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: _obscureText,
                              decoration: ThemeHelper()
                                  .textInputDecoration(
                                      "Password*", "Enter your password")
                                  .copyWith(
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
                              validator: (val) {
                                if (val!.isEmpty) {
                                  return "Please enter your password";
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          FormField<bool>(
                            builder: (state) {
                              return Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Checkbox(
                                          fillColor: MaterialStateProperty.all(
                                              Colors.grey.shade900),
                                          value: checkboxValue,
                                          onChanged: (value) {
                                            setState(() {
                                              checkboxValue = value!;
                                              state.didChange(value);
                                            });
                                          }),
                                      const Text(
                                        "I accept all terms and conditions.",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      state.errorText ?? '',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: Theme.of(context).errorColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                ],
                              );
                            },
                            validator: (value) {
                              if (!checkboxValue) {
                                return 'You need to accept terms and conditions';
                              } else {
                                return null;
                              }
                            },
                          ),
                          const SizedBox(height: 20.0),
                          LoadingButton(
                            onPressed: () async => createAccount(
                                _nameController.text,
                                _emailController.text,
                                _passwordController.text),
                            btnController: btnController,
                            text: 'Create',
                          ),
                          const SizedBox(height: 32.0),
                          const Text(
                            "Or create account using social media",
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 24.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ...buildOAuthButtons(),
                            ],
                          ),
                          const SizedBox(
                            width: 32.0,
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                      text: "Already have an account? "),
                                  TextSpan(
                                    text: 'Login',
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
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