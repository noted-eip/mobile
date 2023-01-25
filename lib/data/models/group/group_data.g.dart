// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unused_element

part of 'group_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupData _$GroupDataFromJson(Map<String, dynamic> json) => GroupData(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      created_at: json['created_at'] as String,
      members: (json['members'] as List<dynamic>?)
          ?.map((e) => GroupMember.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GroupDataToJson(GroupData instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'created_at': instance.created_at,
      'members': instance.members,
    };

GroupMember _$GroupMemberFromJson(Map<String, dynamic> json) => GroupMember(
      account_id: json['account_id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String,
      created_at: json['created_at'] as String,
    );

Map<String, dynamic> _$GroupMemberToJson(GroupMember instance) =>
    <String, dynamic>{
      'account_id': instance.account_id,
      'role': instance.role,
      'created_at': instance.created_at,
      'name': instance.name,
      'email': instance.email,
    };
