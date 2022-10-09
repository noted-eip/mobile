// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:noted_mobile/data/services/api_execption.dart';
import 'package:noted_mobile/utils/constant.dart';

class APIHelper {
  final Dio dio;

  APIHelper({required this.dio}) {
    //
  }

  //for api helper testing only
  APIHelper.test({required this.dio});

  // ignore: unused_element
  void initApiClient() {
    print("initApiClient");
    dio.options.baseUrl = kBaseUrl;
    // ..options.headers.addAll({'parameter': 'parameter'})
  }

  Future<dynamic> get(String url, {Map<String, dynamic>? headers}) async {
    try {
      final response = await dio.get(url, options: Options(headers: headers));
      final String res = json.encode(response.data);

      print('[API Helper - GET] Server Response: $res');

      return {'statusCode': response.statusCode, 'data': response.data};
    } on DioError catch (e) {
      return {
        'error': DioExceptions.fromDioError(e).toString(),
        'statusCode': e.response!.statusCode
      };
    }
  }

  Future<dynamic> post(String url,
      {Map<String, dynamic>? headers, dynamic body}) async {
    try {
      print('[API Helper - POST] Server Request: $body');

      final response =
          await dio.post(url, data: body, options: Options(headers: headers));

      final String res = json.encode(response.data);
      print('[API Helper - POST] Server Response: $res');

      return {'statusCode': response.statusCode, 'data': response.data};
    } on DioError catch (e) {
      return {
        'error': DioExceptions.fromDioError(e).toString(),
        'statusCode': e.response!.statusCode
      };
    }
  }
}
