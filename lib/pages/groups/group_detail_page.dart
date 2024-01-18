import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:noted_mobile/components/common/base_container.dart';
import 'package:noted_mobile/components/common/custom_alerte.dart';
import 'package:noted_mobile/components/common/custom_toast.dart';
import 'package:noted_mobile/components/groups/action_button.dart';
import 'package:noted_mobile/components/groups/group_detail_header.dart';
import 'package:noted_mobile/components/groups/group_info_widget.dart';
import 'package:noted_mobile/components/groups/group_member_list.dart';
import 'package:noted_mobile/components/groups/tab_bar/group_tab_bar.dart';
import 'package:noted_mobile/components/groups/tab_bar/workspace_tab_bar.dart';
import 'package:noted_mobile/components/notes/notes_list_widget.dart';
import 'package:noted_mobile/data/models/invite/invite.dart';
import 'package:noted_mobile/data/providers/group_provider.dart';
import 'package:noted_mobile/data/providers/invite_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/utils/string_extension.dart';
import 'package:openapi/openapi.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

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

  late OverlayEntry overlay;

  Future<void> leaveGroupDialog(
      String userTkn, String userId, String groupId, WidgetRef ref) async {
    return await showDialog(
      context: context,
      builder: ((context) {
        return CustomAlertDialog(
          title: "pop-up.leave-group.title".tr(),
          content: "pop-up.leave-group.description".tr(),
          onConfirm: () async {
            await deleteGroupMember(userTkn, userId, groupId, true);
          },
          confirmText: "pop-up.leave-group.button".tr(),
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
          title: "pop-up.delete-member.title".tr(),
          content: "pop-up.delete-member.description".tr(),
          confirmText: "pop-up.delete-member.button".tr(),
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

      if (mounted) {
        Navigator.pop(context, true);
        CustomToast.show(
          message: "group-detail.delete-success".tr(),
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

          bool noMembers = group.members == null || group.members!.isEmpty;

          return GroupActionButton(
            noMembers: noMembers,
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
                if (mounted) {
                  CustomToast.show(
                    message: e.toString().capitalize(),
                    type: ToastType.error,
                    context: context,
                    gravity: ToastGravity.TOP,
                  );
                }
              }
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
                        mainAxisSize: MainAxisSize.max,
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
                  error: ((error, stackTrace) => Column(
                        children: [
                          Text(error.toString()),
                          FilledButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text("go-back".tr()),
                          )
                        ],
                      )),
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
                                  tabs: [
                                    Tab(
                                      text: "group-detail.tab.notes".tr(),
                                    ),
                                    Tab(
                                      text: "group-detail.tab.members".tr(),
                                    ),
                                    Tab(
                                      text: "group-detail.tab.activities".tr(),
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
