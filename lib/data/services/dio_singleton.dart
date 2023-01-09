import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:noted_mobile/data/services/api_helper.dart';

final singleton = GetIt.instance;

Future<void> init() async {
  singleton.registerLazySingleton<APIHelper>(
    () => APIHelper(dio: singleton()),
  );
  singleton.registerLazySingleton(() => Dio());
}
