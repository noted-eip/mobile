// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:noted_mobile/utils/format_helper.dart';
import 'package:openapi/openapi.dart';

class GroupData {
  const GroupData({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    this.workspaceAccountId,
    required this.avatarUrl,
    this.modifiedAt,
    this.conversations,
    this.invites,
    this.inviteLinks,
    this.members,
    this.activities,
  });

  final String id;
  final String name;
  final String description;
  final String? workspaceAccountId;
  final String avatarUrl;
  final DateTime createdAt;
  final DateTime? modifiedAt;
  final List<V1GroupConversation>? conversations;
  final List<V1GroupInvite>? invites;
  final List<V1GroupInviteLink>? inviteLinks;
  final List<V1GroupActivity>? activities;
  final List<V1GroupMember>? members;

  factory GroupData.fromRawJson(String str) =>
      GroupData.fromJson(json.decode(str));

  factory GroupData.fromJson(Map<String, dynamic> json) {
    return GroupData(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      avatarUrl: '',
      createdAt: json["created_at"] != null
          ? formatStringToDateTime(json["created_at"])
          : DateTime.now(),
      modifiedAt: json["modified_at"] != null
          ? formatStringToDateTime(json["modified_at"])
          : null,
      workspaceAccountId: json["workspace_account_id"] ?? "",
      conversations: null,
      invites: [],
      inviteLinks: [],
      activities: [],
      members: [],
    );
  }

  factory GroupData.fromApi(V1Group apiGroup) {
    apiGroup.members;
    return GroupData(
      id: apiGroup.id,
      name: apiGroup.name,
      description: apiGroup.description,
      avatarUrl: apiGroup.avatarUrl,
      createdAt: apiGroup.createdAt,
      modifiedAt: apiGroup.modifiedAt,
      workspaceAccountId: apiGroup.workspaceAccountId,
      conversations: apiGroup.conversations == null
          ? []
          : apiGroup.conversations!.map((e) => e).toList(),
      invites: apiGroup.invites == null
          ? []
          : apiGroup.invites!.map((e) => e).toList(),
      inviteLinks: apiGroup.inviteLinks == null
          ? []
          : apiGroup.inviteLinks!.map((e) => e).toList(),
      activities: apiGroup.activities == null
          ? []
          : apiGroup.activities!.map((e) => e).toList(),
      members: apiGroup.members == null
          ? []
          : apiGroup.members!.map((e) => e).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "created_at": createdAt,
      };
}

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
