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

  String _handleError(int statusCode, dynamic error) {
    return error["error"];
  }

  @override
  String toString() => message;
}

// 'wrong password or email'
// 'not found'
// 'email: must be a valid email address.'
// 'reset-token does not match'
// 'token: cannot be blank.'
// 'password: the length must be between 4 and 20.'
// 'validation-token does not match'