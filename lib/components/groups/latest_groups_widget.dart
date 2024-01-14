import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/common/new_custom_drawer.dart';
import 'package:noted_mobile/components/groups/modal/create_group.dart';
import 'package:noted_mobile/components/groups/card/group_card.dart';
import 'package:noted_mobile/data/clients/tracker_client.dart';
import 'package:noted_mobile/data/models/group/group.dart';
import 'package:noted_mobile/data/providers/group_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shimmer/shimmer.dart';

typedef GroupRefreshCallBack = void Function(String, String);

class LatestsGroups extends ConsumerStatefulWidget {
  const LatestsGroups({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LatestsGroupsState();
}

class _LatestsGroupsState extends ConsumerState<LatestsGroups> {
  final RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();

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

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Group>?> latestGroups =
        ref.watch(latestGroupsProvider);

    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: latestGroups.when(
        data: (groups) {
          if (groups != null && groups.isNotEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    "home.lastest-groups".tr(),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      if (index < groups.length) {
                        return GroupCard(
                          groupName: groups[index].data.name,
                          groupIcon: Icons.group,
                          onTap: () async {
                            ref
                                .read(trackerProvider)
                                .trackPage(TrackPage.groupDetail);
                            final res = await Navigator.pushNamed(
                                context, '/group-detail',
                                arguments: groups[index].data.id);
                            if (res == true) {
                              ref.invalidate(latestGroupsProvider);
                              ref.invalidate(groupsProvider);
                            }
                          },
                        );
                      } else {
                        return GroupCard(
                          groupName: "home.see-more".tr(),
                          groupIcon: Icons.add,
                          displaySeeMore: true,
                          onTap: () {
                            ref
                                .read(mainScreenProvider)
                                .setItem(MyMenuItems.groups);
                          },
                        );
                      }
                    },
                    itemCount: groups.length > 4 ? 5 : groups.length + 1,
                    scrollDirection: Axis.horizontal,
                  ),
                ),
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("home.start-w-group".tr(),
                    style: const TextStyle(fontSize: 20)),
                Expanded(
                  child: Row(
                    children: [
                      GroupCard(
                        groupName: "home.create-group".tr(),
                        groupIcon: Icons.add,
                        displaySeeMore: true,
                        onTap: () async {
                          await openCreateGroupModal();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
        loading: () {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade400,
                  child: Container(
                    height: 22,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: GridView(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      childAspectRatio: 1,
                    ),
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      GroupCard.empty(),
                      GroupCard.empty(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        error: (error, stack) => Center(
          child: Text(error.toString()),
        ),
      ),
    );
  }
}
