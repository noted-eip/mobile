// ignore_for_file: avoid_print
import 'package:easy_localization/easy_localization.dart';

// ### check secu

// name : entre 4 et 20
// password : min 4 et 20
// email: valid

// code confirmation : 4 chiffres -> forgot pass et validation account

class NotedValidator {
  static String? validateToken(String? value) {
    if (value!.length < 4) {
      return 'forgot.step2.validator'.tr();
    } else {
      return null;
    }
  }

  static String? validateName(String? value) {
    print("validateName");
    if (value == null || value.isEmpty) {
      return 'validator.name-empty'.tr();
    } else if (value.length < 4 || value.length > 20) {
      return 'validator.name-length'.tr();
    }
    return null;
  }

  static String? validateEmail(String? value) {
    print("validateEmail");

    if (value == null || value.isEmpty) {
      return 'validator.email-empty'.tr();
    }

    final emailValidator = RegExp(
      r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$',
    );

    if (!emailValidator.hasMatch(value)) {
      return 'validator.email-valid'.tr();
    }
    return null;
  }

  static String? validatePassword(String? value) {
    print("validatePassword");
    if (value == null || value.isEmpty) {
      return 'validator.password-empty'.tr();
    } else if (value.length < 4 || value.length > 20) {
      return 'validator.password-length'.tr();
    }

    return null;
  }

  static String? validateCode(String? value) {
    print("validateCode");
    if (value == null || value.isEmpty) {
      return 'validator.code-empty'.tr();
    } else if (value.length != 4) {
      return 'validator.code-length'.tr();
    }

    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    print("validateConfirmPassword");
    if (value == null || value.isEmpty) {
      return 'validator.password-empty'.tr();
    }
    if (value != password) {
      return 'validator.password-match'.tr();
    }
    return null;
  }
}
