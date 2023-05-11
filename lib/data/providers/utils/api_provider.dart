import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/utils/constant.dart';
import 'package:openapi/openapi.dart';

final apiProvider = Provider<DefaultApi>(
  (ref) => Openapi(
    dio: Dio(
      BaseOptions(
        baseUrl: kBaseUrl,
        connectTimeout: const Duration(milliseconds: 5000),
        receiveTimeout: const Duration(milliseconds: 3000),
      ),
    ),
  ).getDefaultApi(),
);
