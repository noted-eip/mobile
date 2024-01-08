import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/clients/group_client.dart';
import 'package:noted_mobile/data/models/group/group.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:openapi/openapi.dart';

final groupClientProvider =
    Provider<GroupClient>((ref) => GroupClient(ref: ref));

final groupsProvider = FutureProvider<List<Group>?>((ref) async {
  final account = ref.watch(userProvider);
  final search = ref.watch(searchProvider);
  final grouplist = await ref
      .watch(groupClientProvider)
      .listGroups(accountId: account.id, offset: 0, limit: 20);

  if (search == "") {
    return grouplist;
  } else {
    return grouplist
        ?.where((group) =>
            group.data.name.toLowerCase().contains(search.toLowerCase()))
        .toList();
  }
});

final searchProvider = StateProvider((ref) => '');

final workspaceIdProvider = FutureProvider<String>((ref) async {
  final account = ref.watch(userProvider);
  final grouplist =
      await ref.watch(groupClientProvider).listGroups(accountId: account.id);

  print(grouplist);

  var workspace = grouplist
      ?.firstWhere((element) =>
          element.data.workspaceAccountId != null &&
          element.data.workspaceAccountId != "")
      .data;

  print(workspace?.name);
  print(workspace?.workspaceAccountId);

  return workspace?.id ?? "";
});

final latestGroupsProvider = FutureProvider<List<Group>?>((ref) async {
  final account = ref.watch(userProvider);
  final grouplist = await ref
      .watch(groupClientProvider)
      .listGroups(accountId: account.id, offset: 0, limit: 2);

  return grouplist;
});

final groupProvider =
    FutureProvider.family<V1Group?, String>((ref, groupId) async {
  final group = await ref.watch(groupClientProvider).getGroup(groupId: groupId);

  return group;
});

final groupMemberProvider =
    FutureProvider.family<V1GroupMember?, String>((ref, groupId) async {
  final account = ref.watch(userProvider);
  final user = ref.watch(userProvider);

  final groupMember = await ref.watch(groupClientProvider).getGroupMember(
        groupId: groupId,
        memberId: user.id,
        token: account.token,
      );

  return groupMember;
});

final groupActivitiesProvider =
    FutureProvider.family<List<V1GroupActivity>?, String>((ref, groupId) async {
  final activities = await ref
      .watch(groupClientProvider)
      .getGroupsActivities(groupId: groupId);

  return activities;
});
