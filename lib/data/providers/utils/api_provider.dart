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
  var dio = Dio(
    BaseOptions(
      baseUrl: kBaseUrl,
      // receiveTimeout: const Duration(seconds: 50),
      // connectTimeout: const Duration(seconds: 50),
      // sendTimeout: const Duration(seconds: 50),
    ),
  );

  return Openapi(
    dio: dio,
  ).getDefaultApi();
});
