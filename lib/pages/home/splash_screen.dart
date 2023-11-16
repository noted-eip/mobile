import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/clients/tracker_client.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
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

  _SplashScreenState() {
    Timer(const Duration(milliseconds: 2000), () {
      setState(() {
        if (_isLogged) {
          final user = ref.read(userProvider);
          user.setToken(prefs?.getString('token') ?? '');
          user.setName(
            prefs?.getString('name') ?? '',
          );
          user.setEmail(
            prefs?.getString('email') ?? '',
          );
          user.setID(
            prefs?.getString('id') ?? '',
          );
          ref.read(trackerProvider).trackPage(TrackPage.home);
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        } else {
          ref.read(trackerProvider).trackPage(TrackPage.login);
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
                  borderRadius: BorderRadius.circular(32.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(5.0, 5.0),
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
