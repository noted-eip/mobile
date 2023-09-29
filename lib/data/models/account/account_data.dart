import 'package:openapi/openapi.dart';

class AccountData {
  AccountData({
    required this.id,
    required this.email,
    required this.name,
  });

  final String name;
  final String email;
  final String id;

  factory AccountData.fromApi(V1Account apiAccount) {
    return AccountData(
      id: apiAccount.id,
      email: apiAccount.email,
      name: apiAccount.name,
    );
  }
}
