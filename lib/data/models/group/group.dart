// group.dart file
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:noted_mobile/data/models/group/group_data.dart';
import 'package:openapi/openapi.dart';

part 'group.g.dart';

@JsonSerializable()
class Group {
  Group({
    required this.data,
  });

  GroupData data;

  factory Group.fromRawJson(String str) => Group.fromJson(json.decode(str));

  factory Group.fromJson(Map<String, dynamic> json) => Group(
        data: GroupData.fromJson(json),
      );

  factory Group.fromApi(V1Group apiGroup) => Group(
        data: GroupData.fromApi(apiGroup),
      );
}
