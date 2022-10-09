// import 'package:dio/dio.dart';
// import 'package:noted_mobile/data/services/api_endpoints.dart';
// import 'package:noted_mobile/data/services/api_execption.dart';

// class DioClient {
//   static BaseOptions options = BaseOptions(
//     baseUrl: Endpoints.kBaseUrl,
//     connectTimeout: Endpoints.connectionTimeout,
//     receiveTimeout: Endpoints.receiveTimeout,
//   );
//   final Dio _dio = Dio(options);

//   Future<dynamic> post(String url,
//       {Map<String, dynamic>? headers, dynamic data}) async {
//     try {
//       final response =
//           await _dio.post(url, data: data, options: Options(headers: headers));
//       print('response in dioClient ' + response.data);
//       return response.data;
//     } on DioError catch (e) {
//       return DioExceptions.fromDioError(e).toString();
//     }
//   }

//   Future<dynamic> get(String url, {Map<String, dynamic>? headers}) async {
//     try {
//       final Response response = await _dio.get(
//         url,
//         options: Options(headers: headers),
//       );
//       print('response in dioClient ' + response.data);
//       return response.data;
//     } on DioError catch (e) {
//       return DioExceptions.fromDioError(e).toString();
//     }
//   }
// }
