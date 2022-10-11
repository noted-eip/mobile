import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:noted_mobile/data/api_helper.dart';
import 'package:noted_mobile/data/dio_singleton.dart';
import 'package:noted_mobile/data/user_provider.dart';
import 'package:noted_mobile/utils/theme_helper.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  SharedPreferences? prefs;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void setUserInfos(
    String token,
    String id,
    String email,
    String userName,
  ) async {
    prefs = await SharedPreferences.getInstance();
    prefs!.setString('token', token);
    prefs!.setString('id', id);
    prefs!.setString('email', email);
    prefs!.setString('username', userName);
  }

  Future<void> login(Map<String, String> data, BuildContext context,
      RoundedLoadingButtonController controller) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    final api = singleton.get<APIHelper>();

    try {
      final auth = await api.post("/authenticate", body: data);

      if (auth['statusCode'] != 200) {
        controller.error();
        resetButton(controller);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth['error']),
          ),
        );
        return;
      }

      final token = auth['data']['token'];

      Map<String, dynamic> payload = Jwt.parseJwt(token);

      final user = await api.get("/accounts/${payload['uid']}",
          headers: {"Authorization": "Bearer $token"});

      if (user['statusCode'] != 200) {
        controller.error();
        resetButton(controller);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(user['error']),
          ),
        );
        return;
      }
      if (!mounted) return;

      final userInfos = user['data']['account'];

      userProvider.setToken(token);
      userProvider.setID(payload['uid']);
      userProvider.setEmail(userInfos['email']);
      userProvider.setUsername(userInfos['name']);

      setUserInfos(
        token,
        payload['uid'],
        userInfos['email'],
        userInfos['name'],
      );
      controller.success();
      resetButton(controller);
      Navigator.of(context).pushReplacementNamed('/home');
    } on DioError catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
      controller.error();
      resetButton(controller);
      return;
    }
  }

  void resetButton(RoundedLoadingButtonController controller) async {
    Timer(const Duration(seconds: 3), () {
      controller.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final RoundedLoadingButtonController btnController =
        RoundedLoadingButtonController();
    final RoundedLoadingButtonController btnController2 =
        RoundedLoadingButtonController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Column(
                children: [
                  const Text(
                    'Hello',
                    style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Signin into your account',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30.0),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: ThemeHelper()
                              .textInputDecoration('Email', 'Enter your Email'),
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
                          obscureText: true,
                          decoration: ThemeHelper().textInputDecoration(
                              'Password', 'Enter your password'),
                          validator: (val) {
                            if (val!.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15.0),
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
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              login({
                                "email": _emailController.text,
                                "password": _passwordController.text
                              }, context, btnController);
                            } else {
                              btnController.error();
                              resetButton(btnController);
                            }
                          },
                          controller: btnController,
                          width: 200,
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
                        const SizedBox(height: 25.0),
                        RoundedLoadingButton(
                          color: Colors.redAccent,
                          errorColor: Colors.redAccent,
                          successColor: Colors.green.shade900,
                          onPressed: () {
                            //TODO: Add google sign in
                            // signInWithGoogle().whenComplete(() {
                            //   Navigator.of(context).push(
                            //     MaterialPageRoute(
                            //       builder: (context) {
                            //         return const HomeScreen();
                            //       },
                            //     ),
                            //   );
                            // });

                            btnController2.error();
                            resetButton(btnController2);
                          },
                          controller: btnController2,
                          width: 200,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.googlePlus,
                                size: 25,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Google".toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30.0),
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
      ),
    );
  }
}
