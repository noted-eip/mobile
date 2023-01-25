// user_data.dart file

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'account_data.g.dart';

@JsonSerializable()
class AccountData {
  AccountData({
    required this.id,
    required this.email,
    required this.token,
    required this.name,
  });

  final String name;
  final String email;
  final String token;
  final String id;

  factory AccountData.fromRawJson(String str) =>
      AccountData.fromJson(json.decode(str));

  factory AccountData.fromJson(Map<String, dynamic> json) {
    return AccountData(
      id: json["id"] ?? "",
      email: json["email"] ?? "",
      token: json["token"] ?? "",
      name: json["name"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "token": token,
        "id": id,
      };
}
