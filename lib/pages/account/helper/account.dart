import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:noted_mobile/data/clients/tracker_client.dart';
import 'package:noted_mobile/data/providers/account_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:tuple/tuple.dart';

enum LoginAction {
  goHome,
  goVerification,
}

class AccountHelper {
  AccountHelper();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  Future<LoginAction?> loginWithGoogle({
    required WidgetRef ref,
  }) async {
    try {
      GoogleSignInAccount? gAccount =
          await _googleSignIn.signIn().onError((error, stackTrace) => null);
      if (gAccount == null) {
        return null;
      }
      String? googleToken = await gAccount.authHeaders
          .then((value) => value['Authorization']?.substring(7));

      if (googleToken == null) {
        return null;
      }

      try {
        bool loginRes = await ref
            .read(accountClientProvider)
            .loginWithGoogle(googleToken: googleToken);

        if (!loginRes) {
          return null;
        }

        return LoginAction.goHome;
      } catch (error) {
        rethrow;
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> disconnectGoogle() async {
    await _googleSignIn.disconnect();
  }

  void handleNavigation({
    required LoginAction? action,
    required BuildContext context,
    required String email,
    required String password,
  }) {
    if (action == null) {
      return;
    }

    switch (action) {
      case LoginAction.goHome:
        Navigator.of(context).pushReplacementNamed('/home');
        break;
      case LoginAction.goVerification:
        Navigator.pushNamed(context, '/register-verification',
            arguments: Tuple2(
              email,
              password,
            ));
        break;
    }
  }

  Future<void> handleSendToken({
    required Tuple2<String, String> emailPassword,
    required WidgetRef ref,
    required bool isRegistration,
  }) async {
    try {
      if (!isRegistration) {
        await ref.read(accountClientProvider).resendValidateToken(
              email: emailPassword.item1,
              password: emailPassword.item2,
            );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<LoginAction?> login({
    required String email,
    required String password,
    required RoundedLoadingButtonController btnController,
    required WidgetRef ref,
    required bool isRegistration,
  }) async {
    bool? isValidate;

    try {
      isValidate = await isValidateAccount(
        email: email,
        password: password,
        ref: ref,
      );

      if (isValidate == null) {
        return null;
      }
    } catch (e) {
      rethrow;
    }

    if (!isValidate) {
      btnController.reset();

      await handleSendToken(
          emailPassword: Tuple2(email, password),
          ref: ref,
          isRegistration: isRegistration);

      return LoginAction.goVerification;
    } else {
      try {
        final loginRes = await ref.read(accountClientProvider).login(
              email: email,
              password: password,
            );
        if (loginRes) {
          ref.read(trackerProvider).trackPage(TrackPage.home);
        }

        btnController.success();

        return LoginAction.goHome;
      } catch (e) {
        rethrow;
      }
    }
  }

  Future<bool?> isValidateAccount({
    required String email,
    required String password,
    required WidgetRef ref,
  }) async {
    try {
      bool? isValidateAccount =
          await ref.read(accountClientProvider).isAccountValidated(
                email: email,
                password: password,
              );

      return isValidateAccount;
    } catch (e) {
      rethrow;
    }
  }
}
