// user_data.dart file

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:openapi/openapi.dart';

part 'account_data.g.dart';

@JsonSerializable()
class AccountData {
  AccountData({
    required this.id,
    required this.email,
    required this.name,
  });

  final String name;
  final String email;
  final String id;

  factory AccountData.fromRawJson(String str) =>
      AccountData.fromJson(json.decode(str));

  factory AccountData.fromJson(Map<String, dynamic> json) {
    return AccountData(
      id: json["id"] ?? "",
      email: json["email"] ?? "",
      name: json["name"] ?? "",
    );
  }

  factory AccountData.fromApi(V1Account apiAccount) {
    return AccountData(
      id: apiAccount.id,
      email: apiAccount.email,
      name: apiAccount.name,
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "id": id,
      };
}
