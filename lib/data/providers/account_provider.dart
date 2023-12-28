import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/clients/account_client.dart';
import 'package:noted_mobile/data/models/account/account.dart';

final accountClientProvider =
    Provider<AccountClient>((ref) => AccountClient(ref: ref));

final accountProvider =
    FutureProvider.family<Account?, String>(((ref, id) async {
  final account =
      await ref.watch(accountClientProvider).getAccountById(accountId: id);

  return account;
}));
