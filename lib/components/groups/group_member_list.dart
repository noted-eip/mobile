import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:noted_mobile/components/common/custom_alerte.dart';
import 'package:noted_mobile/components/common/custom_toast.dart';
import 'package:noted_mobile/components/groups/card/group_member_card.dart';
import 'package:noted_mobile/components/common/custom_slide.dart';
import 'package:noted_mobile/data/providers/group_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/utils/string_extension.dart';
import 'package:openapi/openapi.dart';

typedef MemberCallback = void Function(String accountId);

class GroupMembersList extends ConsumerStatefulWidget {
  const GroupMembersList({
    required this.leaveGroup,
    required this.deleteGroupMember,
    required this.groupId,
    this.isPadding,
    required this.members,
    super.key,
  });

  final MemberCallback leaveGroup;
  final MemberCallback deleteGroupMember;
  final String groupId;
  final bool? isPadding;
  final List<V1GroupMember>? members;

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
            content: "Promote this user to admin ?",
            confirmText: "Promote",
            onConfirm: () async {
              await editGroupMemberRole(userTkn, accountId, groupId, true);
            },
          )),
    );
  }

  Future<void> editGroupMemberRole(
      String userTkn, String accountId, String groupId, bool isAdmin) async {
    try {
      V1GroupMember? member = await ref
          .read(groupClientProvider)
          .updateGroupMember(groupId, accountId, isAdmin, userTkn);

      if (member == null) {
        return;
      }

      if (mounted) {
        //TODO: Check if this is needed
        // Navigator.pop(context);
        CustomToast.show(
          message: "Role updated successfully !",
          type: ToastType.success,
          context: context,
          gravity: ToastGravity.BOTTOM,
        );
      }

      ref.invalidate(groupProvider(widget.groupId));
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      CustomToast.show(
        message: e.toString().capitalize(),
        type: ToastType.error,
        context: context,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider);

    if (widget.members == null) {
      return const Center(
        child: Text("No members"),
      );
    } else {
      return Container(
        padding: widget.isPadding != null && !widget.isPadding!
            ? const EdgeInsets.all(0)
            : const EdgeInsets.all(16),
        child: RefreshIndicator(
          displacement: 0,
          onRefresh: () async {
            ref.invalidate(groupProvider(widget.groupId));
          },
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: widget.members!.length,
            itemBuilder: (context, index) {
              final V1GroupMember member = widget.members![index];
              List<ActionSlidable> adminActions = [
                ActionSlidable(
                  Icons.delete,
                  Colors.red,
                  (() async {
                    if (kDebugMode) {
                      print("delete");
                      print(member.accountId);

                      print(member);
                    }

                    bool isLeave = member.accountId == user.id;

                    if (isLeave) {
                      widget.leaveGroup(member.accountId);
                    } else {
                      widget.deleteGroupMember(member.accountId);
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
                      member.accountId,
                      widget.groupId,
                    );
                  }),
                ),
              ];
              List<ActionSlidable> userActions = [];
              bool isUserAdmin = widget.members!
                  .firstWhere((element) => element.accountId == user.id)
                  .isAdmin;

              return GroupMemberCard(
                  memberData: widget.members![index],
                  actions: isUserAdmin ? adminActions : userActions);
            },
          ),
        ),
      );
    }

    // return Container(
    //   padding: widget.isPadding != null && !widget.isPadding!
    //       ? const EdgeInsets.all(0)
    //       : const EdgeInsets.all(16),
    //   child: groupMembers.when(
    //     data: (members) {
    //       if (widget.members == null) {
    //         return const Center(
    //           child: Text("No members"),
    //         );
    //       }
    //       return RefreshIndicator(
    //         displacement: 0,
    //         onRefresh: () async {
    //           ref.invalidate(groupMembersProvider(widget.groupId));
    //         },
    //         child: ListView.builder(
    //           padding: EdgeInsets.zero,
    //           itemCount: widget.members!.length,
    //           itemBuilder: (context, index) {
    //             final V1GroupMember member = widget.members![index];
    //             List<ActionSlidable> adminActions = [
    //               ActionSlidable(
    //                 Icons.delete,
    //                 Colors.red,
    //                 (() async {
    //                   if (kDebugMode) {
    //                     print("delete");
    //                     print(member.accountId);

    //                     print(member);
    //                   }

    //                   bool isLeave = member.accountId == user.id;

    //                   if (isLeave) {
    //                     widget.leaveGroup(member.accountId);
    //                   } else {
    //                     widget.deleteGroupMember(member.accountId);
    //                   }
    //                 }),
    //               ),
    //               ActionSlidable(
    //                 Icons.edit,
    //                 Colors.grey,
    //                 (() async {
    //                   if (kDebugMode) {
    //                     print("Edit");
    //                   }
    //                   await editRoleModal(
    //                     user.token,
    //                     member.accountId,
    //                     widget.groupId,
    //                   );
    //                 }),
    //               ),
    //             ];
    //             List<ActionSlidable> userActions = [];
    //             bool isUserAdmin = members
    //                     .firstWhere((element) => element.account_id == user.id)
    //                     .role ==
    //                 "admin";

    //             return GroupMemberCard(
    //                 memberData: widget.members![index],
    //                 actions: isUserAdmin ? adminActions : userActions);
    //           },
    //         ),
    //       );
    //     },
    //     loading: () {
    //       return ListView(
    //         padding: EdgeInsets.zero,
    //         children: [
    //           Shimmer.fromColors(
    //             baseColor: Colors.grey[800]!,
    //             highlightColor: Colors.grey[600]!,
    //             child: Container(
    //               margin: const EdgeInsets.only(bottom: 16),
    //               height: 70,
    //               width: double.infinity,
    //               decoration: BoxDecoration(
    //                 color: Colors.grey,
    //                 borderRadius: BorderRadius.circular(16),
    //               ),
    //             ),
    //           ),
    //           Shimmer.fromColors(
    //             baseColor: Colors.grey[800]!,
    //             highlightColor: Colors.grey[600]!,
    //             child: Container(
    //               margin: const EdgeInsets.only(bottom: 16),
    //               height: 70,
    //               width: double.infinity,
    //               decoration: BoxDecoration(
    //                 color: Colors.grey,
    //                 borderRadius: BorderRadius.circular(16),
    //               ),
    //             ),
    //           ),
    //         ],
    //       );
    //     },
    //     error: (error, stack) => const Center(
    //       child: Text("Error"),
    //     ),
    //   ),
    // );
  }

  // @override
  // Widget build(BuildContext context) {
  //   final AsyncValue<List<GroupMember>?> groupMembers =
  //       ref.watch(groupMembersProvider(widget.groupId));
  //   final user = ref.read(userProvider);

  //   return Container(
  //     padding: widget.isPadding != null && !widget.isPadding!
  //         ? const EdgeInsets.all(0)
  //         : const EdgeInsets.all(16),
  //     child: groupMembers.when(
  //       data: (members) {
  //         if (members == null) {
  //           return const Center(
  //             child: Text("No members"),
  //           );
  //         }
  //         return RefreshIndicator(
  //           displacement: 0,
  //           onRefresh: () async {
  //             ref.invalidate(groupMembersProvider(widget.groupId));
  //           },
  //           child: ListView.builder(
  //             padding: EdgeInsets.zero,
  //             itemCount: members.length,
  //             itemBuilder: (context, index) {
  //               final GroupMember member = members[index];
  //               List<ActionSlidable> adminActions = [
  //                 ActionSlidable(
  //                   Icons.delete,
  //                   Colors.red,
  //                   (() async {
  //                     if (kDebugMode) {
  //                       print("delete");
  //                       print(member.account_id);
  //                       print(member.name);
  //                       print(member);
  //                     }

  //                     bool isLeave = member.account_id == user.id;

  //                     if (isLeave) {
  //                       widget.leaveGroup(member.account_id);
  //                     } else {
  //                       widget.deleteGroupMember(member.account_id);
  //                     }
  //                   }),
  //                 ),
  //                 ActionSlidable(
  //                   Icons.edit,
  //                   Colors.grey,
  //                   (() async {
  //                     if (kDebugMode) {
  //                       print("Edit");
  //                     }
  //                     await editRoleModal(
  //                       user.token,
  //                       member.account_id,
  //                       widget.groupId,
  //                     );
  //                   }),
  //                 ),
  //               ];
  //               List<ActionSlidable> userActions = [];
  //               bool isUserAdmin = members
  //                       .firstWhere((element) => element.account_id == user.id)
  //                       .role ==
  //                   "admin";

  //               return GroupMemberCard(
  //                   member: member,
  //                   actions: isUserAdmin ? adminActions : userActions);
  //             },
  //           ),
  //         );
  //       },
  //       loading: () {
  //         return ListView(
  //           padding: EdgeInsets.zero,
  //           children: [
  //             Shimmer.fromColors(
  //               baseColor: Colors.grey[800]!,
  //               highlightColor: Colors.grey[600]!,
  //               child: Container(
  //                 margin: const EdgeInsets.only(bottom: 16),
  //                 height: 70,
  //                 width: double.infinity,
  //                 decoration: BoxDecoration(
  //                   color: Colors.grey,
  //                   borderRadius: BorderRadius.circular(16),
  //                 ),
  //               ),
  //             ),
  //             Shimmer.fromColors(
  //               baseColor: Colors.grey[800]!,
  //               highlightColor: Colors.grey[600]!,
  //               child: Container(
  //                 margin: const EdgeInsets.only(bottom: 16),
  //                 height: 70,
  //                 width: double.infinity,
  //                 decoration: BoxDecoration(
  //                   color: Colors.grey,
  //                   borderRadius: BorderRadius.circular(16),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         );
  //       },
  //       error: (error, stack) => const Center(
  //         child: Text("Error"),
  //       ),
  //     ),
  //   );
  // }
}
