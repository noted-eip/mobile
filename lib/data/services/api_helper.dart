//TODO: handle error : eg: https://medium.com/flutter-community/handling-network-calls-like-a-pro-in-flutter-31bd30c86be1
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:noted_mobile/data/services/api_execption.dart';
import 'package:noted_mobile/data/services/api_response.dart';
import 'package:noted_mobile/utils/constant.dart';

class APIHelper {
  final Dio dio;

  APIHelper({required this.dio});

  APIHelper.test({required this.dio});

  void initApiClient() {
    if (kDebugMode) {
      print("initApiClient");
    }
    dio.options.baseUrl = kBaseUrl;
  }

  Future<ApiResponse> get(String url,
      {Map<String, dynamic>? headers,
      Map<String, dynamic>? queryParams}) async {
    if (kDebugMode) {
      print(
          '[API Helper - GET] Server Request: $url,headers: $headers, queryParams: $queryParams');
    }
    try {
      final response = await dio.get(url,
          options: Options(headers: headers), queryParameters: queryParams);
      final String res = json.encode(response.data);

      if (kDebugMode) {
        print('[API Helper - GET] Server Response: $res');
      }

      return ApiResponse(statusCode: response.statusCode, data: response.data);
    } on DioException catch (e) {
      return ApiResponse(
          statusCode: e.response!.statusCode,
          error: DioExceptions.fromDioError(e).toString());
    }
  }

  Future<ApiResponse> post(String url,
      {Map<String, dynamic>? headers, dynamic body}) async {
    try {
      if (kDebugMode) {
        print('[API Helper - POST] Server Request: $body');
      }

      final response =
          await dio.post(url, data: body, options: Options(headers: headers));

      final String res = json.encode(response.data);
      if (kDebugMode) {
        print('[API Helper - POST] Server Response: $res');
      }

      return ApiResponse(statusCode: response.statusCode, data: response.data);
    } on DioException catch (e) {
      return ApiResponse(
          error: DioExceptions.fromDioError(e).toString(),
          statusCode: e.response!.statusCode);
    }
  }

  Future<ApiResponse> patch(String url,
      {Map<String, dynamic>? headers, dynamic body}) async {
    try {
      if (kDebugMode) {
        print('[API Helper - PUT] Server Request: $body');
        print('[API Helper - PUT] Server Request: $headers');
        print('[API Helper - PUT] Server Request: $url');
      }

      final response =
          await dio.patch(url, data: body, options: Options(headers: headers));

      final String res = json.encode(response.data);
      if (kDebugMode) {
        print('[API Helper - PUT] Server Response: $res');
      }
      return ApiResponse(statusCode: response.statusCode, data: response.data);
    } on DioException catch (e) {
      return ApiResponse(
          error: DioExceptions.fromDioError(e).toString(),
          statusCode: e.response!.statusCode);
    }
  }

  Future<ApiResponse> delete(String url,
      {Map<String, dynamic>? headers, dynamic body}) async {
    try {
      if (kDebugMode) {
        print('[API Helper - DELETE] Server Request: $body');
      }

      final response =
          await dio.delete(url, data: body, options: Options(headers: headers));

      final String res = json.encode(response.data);
      if (kDebugMode) {
        print('[API Helper - DELETE] Server Response: $res');
      }
      return ApiResponse(statusCode: response.statusCode, data: response.data);
    } on DioException catch (e) {
      if (kDebugMode) {
        print('[API Helper - DELETE] Server Response: ${e.toString()}');
      }
      return ApiResponse(
        error: DioExceptions.fromDioError(e).toString(),
        statusCode: e.response!.statusCode,
      );
    }
  }
}
