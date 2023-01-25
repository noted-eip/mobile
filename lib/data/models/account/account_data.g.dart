// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unused_element

part of 'account_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountData _$AccountDataFromJson(Map<String, dynamic> json) => AccountData(
      id: json['id'] as String,
      email: json['email'] as String,
      token: json['token'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$AccountDataToJson(AccountData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'token': instance.token,
      'id': instance.id,
    };
