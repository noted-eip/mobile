import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:noted_mobile/components/common/base_container.dart';
import 'package:noted_mobile/components/common/custom_alerte.dart';
import 'package:noted_mobile/components/common/custom_modal.dart';
import 'package:noted_mobile/components/common/custom_toast.dart';
import 'package:noted_mobile/components/groups/action_button.dart';
import 'package:noted_mobile/components/groups/group_detail_header.dart';
import 'package:noted_mobile/components/groups/group_info_widget.dart';
import 'package:noted_mobile/components/groups/group_member_list.dart';
import 'package:noted_mobile/components/groups/tab_bar/group_tab_bar.dart';
import 'package:noted_mobile/components/groups/tab_bar/workspace_tab_bar.dart';
import 'package:noted_mobile/components/invites/invite_member.dart';
import 'package:noted_mobile/components/notes/notes_list_widget.dart';
import 'package:noted_mobile/data/models/invite/invite.dart';
import 'package:noted_mobile/data/providers/group_provider.dart';
import 'package:noted_mobile/data/providers/invite_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/utils/string_extension.dart';
import 'package:openapi/openapi.dart';
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

class _GroupDetailPageState extends ConsumerState<GroupDetailPage>
    with TickerProviderStateMixin {
  final RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();

  late TabController _tabControllerWorkspace;
  late TabController _tabControllerGroup;

  @override
  void initState() {
    _tabControllerWorkspace = TabController(
      length: 2,
      vsync: this,
    );
    _tabControllerGroup = TabController(
      length: 3,
      vsync: this,
    );

    super.initState();
  }

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
            groupId: groupId,
            memberId: memberId,
            token: userTkn,
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
          height: 0.85,
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

    final AsyncValue<V1Group?> groupFromApi = ref.watch(groupProvider(groupId));

    return Scaffold(
      floatingActionButton: groupFromApi.when(
        data: (group) {
          if (group == null) {
            return const SizedBox.shrink();
          }

          bool isWorkspace = group.workspaceAccountId != null &&
              group.workspaceAccountId!.isNotEmpty;

          return GroupActionButton(
            controller:
                isWorkspace ? _tabControllerWorkspace : _tabControllerGroup,
            isWorkspace: isWorkspace,
            group: group,
            inviteMember: (recipientId) async {
              try {
                Invite? invite =
                    await ref.read(inviteClientProvider).sendInvite(
                          groupId: groupId,
                          recipientId: recipientId,
                        );

                if (invite != null) {
                  btnController.success();
                  ref.invalidate(groupInvitesProvider(group.id));
                } else {
                  btnController.error();
                }
              } catch (e) {
                //TODO : handle Error
                // TODO: handle invite member if already in List

                // if (mounted) {
                //   CustomToast.show(
                //     message: "Failed to send invite to ${members[i].item1}",
                //     // message: e.toString().capitalize(),
                //     type: ToastType.error,
                //     context: saveContext,
                //     gravity: ToastGravity.BOTTOM,
                //     duration: 5,
                //   );
                // }
                // btnController.error();
              }
              // await inviteMemberModal(
              //   user.token,
              //   groupId,
              // );
            },
          );
        },
        loading: () {
          return const SizedBox.shrink();
        },
        error: (error, stackTrace) {
          return const SizedBox.shrink();
        },
      ),
      key: _scaffoldKey,
      body: BaseContainer(
        openEndDrawer: false,
        titleWidget: groupFromApi.when(
          data: (group) {
            if (group == null) {
              return const SizedBox.shrink();
            }

            return GroupDetailHeader(
              group: group,
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
            );
          },
          loading: () {
            return const SizedBox.shrink();
          },
          error: (error, stackTrace) {
            return const SizedBox.shrink();
          },
        ),
        primaryColor: Colors.white,
        secondaryColor: Colors.grey.shade900,
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: groupFromApi.when(
                  data: ((group) {
                    if (group != null) {
                      bool isWorkspace = group.workspaceAccountId != null &&
                          group.workspaceAccountId!.isNotEmpty;

                      return Column(
                        children: [
                          GroupInfos(group: group),
                          const SizedBox(
                            height: 20,
                          ),
                          if (isWorkspace) ...[
                            WorkspaceTabBar(
                              controller: _tabControllerWorkspace,
                              groupId: groupId,
                            ),
                          ] else ...[
                            GroupTabBar(
                              controller: _tabControllerGroup,
                              leaveGroup: (accountId) {
                                leaveGroupDialog(
                                  user.token,
                                  accountId,
                                  groupId,
                                  ref,
                                );
                              },
                              deleteGroup: (accountId) {
                                deleteGroupMemberDialog(
                                  user.token,
                                  accountId,
                                  groupId,
                                  ref,
                                );
                              },
                              inviteMember: () async {
                                await inviteMemberModal(
                                  user.token,
                                  groupId,
                                );
                              },
                              group: group,
                            ),
                          ]
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
