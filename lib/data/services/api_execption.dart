import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';

class NotedException implements Exception {
  String message = "";

  NotedException.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.cancel:
        message = "error.cancel".tr();
        break;
      case DioExceptionType.connectionTimeout:
        message = "error.connectionTimeout".tr();
        break;
      case DioExceptionType.connectionError:
        message = "error.connectionError".tr();
        break;
      case DioExceptionType.receiveTimeout:
        message = "error.receiveTimeout".tr();
        break;
      case DioExceptionType.unknown:
        message = _handleError(
            dioException.response!.statusCode!, dioException.response?.data);
        break;
      case DioExceptionType.sendTimeout:
        message = "error.sendTimeout".tr();
        break;
      case DioExceptionType.badResponse:
        message = _handleError(
            dioException.response!.statusCode!, dioException.response?.data);
        break;
      default:
        message = "error.default".tr();
        break;
    }
  }

  String _translateError(String error) {
    if (error.contains("account created with google (no password)")) {
      return "translate-error.accountCreatedWithGoogle".tr();
    }
    // else if (error.contains("google")) {
    //   print(error);
    //   return "translate-error.google".tr();
    // }
    else if (error.contains("length must be between 4 and 20")) {
      return "translate-error.passwordLength".tr();
    } else if (error.contains("account already validate")) {
      return "translate-error.accountAlreadyValidate".tr();
    } else if (error.contains("permission denied")) {
      return "translate-error.permissionDenied".tr();
    } else if (error.contains("length must be between 1 and 64")) {
      return "translate-error.lengthMustBeBetween1And64".tr();
    } else if (error.contains("wrong password or email")) {
      return "translate-error.wrongPasswordOrEmail".tr();
    } else if (error.contains("not found")) {
      return "translate-error.notFound".tr();
    } else if (error.contains("email: must be a valid email address")) {
      return "translate-error.emailMustBeValid".tr();
    } else if (error.contains("reset-token does not match")) {
      return "translate-error.resetTokenDoesNotMatch".tr();
    } else if (error.contains("token: cannot be blank")) {
      return "translate-error.tokenCannotBeBlank".tr();
    } else if (error.contains("validation-token does not match")) {
      return "translate-error.validationTokenDoesNotMatch".tr();
    } else if (error.contains("already exists")) {
      return "translate-error.alreadyExists".tr();
    } else {
      return "translate-error.default".tr();
    }
  }

  String _handleError(int statusCode, dynamic error) {
    return _translateError(error["error"]);
  }

  @override
  String toString() => message;
}
