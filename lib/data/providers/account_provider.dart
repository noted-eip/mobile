import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/clients/account_client.dart';
import 'package:noted_mobile/data/models/account/account.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';

final accountClientProvider = Provider<AccountClient>((ref) => AccountClient());

final accountProvider =
    FutureProvider.family<Account?, String>(((ref, id) async {
  final user = ref.watch(userProvider);
  final account =
      await ref.watch(accountClientProvider).getAccountById(id, user.token);

  return account;
}));
