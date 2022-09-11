import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  bool _isVisible = false;
  SharedPreferences? prefs;
  bool _isLogged = false;

  Future<void> initializePreference() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    initializePreference().whenComplete(() {
      _isLogged = prefs?.getString('token') != null;
    });
    super.initState();
  }

  SplashScreenState() {
    Timer(const Duration(milliseconds: 2000), () {
      setState(() {
        if (_isLogged) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
        }
      });
    });

    Timer(const Duration(milliseconds: 10), () {
      setState(() {
        _isVisible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.secondary,
        child: AnimatedOpacity(
          opacity: _isVisible ? 1.0 : 0,
          duration: const Duration(milliseconds: 1200),
          child: Center(
            child: Container(
              height: 140.0,
              width: 140.0,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 2.0,
                      offset: const Offset(5.0, 3.0),
                      spreadRadius: 2.0,
                    )
                  ]),
              child: const Center(
                child: Image(
                  image: AssetImage('./images/noted_logo.png'),
                  fit: BoxFit.fill,
                  height: 100.0,
                  width: 100.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
