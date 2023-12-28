import 'package:dio/dio.dart';

class NotedException implements Exception {
  String message = "";

  NotedException.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.cancel:
        message = "Request to API server was cancelled"; // TODO: add traduction
        break;
      case DioExceptionType.connectionTimeout:
        message = "Connection timeout with API server"; // TODO: add traduction
        break;
      case DioExceptionType.connectionError:
        message =
            "Connection to API server failed due to internet connection"; // TODO: add traduction
        break;
      case DioExceptionType.receiveTimeout:
        message =
            "Receive timeout in connection with API server"; // TODO: add traduction
        break;
      case DioExceptionType.unknown:
        message = _handleError(
            dioException.response!.statusCode!, dioException.response?.data);
        break;
      case DioExceptionType.sendTimeout:
        message =
            "Send timeout in connection with API server"; // TODO: add traduction
        break;
      case DioExceptionType.badResponse:
        message = _handleError(
            dioException.response!.statusCode!, dioException.response?.data);
        break;
      default:
        message = "Something went wrong"; // TODO: add traduction
        break;
    }
  }

  String _handleError(int statusCode, dynamic error) {
    print("Error: $error");
    return error["error"];
  }

  @override
  String toString() => message;
}
