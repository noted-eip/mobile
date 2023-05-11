import 'package:flutter/foundation.dart';
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
import 'package:noted_mobile/utils/string_extension.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

//TODO: ajouter un scroll sur la page entière et faire disparaitre le header
//avec l'effet d'apple en gardant le nom du fichier dans l'app bar
// Voir pour refaire le design de la page
//TODO: add NestedScrollView

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
          title: "Leave the Group",
          content: "Are you sure you want to leave this group ?",
          onConfirm: () async {
            await deleteGroupMember(userTkn, userId, groupId, true);
          },
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
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context, true);
        } else {
          Navigator.pop(context);
          ref.invalidate(groupMembersProvider(groupId));
        }
      }
    } catch (e) {
      CustomToast.show(
        message: e.toString().capitalize(),
        type: ToastType.error,
        context: context,
        gravity: ToastGravity.BOTTOM,
      );
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
          message: "Group deleted successfully",
          type: ToastType.success,
          context: context,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      CustomToast.show(
        message: e.toString().capitalize(),
        type: ToastType.error,
        context: context,
        gravity: ToastGravity.BOTTOM,
      );
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  // Future<void> openSettings(String userTkn, String userId, String groupId,
  //     AsyncValue<Group?> group, WidgetRef ref) async {
  //   final user = ref.watch(userProvider);
  //   return showModalBottomSheet(
  //     backgroundColor: Colors.transparent,
  //     context: context,
  //     isScrollControlled: true,
  //     builder: (context) {
  //       return EditGroupModal(
  //         btnController: btnController,
  //         userTkn: user.token,
  //         groupId: groupId,
  //         baseTitle: group.hasValue ? group.value!.data.name : "groupName",
  //         baseDescription: group.hasValue
  //             ? group.value!.data.description
  //             : "groupDescription",
  //       );
  //     },
  //   );
  // }

  // Widget baseContainerTittle(AsyncValue<Group?> groupFromApi,
  //     AsyncValue<GroupMember?> memberFromApi, WidgetRef ref) {
  //   return Row(
  //     children: [
  //       groupFromApi.hasValue
  //           ? Expanded(
  //               flex: 1,
  //               child: AutoSizeText(
  //                 groupFromApi.value!.data.name.capitalize(),
  //                 overflow: TextOverflow.ellipsis,
  //               ),
  //             )
  //           : Shimmer.fromColors(
  //               baseColor: Colors.grey.shade800,
  //               highlightColor: Colors.grey.shade600,
  //               child: Container(
  //                 decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(10),
  //                   color: Colors.black,
  //                 ),
  //                 height: 20,
  //                 width: 100,
  //               ),
  //             ),
  //       groupFromApi.hasValue && memberFromApi.hasValue
  //           ? Material(
  //               color: Colors.transparent,
  //               child: PopupMenuButton(
  //                 shape: const RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.all(
  //                     Radius.circular(16),
  //                   ),
  //                 ),
  //                 itemBuilder: ((context) {
  //                   return [
  //                     if (memberFromApi.value!.role == "admin")
  //                       PopupMenuItem(
  //                         child: TextButton(
  //                           onPressed: () async {
  //                             if (groupFromApi.hasValue) {
  //                               final snapshot = groupFromApi.value!.data;
  //                               final user = ref.read(userProvider);
  //                               Navigator.pop(context);

  //                               await openSettings(user.token, user.id,
  //                                   snapshot.id, groupFromApi, ref);
  //                             }
  //                           },
  //                           child: Row(
  //                             children: [
  //                               Icon(
  //                                 Icons.edit,
  //                                 color: Colors.grey.shade900,
  //                                 size: 30,
  //                               ),
  //                               const SizedBox(
  //                                 width: 10,
  //                               ),
  //                               Text(
  //                                 "Edit",
  //                                 style: TextStyle(
  //                                     color: Colors.grey.shade900,
  //                                     fontSize: 16,
  //                                     fontWeight: FontWeight.bold),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                     if (memberFromApi.value!.role == "admin")
  //                       PopupMenuItem(
  //                         child: TextButton(
  //                           onPressed: () async {
  //                             final res = await showDialog(
  //                               context: context,
  //                               builder: ((context) {
  //                                 return CustomAlertDialog(
  //                                   title: "Delete Group",
  //                                   content:
  //                                       "Are you sure you want to delete this group?",
  //                                   onConfirm: () async {
  //                                     final groupId =
  //                                         groupFromApi.value!.data.id;
  //                                     final userTkn =
  //                                         ref.read(userProvider).token;

  //                                     await deleteGroup(
  //                                       groupId,
  //                                       userTkn,
  //                                     );
  //                                   },
  //                                 );
  //                               }),
  //                             );

  //                             if (mounted && res == true) {
  //                               await Future.delayed(
  //                                   const Duration(milliseconds: 500),
  //                                   (() => Navigator.of(context).pop(true)));
  //                             } else {
  //                               Navigator.of(context).pop();
  //                             }
  //                           },
  //                           child: Row(
  //                             children: [
  //                               Icon(
  //                                 Icons.delete,
  //                                 color: Colors.grey.shade900,
  //                                 size: 30,
  //                               ),
  //                               const SizedBox(
  //                                 width: 10,
  //                               ),
  //                               Text(
  //                                 "Delete",
  //                                 style: TextStyle(
  //                                     color: Colors.grey.shade900,
  //                                     fontSize: 16,
  //                                     fontWeight: FontWeight.bold),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                     PopupMenuItem(
  //                       child: TextButton(
  //                         onPressed: () async {
  //                           if (groupFromApi.hasValue) {
  //                             final snapshot = groupFromApi.value!.data;
  //                             final user = ref.read(userProvider);
  //                             Navigator.pop(context);

  //                             await leaveGroupDialog(
  //                               user.token,
  //                               user.id,
  //                               snapshot.id,
  //                               ref,
  //                             );
  //                           }
  //                         },
  //                         child: Row(
  //                           children: [
  //                             Icon(
  //                               Icons.exit_to_app_rounded,
  //                               color: Colors.grey.shade900,
  //                               size: 30,
  //                             ),
  //                             const SizedBox(
  //                               width: 10,
  //                             ),
  //                             Text(
  //                               "Leave",
  //                               style: TextStyle(
  //                                 color: Colors.grey.shade900,
  //                                 fontSize: 16,
  //                                 fontWeight: FontWeight.bold,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ];
  //                 }),
  //                 child: Padding(
  //                   padding: const EdgeInsets.symmetric(horizontal: 16),
  //                   child: Icon(
  //                     Icons.more_vert,
  //                     color: Colors.grey.shade900,
  //                     size: 32,
  //                   ),
  //                 ),
  //               ),
  //             )
  //           : const SizedBox(),
  //     ],
  //   );
  // }

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
        body: groupFromApi.when(
          data: ((data) {
            if (data != null) {
              return SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    children: [
                      GroupInfos(group: data),
                      const SizedBox(
                        height: 20,
                      ),
                      Expanded(
                        child: DefaultTabController(
                          length: 2,
                          child: Column(
                            children: [
                              TabBar(
                                indicatorColor: Colors.grey.shade900,
                                tabs: const [
                                  Tab(
                                    text: "Notes",
                                  ),
                                  Tab(
                                    text: "Members",
                                  ),
                                  // Tab(
                                  //   text: "Activity",
                                  // ),
                                ],
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      child: NotesList(
                                        title: null,
                                        isRefresh: true,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              IconButton(
                                                onPressed: () async {
                                                  ref.invalidate(
                                                      groupInvitesProvider(
                                                          groupId));

                                                  await showModalBottomSheet(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    context: context,
                                                    isScrollControlled: true,
                                                    builder: (context) {
                                                      return CustomModal(
                                                        child:
                                                            ListInvitesWidget(
                                                                groupId:
                                                                    groupId),
                                                        onClose: (context2) {
                                                          Navigator.pop(
                                                              context2, false);
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
                                              isPadding: false,
                                              deleteGroupMember: (accountId) {
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
                                    // Column(
                                    //   children: [
                                    //     const SizedBox(
                                    //       height: 16,
                                    //     ),
                                    //     Expanded(
                                    //       child: Padding(
                                    //         padding: const EdgeInsets.symmetric(
                                    //           horizontal: 16,
                                    //         ),
                                    //         child: GroupActivities(
                                    //           groupId: groupId,
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                              text: "Members",
                            ),
                            Tab(
                              text: "Activities",
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
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: NotesList.empty(),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: GroupMembersList(
                                  isPadding: false,
                                  deleteGroupMember: (accountId) {},
                                  leaveGroup: (accountId) {},
                                  groupId: groupId,
                                ),
                              ),
                              const NotesList(
                                title: Text(
                                  "Notes List",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                                isRefresh: true,
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
    );
  }
}

class GroupActivities extends ConsumerStatefulWidget {
  const GroupActivities({required this.groupId, super.key});

  final String groupId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GroupActivitiesState();
}

class _GroupActivitiesState extends ConsumerState<GroupActivities> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Activities"),
    );
  }
}
