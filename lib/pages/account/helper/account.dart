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

  Future<bool?> changePassword({
    required WidgetRef ref,
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
      rethrow;
    }
  }

  Future<LoginAction?> loginWithGoogle({
    required WidgetRef ref,
    String? code,
  }) async {
    String? googleToken;

    if (code == null) {
      try {
        GoogleSignInAccount? gAccount = await _googleSignIn.signIn();

        if (gAccount == null) {
          return null;
        }
        googleToken = await gAccount.authHeaders
            .then((value) => value['Authorization']?.substring(7));

        if (googleToken == null) {
          return null;
        }
      } catch (error) {
        rethrow;
      }
    } else {
      try {
        String? googleTokenResponse = await ref
            .read(accountClientProvider)
            .getAccesTokenGoogle(code: code);

        if (googleTokenResponse == null) {
          return null;
        }

        googleToken = googleTokenResponse;
      } catch (e) {
        rethrow;
      }
    }

    try {
      final loginRes = await ref.read(accountClientProvider).loginWithGoogle(
            googleToken: googleToken,
          );

      if (loginRes) {
        ref.read(trackerProvider).trackPage(TrackPage.home);
      }

      return LoginAction.goHome;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> disconnectGoogle() async {
    // await _googleSignIn.signOut();
    await _googleSignIn.disconnect();
  }

  Future<void> handleNavigation({
    required LoginAction? action,
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    print("action $action");
    if (action == null) {
      return;
    }

    switch (action) {
      case LoginAction.goHome:
        await Navigator.of(context).pushReplacementNamed('/home');
        break;
      case LoginAction.goVerification:
        if (context.mounted) {
          await Navigator.pushNamed(context, '/register-verification',
              arguments: Tuple2(
                email,
                password,
              ));
        }
        break;
    }
  }

  Future<void> handleReSendToken({
    required Tuple2<String, String> emailPassword,
    required WidgetRef ref,
  }) async {
    print("resend token");
    try {
      await ref.read(accountClientProvider).resendValidateToken(
            email: emailPassword.item1,
            password: emailPassword.item2,
          );
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
