import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/clients/invite_client.dart';
import 'package:noted_mobile/data/models/invite/invite.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';

final inviteClientProvider =
    Provider<InviteClient>((ref) => InviteClient(ref: ref));

final sendInvitesProvider = FutureProvider<List<Invite>?>((ref) async {
  final account = ref.watch(userProvider);
  final inviteList = await ref.watch(inviteClientProvider).listInvites(
        token: account.token,
        senderId: account.id,
      );

  return inviteList;
});

final receiveInvitesProvider = FutureProvider<List<Invite>?>((ref) async {
  final account = ref.watch(userProvider);
  final inviteList = await ref.watch(inviteClientProvider).listInvites(
        token: account.token,
        recipientId: account.id,
      );
  return inviteList;
});

final groupInvitesProvider =
    FutureProvider.family<List<Invite>?, String>((ref, groupId) async {
  final account = ref.watch(userProvider);
  final inviteList = await ref.watch(inviteClientProvider).listInvites(
        token: account.token,
        groupId: groupId,
      );
  return inviteList;
});
