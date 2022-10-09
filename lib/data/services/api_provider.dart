// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:noted_mobile/data/services/noted_api.dart';

// class ApiProvider extends ChangeNotifier {
//   final NotedApi _notedApi = NotedApi();

//   bool isLoading = false;

//   void setLoading(bool value) {
//     isLoading = value;
//     notifyListeners();
//   }

//   Future<void> authentificate(
//     BuildContext ctx,
//     dynamic userData,
//   ) async {
//     setLoading(true);
//     try {
//       dynamic response = await _notedApi.authentificate(userData);
//       print(response);

//       notifyListeners();
//     } catch (e) {
//       print(e);
//       ScaffoldMessenger.of(ctx).showSnackBar(
//         SnackBar(
//           content: Text(e.toString()),
//         ),
//       );
//     } finally {
//       setLoading(false);
//     }
//   }
// }
