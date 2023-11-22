import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:noted_mobile/components/common/custom_toast.dart';
import 'package:noted_mobile/components/common/loading_button.dart';
import 'package:noted_mobile/data/clients/tracker_client.dart';
import 'package:noted_mobile/data/providers/account_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/utils/string_extension.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:tuple/tuple.dart';

class AccountHelper {
  AccountHelper();

  Future<void> handleSendToken({
    required Tuple2<String, String> emailPassword,
    required WidgetRef ref,
    required BuildContext context,
    required bool isRegister,
  }) async {
    try {
      if (!isRegister) {
        await ref.read(accountClientProvider).resendValidateToken(
              email: emailPassword.item1,
              password: emailPassword.item2,
            );
      }
    } catch (e) {
      CustomToast.show(
        message: e.toString().capitalize(),
        type: ToastType.error,
        context: context,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
    required RoundedLoadingButtonController btnController,
    required WidgetRef ref,
    required bool isRegister,
  }) async {
    bool? isValidate = await isValidateAccount(
      email: email,
      password: password,
      context: context,
      ref: ref,
    );

    if (isValidate == null) {
      btnController.error();
      resetButton(btnController);
      return;
    }

    print('isValidate: $isValidate');

    if (!isValidate) {
      btnController.reset();

      await handleSendToken(
          emailPassword: Tuple2(email, password),
          ref: ref,
          context: context,
          isRegister: isRegister);

      Navigator.pushNamed(context, '/register-verification',
          arguments: Tuple2(
            email,
            password,
          ));
      return;
    } else {
      try {
        final loginRes = await ref.read(accountClientProvider).login(
              email: email,
              password: password,
            );
        if (loginRes) {
          ref.read(trackerProvider).trackPage(TrackPage.home);
          Navigator.of(context).pushReplacementNamed('/home');
        }

        btnController.success();
      } catch (e) {
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
  }

  Future<bool?> isValidateAccount({
    required String email,
    required String password,
    required BuildContext context,
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
      // if (mounted) {
      CustomToast.show(
        message: e.toString().capitalize(),
        type: ToastType.error,
        context: context,
        gravity: ToastGravity.BOTTOM,
      );
      // }
      return null;
    }
    // return false;
  }
}
