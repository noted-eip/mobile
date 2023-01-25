import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/common/custom_alerte.dart';
import 'package:noted_mobile/components/common/custom_modal.dart';
import 'package:noted_mobile/components/group_member_list.dart';
import 'package:noted_mobile/components/invite_member.dart';
import 'package:noted_mobile/components/modal/edit_group.dart';
import 'package:noted_mobile/components/modal/pending_invite.dart';
import 'package:noted_mobile/data/providers/group_provider.dart';
import 'package:noted_mobile/data/providers/invite_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class GroupSettingModal extends ConsumerStatefulWidget {
  const GroupSettingModal({required this.groupId, super.key});

  final String groupId;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GroupSettingModalState();
}

class _GroupSettingModalState extends ConsumerState<GroupSettingModal> {
  RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();

  Future<void> inviteMemberModal(String tkn, String groupId) async {
    TextEditingController controller = TextEditingController();
    GlobalKey<FormState> roleformKey = GlobalKey<FormState>();

    return await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return CustomModal(
          height: 0.92,
          child: InviteMemberWidget(
            controller: controller,
            formKey: roleformKey,
            groupId: groupId,
          ),
        );
      },
    );
  }

  Future<void> deleteGroupMember(
      String userTkn, String memberId, String groupId, bool isLeave) async {
    try {
      await ref.read(groupClientProvider).deleteGroupMember(
            groupId,
            memberId,
            userTkn,
          );
      if (mounted) {
        if (isLeave) {
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context, true);
        } else {
          Navigator.pop(context);
          ref.invalidate(groupMembersProvider(groupId));
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> deleteGroupMemberDialog(
      String userTkn, String userId, String groupId, WidgetRef ref) async {
    return await showDialog(
      context: context,
      builder: ((context) {
        return CustomAlertDialog(
          title: "Delete member",
          content: "Are you sure you want to delete this member ?",
          onConfirm: () async {
            await deleteGroupMember(userTkn, userId, groupId, false);
          },
        );
      }),
    );
  }

  Future<void> leaveGroupDialog(
      String userTkn, String userId, String groupId, WidgetRef ref) async {
    return await showDialog(
      context: context,
      builder: ((context) {
        return CustomAlertDialog(
          title: "Leave the Group",
          content: "Are you sure you want to leave this group ?",
          onConfirm: () async {
            await deleteGroupMember(userTkn, userId, groupId, true);
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(groupProvider(widget.groupId));

    final user = ref.watch(userProvider);

    return CustomModal(
      height: 0.92,
      iconButton: IconButton(
        onPressed: () async {
          bool res = await showModalBottomSheet(
            backgroundColor: Colors.transparent,
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return EditGroupModal(
                btnController: btnController,
                userTkn: user.token,
                groupId: widget.groupId,
                baseTitle:
                    group.hasValue ? group.value!.data.name : "groupName",
                baseDescription: group.hasValue
                    ? group.value!.data.description
                    : "groupDescription",
              );
            },
          );

          if (res && mounted) {
            Navigator.pop(context, true);
          }
        },
        icon: const Icon(
          Icons.edit,
          color: Colors.black,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group.hasValue ? group.value!.data.name : "groupName",
            style: const TextStyle(
                color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 32,
          ),
          Text(
            group.hasValue ? group.value!.data.description : "groupDescription",
            style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.normal),
          ),
          const SizedBox(
            height: 48,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Member List",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      ref.invalidate(groupInvitesProvider(widget.groupId));

                      await showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return CustomModal(
                            child: ListInvitesWidget(groupId: widget.groupId),
                            onClose: (context2) {
                              Navigator.pop(context2, false);
                            },
                          );
                        },
                      );
                    },
                    icon: const Icon(
                      Icons.inbox,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await inviteMemberModal(
                        user.token,
                        widget.groupId,
                      );
                    },
                    icon: const Icon(
                      Icons.add,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Expanded(
            child: GroupMembersList(
              deleteGroupMember: (accountId) {
                deleteGroupMemberDialog(
                  user.token,
                  accountId,
                  widget.groupId,
                  ref,
                );
              },
              leaveGroup: (accountId) {
                leaveGroupDialog(
                  user.token,
                  accountId,
                  widget.groupId,
                  ref,
                );
              },
              groupId: widget.groupId,
            ),
          ),
          const SizedBox(
            height: 32,
          ),
          TextButton(
            onPressed: () async {
              await leaveGroupDialog(user.token, user.id, widget.groupId, ref);
            },
            child: const Text(
              "Leave the groupe",
              style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
