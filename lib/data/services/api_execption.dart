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

  String? _translateError(String error) {
    switch (error) {
      case "wrong password or email":
        return "translate-error.wrongPasswordOrEmail".tr();
      case "not found":
        return "translate-error.notFound".tr();
      case "email: must be a valid email address.":
        return "translate-error.emailMustBeValid".tr();
      case "reset-token does not match":
        return "translate-error.resetTokenDoesNotMatch".tr();
      case "token: cannot be blank.":
        return "translate-error.tokenCannotBeBlank".tr();
      case "password: the length must be between 4 and 20.":
        return "translate-error.passwordLength".tr();
      case "validation-token does not match":
        return "translate-error.validationTokenDoesNotMatch".tr();
      case "already exists":
        return "translate-error.alreadyExists".tr();
      default:
        if (error.contains("google")) {
          return "translate-error.google".tr();
        }

        return null;
    }
  }

  String _handleError(int statusCode, dynamic error) {
    return _translateError(error["error"]) ?? error["error"];
  }

  @override
  String toString() => message;
}
