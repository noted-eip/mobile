import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/utils/constant.dart';
import 'package:openapi/openapi.dart';

final apiProvider = Provider<DefaultApi>(
  (ref) => Openapi(
    dio: Dio(
      BaseOptions(
        baseUrl: kBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    ),
  ).getDefaultApi(),
);
