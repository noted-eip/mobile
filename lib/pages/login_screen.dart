import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:noted_mobile/data/providers/account_provider.dart';
import 'package:noted_mobile/utils/theme_helper.dart';
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
        RoundedLoadingButton(
          height: 48,
          width: 48,
          borderRadius: 16,
          color: oAuth[i]['color'],
          controller: oAuth[i]['controller'],
          onPressed: () {
            oAuth[i]['controller'].error();
            resetButton(oAuth[i]['controller']);
          },
          child: Icon(
            oAuth[i]['icon'],
            color: Colors.white,
          ),
        ),
      );
    }

    return buttons;
  }

  void resetButton(RoundedLoadingButtonController controller) async {
    Timer(const Duration(seconds: 3), () {
      controller.reset();
    });
  }

  Future<void> login(
    String email,
    String password,
  ) async {
    if (_formKey.currentState!.validate()) {
      try {
        final loginRes = await ref.read(accountClientProvider).login(
              _emailController.text,
              _passwordController.text,
              ref,
            );
        if (loginRes && mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
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
                const Text(
                  'Signin into your account',
                  style: TextStyle(color: Colors.grey, fontSize: 24),
                ),
                const SizedBox(height: 32.0),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: ThemeHelper()
                            .textInputDecoration('Email', 'Enter your Email')
                            .copyWith(
                              prefixIcon: const Icon(
                                Icons.mail_outline,
                                color: Colors.grey,
                              ),
                            ),
                        validator: (val) {
                          if (val!.isEmpty) {
                            return "Please enter your email";
                          } else if (!RegExp(
                                  r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                              .hasMatch(val)) {
                            return "Enter a valid email address";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30.0),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        decoration: ThemeHelper()
                            .textInputDecoration(
                                'Password', 'Enter your password')
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
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      Container(
                        margin: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/forgot-password');
                          },
                          child: const Text(
                            "Forgot your password?",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      RoundedLoadingButton(
                        color: Colors.grey.shade900,
                        errorColor: Colors.redAccent,
                        successColor: Colors.green.shade900,
                        onPressed: () async {
                          login(
                            _emailController.text,
                            _passwordController.text,
                          );
                        },
                        controller: btnController,
                        width: MediaQuery.of(context).size.width,
                        borderRadius: 16,
                        child: Text(
                          'Sign In'.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      const Text(
                        "Or sign in account using social media",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                              const TextSpan(text: "Don't have an account? "),
                              TextSpan(
                                text: 'Create',
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
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
