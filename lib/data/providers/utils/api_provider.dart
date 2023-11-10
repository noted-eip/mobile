import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/openapi.dart';
// import 'package:pretty_dio_logger/pretty_dio_logger.dart';
// import 'package:pretty_dio_logger/pretty_dio_logger.dart';

const String applicationJson = "application/json";
const String contentType = "content-type";
const String accept = "accept";
const String defaultLang = "en";
const String kBaseUrl = "https://noted-rojasdiego.koyeb.app";

final apiProvider = Provider<DefaultApi>((ref) {
  // Map<String, String> headers = {
  //   contentType: applicationJson,
  //   accept: applicationJson,
  //   defaultLang: defaultLang
  // };

  // var options = BaseOptions(
  //   baseUrl: kBaseUrl,
  //   headers: headers,
  //   receiveTimeout: const Duration(seconds: 20),
  //   sendTimeout: const Duration(seconds: 20),
  //   connectTimeout: const Duration(seconds: 20),
  // );

  var dio = Dio(
    BaseOptions(
      baseUrl: kBaseUrl,
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  // var interceptor = [
  //   PrettyDioLogger(
  //     requestHeader: true,
  //     requestBody: true,
  //     responseHeader: true,
  //   )
  // ];
  // if (!kReleaseMode) {
  //   dio.interceptors.add(interceptor);
  // }

  return Openapi(
    dio: dio,
  ).getDefaultApi();
});
