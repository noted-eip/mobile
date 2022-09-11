import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:noted_mobile/utils/theme_helper.dart';
import 'package:noted_mobile/data/user_provider.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:jwt_decode/jwt_decode.dart';
import '../utils/constant.dart';
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

  Future<void> login(Map<String, String> data, BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    try {
      var dio = Dio();
      Response response = await dio.post("$kBaseUrl/authenticate", data: data);

      if (response.statusCode == 200) {
        Map<String, dynamic> payload = Jwt.parseJwt(response.data['token']);

        Response userInfos = await dio.get(
          "$kBaseUrl/accounts/${payload['uid']}",
          options: Options(
            headers: {"Authorization": "Bearer ${response.data['token']}"},
          ),
        );

        userProvider.setToken(response.data['token']);
        userProvider.setID(payload['uid']);
        userProvider.setEmail(userInfos.data['account']['email']);
        userProvider.setUsername(userInfos.data['account']['name']);

        setUserInfos(
          response.data['token'],
          payload['uid'],
          userInfos.data['account']['email'],
          userInfos.data['account']['name'],
        );
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on DioError catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.response!.data["error"] ?? "Wrong password or email"),
      ));
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
                              return 'Please enter your email';
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
                              // ignore: todo
                              // TODO: Navigate to forgot password screen
                              // Navigator.pushNamed(context, '/forgot-password');
                            },
                            child: const Text(
                              "Forgot your password?",
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration:
                              ThemeHelper().buttonBoxDecoration(context),
                          child: ElevatedButton(
                            style: ThemeHelper().buttonStyle(),
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(40, 10, 40, 10),
                              child: Text(
                                'Sign In'.toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                login({
                                  "email": _emailController.text,
                                  "password": _passwordController.text
                                }, context);
                              }
                            },
                          ),
                        ),
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
                                      // ignore: todo
                                      // TODO: Navigate to register page
                                      // Navigator.pushNamed(
                                      //     context, '/register');
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
