import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/common/custom_alerte.dart';
import 'package:noted_mobile/components/common/loading_button.dart';
import 'package:noted_mobile/components/groups/modal/edit_group.dart';
import 'package:noted_mobile/data/providers/group_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:openapi/openapi.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class GroupHeaderMenu extends ConsumerStatefulWidget {
  const GroupHeaderMenu({
    Key? key,
    required this.group,
    required this.deleteGroup,
    required this.leaveGroup,
  }) : super(key: key);

  final V1Group group;

  final AsyncCallBack leaveGroup;
  final AsyncCallBack deleteGroup;

  @override
  ConsumerState<GroupHeaderMenu> createState() => _GroupHeaderMenuState();
}

class _GroupHeaderMenuState extends ConsumerState<GroupHeaderMenu> {
  Future<void> openSettings({
    required String userTkn,
    required String userId,
    required V1Group group,
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
          groupId: group.id,
          baseTitle: group.name,
          baseDescription: group.description,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider);
    AsyncValue<V1GroupMember?> member =
        ref.watch(groupMemberProvider(widget.group.id));

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Material(
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(8),
        color: Colors.transparent,
        child: PopupMenuButton(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
          ),
          itemBuilder: (context) {
            return [
              if (member.value != null && member.value!.isAdmin)
                PopupMenuItem(
                  child: TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await openSettings(
                        group: widget.group,
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
                          "group-detail.edit".tr(),
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
              if (member.value != null && member.value!.isAdmin)
                PopupMenuItem(
                  child: TextButton(
                    onPressed: () async {
                      final res = await showDialog(
                        context: context,
                        builder: ((context) {
                          return CustomAlertDialog(
                            title: "group-detail.delete-group".tr(),
                            content: "group-detail.delete-confirm".tr(),
                            onConfirm: () async {
                              await widget.deleteGroup();
                            },
                          );
                        }),
                      );

                      if (mounted && res == true) {
                        await Future.delayed(const Duration(milliseconds: 500),
                            (() => Navigator.of(context).pop(true)));
                      } else {
                        if (mounted) Navigator.of(context).pop();
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
                          "group-detail.delete".tr(),
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
                    final res = await showDialog(
                      context: context,
                      builder: ((context) {
                        return CustomAlertDialog(
                          title: "group-detail.leave-group".tr(),
                          content: "group-detail.leave-confirm".tr(),
                          onConfirm: () async {
                            await widget.leaveGroup();
                          },
                          confirmText: "group-detail.leave".tr(),
                        );
                      }),
                    );

                    if (mounted && res == true) {
                      await Future.delayed(const Duration(milliseconds: 500),
                          (() => Navigator.of(context).pop(true)));
                    } else {
                      if (mounted) Navigator.of(context).pop();
                    }
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
                        "group-detail.leave".tr(),
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
            ];
          },
          child: Icon(
            Icons.more_vert,
            color: Colors.grey.shade900,
            size: 32,
          ),
        ),
      ),
    );
  }
}
