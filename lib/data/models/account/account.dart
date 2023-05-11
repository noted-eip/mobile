// account.dart file
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:noted_mobile/data/models/account/account_data.dart';
import 'package:openapi/openapi.dart';

part 'account.g.dart';

@JsonSerializable()
class Account {
  Account({
    required this.data,
  });

  AccountData data;

  factory Account.fromRawJson(String str) => Account.fromJson(json.decode(str));

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      data: AccountData.fromJson(json),
    );
  }

  factory Account.fromApi(V1Account apiAccount) {
    return Account(
      data: AccountData.fromApi(apiAccount),
    );
  }
}
