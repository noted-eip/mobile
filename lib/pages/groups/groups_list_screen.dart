import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:noted_mobile/components/groups/modal/create_group.dart';
import 'package:noted_mobile/components/groups/card/group_card.dart';
import 'package:noted_mobile/data/clients/tracker_client.dart';
import 'package:noted_mobile/data/models/group/group.dart';
import 'package:noted_mobile/data/providers/group_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/utils/debounce.dart';
import 'package:noted_mobile/utils/theme_helper.dart';

class GroupsListPage extends ConsumerStatefulWidget {
  const GroupsListPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GroupsListPageState();
}

class _GroupsListPageState extends ConsumerState<GroupsListPage> {
  Future<void> openCreateGroupModal() async {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return const CreateGroupModal();
      },
    );
  }

  Widget buildSearchBar() {
    return TextField(
      decoration: ThemeHelper()
          .textInputDecoration('', 'my-groups.search'.tr())
          .copyWith(
              prefixIcon: const Icon(
                Icons.search_outlined,
                color: Colors.grey,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always),
      onChanged: (value) {
        Debouncer().run(
          () {
            ref.read(searchProvider.notifier).update((state) => value);
          },
          waitForMs: 500,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Group>?> groups = ref.watch(groupsProvider);

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: CupertinoPageScaffold(
            child: RefreshIndicator(
              triggerMode: RefreshIndicatorTriggerMode.onEdge,
              displacement: 60,
              edgeOffset: kToolbarHeight +
                  16 +
                  MediaQuery.of(context).padding.top +
                  100,
              onRefresh: () async {
                return await Future.delayed(
                  const Duration(milliseconds: 200),
                ).then((value) => ref.invalidate(groupsProvider));
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: <Widget>[
                  CupertinoSliverNavigationBar(
                    border: Border.all(color: CupertinoColors.white),
                    padding: const EdgeInsetsDirectional.only(
                      start: 8,
                      end: 8,
                    ),
                    backgroundColor: Colors.white,
                    leading: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 32,
                        icon: Icon(
                          Icons.menu,
                          color: Colors.grey.shade900,
                        ),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                    ),
                    largeTitle: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          "my-groups.title".tr(),
                        ),
                        const Spacer(),
                        Material(
                          color: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              color: Colors.grey.shade900,
                              splashColor: Colors.black,
                              splashRadius: 35,
                              focusColor: Colors.blueAccent,
                              iconSize: 32,
                              onPressed: () => openCreateGroupModal(),
                              icon: const Icon(Icons.add),
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Material(
                          color: Colors.transparent,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 24,
                            onPressed: (() {
                              ScaffoldState? scaffoldState = ref
                                  .read(mainScreenProvider)
                                  .scaffoldKey
                                  .currentState;

                              if (scaffoldState == null ||
                                  !scaffoldState.hasEndDrawer) {
                                Navigator.of(context).pushNamed('/notif');
                                return;
                              }

                              scaffoldState.openEndDrawer();
                              // if (kDebugMode) {
                              //   print("Send button pressed");
                              // }
                              // ref
                              //     .read(trackerProvider)
                              //     .trackPage(TrackPage.notification);
                              // Navigator.pushNamed(context, "/notif");
                            }),
                            icon: Icon(Icons.send_rounded,
                                color: Colors.grey.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: CustomDelegate(
                      closedHeight: 16,
                      openHeight: 16,
                      toolBarHeight: kToolbarHeight,
                      child: buildSearchBar(),
                    ),
                  ),
                  groups.when(
                    data: (data) {
                      if (data == null || data.isEmpty) {
                        var media = MediaQuery.of(context);
                        var bodyHeight = media.size.height -
                            media.padding.top -
                            16 -
                            media.viewPadding.top -
                            media.viewPadding.bottom -
                            media.padding.bottom -
                            kToolbarHeight;

                        return SliverSafeArea(
                          top: false,
                          sliver: SliverFixedExtentList(
                            itemExtent: bodyHeight,
                            delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Lottie.asset(
                                      'assets/animations/empty-box.json',
                                      height: 250,
                                    ),
                                    Text("my-groups.empty".tr(),
                                        style: const TextStyle(fontSize: 18)),
                                  ],
                                );
                              },
                              childCount: 1,
                            ),
                          ),
                        );
                      }

                      return SliverSafeArea(
                        top: false,
                        minimum: const EdgeInsets.all(16),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final group = data[index].data;
                              return Material(
                                color: Colors.transparent,
                                child: GroupCard(
                                  groupName: group.name,
                                  groupDescription: group.description,
                                  groupNotesCount: 0,
                                  onTap: () async {
                                    ref
                                        .read(trackerProvider)
                                        .trackPage(TrackPage.groupDetail);
                                    final res = await Navigator.pushNamed(
                                        context, "/group-detail",
                                        arguments: group.id);

                                    if (res == true) {
                                      ref.invalidate(groupsProvider);
                                      ref.invalidate(latestGroupsProvider);
                                    }
                                  },
                                ),
                              );
                            },
                            childCount: data.length,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                        ),
                      );
                    },
                    loading: () => SliverSafeArea(
                      top: false,
                      minimum: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return const GroupCard.empty();
                          },
                          childCount: 6,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                      ),
                    ),
                    error: (error, stack) => SliverSafeArea(
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height -
                                  kToolbarHeight -
                                  16 -
                                  MediaQuery.of(context).padding.top -
                                  MediaQuery.of(context).padding.bottom -
                                  MediaQuery.of(context).viewPadding.top -
                                  MediaQuery.of(context).viewPadding.bottom,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  LottieBuilder.asset(
                                    'assets/animations/error.json',
                                    height: 250,
                                  ),
                                  Text(
                                    "my-groups.error".tr(),
                                  ),
                                ],
                              ),
                            );
                          },
                          childCount: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomDelegate extends SliverPersistentHeaderDelegate {
  double toolBarHeight;
  double closedHeight;
  double openHeight;
  Widget child;

  CustomDelegate({
    required this.toolBarHeight,
    required this.closedHeight,
    required this.openHeight,
    required this.child,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: toolBarHeight + openHeight,
        color: Colors.white,
        padding: const EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: 16,
        ),
        child: child,
      ),
    );
  }

  @override
  double get maxExtent => toolBarHeight + openHeight;

  @override
  double get minExtent => toolBarHeight + closedHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
