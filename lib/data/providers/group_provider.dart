import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/clients/group_client.dart';
import 'package:noted_mobile/data/models/group/group.dart';
import 'package:noted_mobile/data/models/group/group_data.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';

final groupClientProvider = Provider<GroupClient>((ref) => GroupClient());

final groupsProvider = FutureProvider<List<Group>?>((ref) async {
  final account = ref.watch(userProvider);
  final search = ref.watch(searchProvider);
  final grouplist = await ref
      .watch(groupClientProvider)
      .listGroups(account.id, account.token, offset: 0, limit: 20);

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

final latestGroupsProvider = FutureProvider<List<Group>?>((ref) async {
  final account = ref.watch(userProvider);
  final grouplist = await ref
      .watch(groupClientProvider)
      .listGroups(account.id, account.token, offset: 0, limit: 2);

  return grouplist;
});

final groupProvider =
    FutureProvider.family<Group?, String>((ref, groupId) async {
  final account = ref.watch(userProvider);
  final group =
      await ref.watch(groupClientProvider).getGroup(groupId, account.token);

  return group;
});

final groupMembersProvider =
    FutureProvider.family<List<GroupMember>?, String>((ref, groupId) async {
  final account = ref.watch(userProvider);
  final groupMembers = await ref
      .watch(groupClientProvider)
      .listGroupMembers(groupId, account.token);

  return groupMembers;
});
