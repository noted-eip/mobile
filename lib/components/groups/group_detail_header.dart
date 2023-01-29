import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/common/custom_alerte.dart';
import 'package:noted_mobile/components/common/loading_button.dart';
import 'package:noted_mobile/components/groups/modal/edit_group.dart';
import 'package:noted_mobile/data/models/group/group.dart';
import 'package:noted_mobile/data/models/group/group_data.dart';
import 'package:noted_mobile/data/providers/group_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/utils/string_extension.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shimmer/shimmer.dart';

class GroupDetailHeader extends ConsumerStatefulWidget {
  const GroupDetailHeader({
    required this.groupId,
    required this.deleteGroup,
    required this.leaveGroup,
    super.key,
  });

  final String groupId;
  final AsyncCallBack leaveGroup;
  final AsyncCallBack deleteGroup;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GroupDetailHeaderState();
}

class _GroupDetailHeaderState extends ConsumerState<GroupDetailHeader> {
  Future<void> openSettings({
    required String userTkn,
    required String userId,
    required String groupId,
    required AsyncValue<Group?> group,
    required WidgetRef ref,
  }) async {
    RoundedLoadingButtonController btnController =
        RoundedLoadingButtonController();
    final user = ref.watch(userProvider);
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return EditGroupModal(
          btnController: btnController,
          userTkn: user.token,
          groupId: groupId,
          baseTitle: group.hasValue ? group.value!.data.name : "groupName",
          baseDescription: group.hasValue
              ? group.value!.data.description
              : "groupDescription",
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider);
    final AsyncValue<GroupMember?> member =
        ref.watch(groupMemberProvider(widget.groupId));
    final AsyncValue<Group?> group = ref.watch(groupProvider(widget.groupId));

    return Row(
      children: [
        group.hasValue
            ? Expanded(
                flex: 1,
                child: AutoSizeText(
                  group.value!.data.name.capitalize(),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : Shimmer.fromColors(
                baseColor: Colors.grey.shade800,
                highlightColor: Colors.grey.shade600,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black,
                  ),
                  height: 20,
                  width: 100,
                ),
              ),
        group.hasValue && member.hasValue
            ? Material(
                color: Colors.transparent,
                child: PopupMenuButton(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(16),
                    ),
                  ),
                  itemBuilder: ((context) {
                    return [
                      if (member.value!.role == "admin")
                        PopupMenuItem(
                          child: TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await openSettings(
                                group: group,
                                groupId: widget.groupId,
                                ref: ref,
                                userId: user.id,
                                userTkn: user.token,
                              );
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit,
                                  color: Colors.grey.shade900,
                                  size: 30,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Edit",
                                  style: TextStyle(
                                    color: Colors.grey.shade900,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (member.value!.role == "admin")
                        PopupMenuItem(
                          child: TextButton(
                            onPressed: () async {
                              final res = await showDialog(
                                context: context,
                                builder: ((context) {
                                  return CustomAlertDialog(
                                    title: "Delete Group",
                                    content:
                                        "Are you sure you want to delete this group?",
                                    onConfirm: () async {
                                      await widget.deleteGroup();
                                    },
                                  );
                                }),
                              );

                              if (mounted && res == true) {
                                await Future.delayed(
                                    const Duration(milliseconds: 500),
                                    (() => Navigator.of(context).pop(true)));
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete,
                                  color: Colors.grey.shade900,
                                  size: 30,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Delete",
                                  style: TextStyle(
                                    color: Colors.grey.shade900,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      PopupMenuItem(
                        child: TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await showDialog(
                              context: context,
                              builder: ((context) {
                                return CustomAlertDialog(
                                  title: "Leave the Group",
                                  content:
                                      "Are you sure you want to leave this group ?",
                                  onConfirm: () async {
                                    await widget.leaveGroup();
                                  },
                                );
                              }),
                            );
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.exit_to_app_rounded,
                                color: Colors.grey.shade900,
                                size: 30,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Leave",
                                style: TextStyle(
                                    color: Colors.grey.shade900,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ];
                  }),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(
                      Icons.more_vert,
                      color: Colors.grey.shade900,
                      size: 32,
                    ),
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}
