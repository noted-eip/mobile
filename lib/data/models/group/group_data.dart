// user_data.dart file

// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'group_data.g.dart';

@JsonSerializable()
class GroupData {
  const GroupData({
    required this.id,
    required this.name,
    required this.description,
    required this.created_at,
    this.members,
  });

  final String id;
  final String name;
  final String description;
  final String created_at;
  final List<GroupMember>? members;

  factory GroupData.fromRawJson(String str) =>
      GroupData.fromJson(json.decode(str));

  factory GroupData.fromJson(Map<String, dynamic> json) {
    return GroupData(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      created_at: json["created_at"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "created_at": created_at,
      };
}

@JsonSerializable()
class GroupMember {
  GroupMember({
    required this.account_id,
    required this.name,
    required this.email,
    required this.role,
    required this.created_at,
  });

  final String account_id;
  final String role;
  final String created_at;
  String? name;
  String? email;

  factory GroupMember.fromRawJson(String str) =>
      GroupMember.fromJson(json.decode(str));

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      account_id: json["account_id"] ?? "",
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      created_at: json["created_at"] ?? "",
      role: json["role"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "account_id": account_id,
        "name": name,
        "email": email,
        "created_at": created_at,
        "role": role,
      };

  GroupMember copyWith({
    String? account_id,
    String? name,
    String? email,
    String? role,
    String? created_at,
  }) {
    return GroupMember(
      account_id: account_id ?? this.account_id,
      name: name ?? this.name,
      email: email ?? this.email,
      created_at: created_at ?? this.created_at,
      role: role ?? this.role,
    );
  }
}
