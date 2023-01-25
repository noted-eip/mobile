import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/common/custom_alerte.dart';
import 'package:noted_mobile/components/group_member_card_widget.dart';
import 'package:noted_mobile/components/slide_widget.dart';
import 'package:noted_mobile/data/models/group/group_data.dart';
import 'package:noted_mobile/data/providers/group_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:shimmer/shimmer.dart';

typedef MemberCallback = void Function(String accountId);

class GroupMembersList extends ConsumerStatefulWidget {
  const GroupMembersList({
    required this.leaveGroup,
    required this.deleteGroupMember,
    required this.groupId,
    super.key,
  });

  final MemberCallback leaveGroup;
  final MemberCallback deleteGroupMember;
  final String groupId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GroupMembersListState();
}

class _GroupMembersListState extends ConsumerState<GroupMembersList> {
  Future<void> editRoleModal(
      String userTkn, String accountId, String groupId) async {
    return await showDialog(
      context: context,
      builder: ((context) => CustomAlertDialog(
            title: "Edit Role",
            content: "Select a new role for this member",
            onConfirm: () async {
              await editGroupMemberRole(userTkn, accountId, groupId, "admin");
            },
          )),
    );
  }

  Future<void> editGroupMemberRole(
      String userTkn, String accountId, String groupId, String role) async {
    try {
      GroupMember? member = await ref
          .read(groupClientProvider)
          .updateGroupMember(groupId, accountId, role, userTkn);

      if (member == null) {
        return;
      }

      if (mounted) {
        Navigator.pop(context);
      }
      ref.invalidate(groupMembersProvider(widget.groupId));
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<GroupMember>?> groupMembers =
        ref.watch(groupMembersProvider(widget.groupId));
    final user = ref.read(userProvider);

    return groupMembers.when(
      data: (members) {
        if (members == null) {
          return const Center(
            child: Text("No members"),
          );
        }
        return RefreshIndicator(
          displacement: 0,
          onRefresh: () async {
            ref.invalidate(groupMembersProvider(widget.groupId));
          },
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: members.length,
            itemBuilder: (context, index) {
              final GroupMember member = members[index];
              List<ActionSlidable> adminActions = [
                ActionSlidable(
                  Icons.delete,
                  Colors.red,
                  (() async {
                    if (kDebugMode) {
                      print("delete");
                      print(member.account_id);
                      print(member.name);
                      print(member);
                    }

                    bool isLeave = member.account_id == user.id;

                    if (isLeave) {
                      widget.leaveGroup(member.account_id);
                    } else {
                      widget.deleteGroupMember(member.account_id);
                    }
                  }),
                ),
                ActionSlidable(
                  Icons.edit,
                  Colors.grey,
                  (() async {
                    if (kDebugMode) {
                      print("Edit");
                    }
                    await editRoleModal(
                      user.token,
                      member.account_id,
                      widget.groupId,
                    );
                  }),
                ),
              ];
              List<ActionSlidable> userActions = [];
              bool isUserAdmin = members
                      .firstWhere((element) => element.account_id == user.id)
                      .role ==
                  "admin";

              return GroupMemberCard(
                  member: member,
                  actions: isUserAdmin ? adminActions : userActions);
            },
          ),
        );
      },
      loading: () {
        return ListView(
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey[800]!,
              highlightColor: Colors.grey[600]!,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                height: 70,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            Shimmer.fromColors(
              baseColor: Colors.grey[800]!,
              highlightColor: Colors.grey[600]!,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                height: 70,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        );
      },
      error: (error, stack) => const Center(
        child: Text("Error"),
      ),
    );
  }
}
