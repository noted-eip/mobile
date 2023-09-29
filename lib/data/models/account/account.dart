import 'package:noted_mobile/data/models/account/account_data.dart';
import 'package:openapi/openapi.dart';

class Account {
  Account({
    required this.data,
  });

  AccountData data;

  factory Account.fromApi(V1Account apiAccount) {
    return Account(
      data: AccountData.fromApi(apiAccount),
    );
  }
}
