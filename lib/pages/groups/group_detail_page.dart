import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:noted_mobile/components/common/base_container.dart';
import 'package:noted_mobile/components/common/custom_alerte.dart';
import 'package:noted_mobile/components/common/custom_modal.dart';
import 'package:noted_mobile/components/common/custom_toast.dart';
import 'package:noted_mobile/components/groups/group_detail_header.dart';
import 'package:noted_mobile/components/groups/group_info_widget.dart';
import 'package:noted_mobile/components/groups/group_member_list.dart';
import 'package:noted_mobile/components/invites/invite_member.dart';
import 'package:noted_mobile/components/invites/pending_invite.dart';
import 'package:noted_mobile/components/notes/notes_list_widget.dart';
import 'package:noted_mobile/data/models/group/group.dart';
import 'package:noted_mobile/data/providers/group_provider.dart';
import 'package:noted_mobile/data/providers/invite_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/pages/groups/group_activities.dart';
import 'package:noted_mobile/utils/string_extension.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

//TODO: gérer les empty states sur les notes, les membres et les activités
//TODO: gérer les errors states sur les notes, les membres et les activités

class GroupDetailPage extends ConsumerStatefulWidget {
  const GroupDetailPage({super.key, this.groupId});

  final String? groupId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GroupDetailPageState();
}

class _GroupDetailPageState extends ConsumerState<GroupDetailPage> {
  final RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> leaveGroupDialog(
      String userTkn, String userId, String groupId, WidgetRef ref) async {
    return await showDialog(
      context: context,
      builder: ((context) {
        return CustomAlertDialog(
          title: "Quitter le groupe",
          content: "Êtes-vous sûr de vouloir quitter ce groupe ?",
          onConfirm: () async {
            await deleteGroupMember(userTkn, userId, groupId, true);
          },
          confirmText: "Quitter",
        );
      }),
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
          Navigator.pop(context, true);
        } else {
          ref.invalidate(groupProvider(groupId));
        }
      }
    } catch (e) {
      if (mounted) {
        CustomToast.show(
          message: e.toString().capitalize(),
          type: ToastType.error,
          context: context,
          gravity: ToastGravity.BOTTOM,
        );
      }
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

  Future<void> deleteGroup(String groupId, userTkn) async {
    try {
      await ref.read(groupClientProvider).deleteGroup(groupId: groupId);

      if (kDebugMode) {
        print("Group deleted successfully");
      }
      if (mounted) {
        Navigator.pop(context, true);
        CustomToast.show(
          message: "Le groupe a été supprimé avec succès",
          type: ToastType.success,
          context: context,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      if (mounted) {
        CustomToast.show(
          message: e.toString().capitalize(),
          type: ToastType.error,
          context: context,
          gravity: ToastGravity.BOTTOM,
        );
      }
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

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

  @override
  Widget build(BuildContext context) {
    String groupId = widget.groupId ?? "";
    if (ModalRoute.of(context)!.settings.arguments != null) {
      groupId = ModalRoute.of(context)!.settings.arguments as String;
    }

    final user = ref.watch(userProvider);

    final AsyncValue<Group?> groupFromApi = ref.watch(groupProvider(groupId));

    return Scaffold(
      key: _scaffoldKey,
      body: BaseContainer(
        titleWidget: GroupDetailHeader(
          groupId: groupId,
          deleteGroup: () async => await deleteGroup(
            groupId,
            user.token,
          ),
          leaveGroup: () async => await deleteGroupMember(
            user.token,
            user.id,
            groupId,
            true,
          ),
        ),
        primaryColor: Colors.white,
        secondaryColor: Colors.grey.shade900,
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: groupFromApi.when(
                  data: ((data) {
                    if (data != null) {
                      bool isWorkspace = data.data.workspaceAccountId != null &&
                          data.data.workspaceAccountId!.isNotEmpty;

                      return Column(
                        children: [
                          GroupInfos(group: data),
                          const SizedBox(
                            height: 20,
                          ),
                          Expanded(
                            child: DefaultTabController(
                              length: isWorkspace ? 2 : 3,
                              child: Column(
                                children: [
                                  TabBar(
                                    indicatorColor: Colors.grey.shade900,
                                    tabs: [
                                      const Tab(
                                        text: "Notes",
                                      ),
                                      if (!isWorkspace)
                                        const Tab(
                                          text: "Membres",
                                        ),
                                      const Tab(
                                        text: "Activitées",
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  Expanded(
                                    child: TabBarView(
                                      dragStartBehavior: DragStartBehavior.down,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          child: NotesList(
                                            title: null,
                                            isRefresh: true,
                                            groupId: data.data.id,
                                          ),
                                        ),
                                        if (!isWorkspace)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    IconButton(
                                                      onPressed: () async {
                                                        ref.invalidate(
                                                            groupInvitesProvider(
                                                                groupId));

                                                        await showModalBottomSheet(
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          context: context,
                                                          isScrollControlled:
                                                              true,
                                                          builder: (context) {
                                                            return CustomModal(
                                                              child: ListInvitesWidget(
                                                                  groupId:
                                                                      groupId),
                                                              onClose:
                                                                  (context2) {
                                                                Navigator.pop(
                                                                    context2,
                                                                    false);
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
                                                          groupId,
                                                        );
                                                      },
                                                      icon: const Icon(
                                                        Icons.add,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Expanded(
                                                  child: GroupMembersList(
                                                    members: data.data.members,
                                                    isPadding: false,
                                                    deleteGroupMember:
                                                        (accountId) {
                                                      deleteGroupMemberDialog(
                                                        user.token,
                                                        accountId,
                                                        groupId,
                                                        ref,
                                                      );
                                                    },
                                                    leaveGroup: (accountId) {
                                                      leaveGroupDialog(
                                                        user.token,
                                                        accountId,
                                                        groupId,
                                                        ref,
                                                      );
                                                    },
                                                    groupId: groupId,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child:
                                              GroupActivities(groupId: groupId),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const Center(
                        child: Text("No data"),
                      );
                    }
                  }),
                  error: ((error, stackTrace) => Text(error.toString())),
                  loading: () {
                    return Column(
                      children: [
                        const GroupInfos.empty(),
                        Expanded(
                          child: DefaultTabController(
                            length: 3,
                            child: Column(
                              children: [
                                TabBar(
                                  indicatorColor: Colors.grey.shade900,
                                  tabs: const [
                                    Tab(
                                      text: "Notes",
                                    ),
                                    Tab(
                                      text: "Membres",
                                    ),
                                    Tab(
                                      text: "Activitées",
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: NotesList(
                                          title: Text(
                                            "",
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.black),
                                          ),
                                          isRefresh: true,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: GroupMembersList(
                                          members: null,
                                          isPadding: false,
                                          deleteGroupMember: (accountId) {},
                                          leaveGroup: (accountId) {},
                                          groupId: groupId,
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: GroupMembersList(
                                            members: null,
                                            isPadding: false,
                                            deleteGroupMember: (accountId) {},
                                            leaveGroup: (accountId) {},
                                            groupId: groupId,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
