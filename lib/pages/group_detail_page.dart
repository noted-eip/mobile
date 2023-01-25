import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/common/base_container.dart';
import 'package:noted_mobile/components/common/custom_alerte.dart';
import 'package:noted_mobile/components/group_info_widget.dart';
import 'package:noted_mobile/components/modal/group_settings.dart';
import 'package:noted_mobile/components/notes_list_widget.dart';
import 'package:noted_mobile/data/models/group/group.dart';
import 'package:noted_mobile/data/providers/group_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/data/group.dart';
import 'package:noted_mobile/utils/string_extension.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shimmer/shimmer.dart';

//TODO: ajouter un scroll sur la page entière et faire disparaitre le header
//avec l'effet d'apple en gardant le nom du fichier dans l'app bar
// Voir pour refaire le design de la page

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

  late Future<NewGroup?> group;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> deleteGroup(String groupId, userTkn) async {
    try {
      await ref.read(groupClientProvider).deleteGroup(groupId, userTkn);

      if (kDebugMode) {
        print("Group deleted successfully");
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> openSettings(String userTkn, String userId, String groupId,
      AsyncValue<Group?> group, WidgetRef ref) async {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return GroupSettingModal(groupId: groupId);
      },
    );
  }

  Widget baseContainerTittle(AsyncValue<Group?> groupFromApi, WidgetRef ref) {
    return Row(
      children: [
        groupFromApi.hasValue
            ? Expanded(
                flex: 1,
                child: AutoSizeText(
                  groupFromApi.value!.data.name.capitalize(),
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
        groupFromApi.hasValue
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
                      PopupMenuItem(
                        child: TextButton(
                          onPressed: () async {
                            if (groupFromApi.hasValue) {
                              final snapshot = groupFromApi.value!.data;
                              final user = ref.read(userProvider);
                              Navigator.pop(context);

                              await openSettings(user.token, user.id,
                                  snapshot.id, groupFromApi, ref);
                            }
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
                                    fontWeight: FontWeight.bold),
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
                                  title: "Delete Group",
                                  content:
                                      "Are you sure you want to delete this group?",
                                  onConfirm: () async {
                                    final groupId = groupFromApi.value!.data.id;
                                    final userTkn =
                                        ref.read(userProvider).token;

                                    await deleteGroup(
                                      groupId,
                                      userTkn,
                                    );
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

  @override
  Widget build(BuildContext context) {
    String groupId = widget.groupId ?? "";
    if (ModalRoute.of(context)!.settings.arguments != null) {
      groupId = ModalRoute.of(context)!.settings.arguments as String;
    }

    final AsyncValue<Group?> groupFromApi = ref.watch(groupProvider(groupId));

    return Scaffold(
      key: _scaffoldKey,
      body: BaseContainer(
        titleWidget: baseContainerTittle(groupFromApi, ref),
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
                      const Expanded(
                        child: NotesList(
                          title: Text(
                            "Notes List",
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                          isRefresh: true,
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
              children: const [
                GroupInfos.empty(),
                Expanded(
                  child: NotesList.empty(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
