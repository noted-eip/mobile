import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/clients/invite_client.dart';
import 'package:noted_mobile/data/providers/cache_timeout.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/pages/notification_page.dart';

final inviteClientProvider = Provider<InviteClient>((ref) => InviteClient());

final sendInvitesProvider =
    FutureProvider.autoDispose<List<Invite>?>((ref) async {
  final account = ref.watch(userProvider);
  final inviteList = await ref.watch(inviteClientProvider).listInvites(
        account.token,
        senderId: account.id,
        // offset: 0,
        // limit: 20,
      );
  cacheTimeout(ref, 'fetchSendInvites', hour: 0, minute: 1, seconde: 0);

  return inviteList;
});

final receiveInvitesProvider =
    FutureProvider.autoDispose<List<Invite>?>((ref) async {
  final account = ref.watch(userProvider);
  final inviteList = await ref.watch(inviteClientProvider).listInvites(
        account.token,
        recipientId: account.id,
        // offset: 0,
        // limit: 20,
      );

  cacheTimeout(ref, 'fetchReceiveInvites', hour: 0, minute: 1, seconde: 0);

  return inviteList;
});

final groupInvitesProvider = FutureProvider.autoDispose
    .family<List<Invite>?, String>((ref, groupId) async {
  final account = ref.watch(userProvider);
  final inviteList = await ref.watch(inviteClientProvider).listInvites(
        account.token,
        groupId: groupId,
        // offset: 0,
        // limit: 20,
      );

  cacheTimeout(ref, 'fetchGroupInvites: $groupId', hour: 0, minute: 1);

  return inviteList;
});
