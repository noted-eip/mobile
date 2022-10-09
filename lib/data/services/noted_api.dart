// import 'package:noted_mobile/data/services/api_endpoints.dart';
// import 'package:noted_mobile/data/services/dio_client.dart';

// class NotedApi {
//   final DioClient _client = DioClient();

//   Future<dynamic> authentificate(dynamic userData) async {
//     print("authentificate");
//     final response = await _client.post(
//       Endpoints.authentificate,
//       data: userData,
//     );
//     print(response + 'response');
//     return response;
//   }

//   Future<dynamic> getUserInfos(
//       String userUuid, Map<String, dynamic> headers) async {
//     final response = await _client.get(
//       Endpoints.accounts + userUuid,
//       headers: headers,
//     );
//     return response;
//   }

//   // Future<UserProfile> getUserProfile({String username}) async {
//   //   try {
//   //     final response = await _client.get('${Endpoints.usersProfile}/$username');
//   //     return UserProfile.fromJson(response);
//   //   } catch (e) {
//   //     throw e;
//   //   }
//   // }

//   // Future<List<Repos>> getRepos({String username}) async {
//   //   try {
//   //     final List response = await _client
//   //         .get('${Endpoints.usersProfile}/$username/${Endpoints.repos}');

//   //     return response.map((item) => Repos.fromMap(item)).toList();
//   //   } catch (e) {
//   //     throw e;
//   //   }
//   // }
// }
