import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/groups/group_member_list.dart';
import 'package:noted_mobile/components/notes/notes_list_widget.dart';
import 'package:noted_mobile/pages/groups/group_activities.dart';
import 'package:openapi/openapi.dart';

class GroupTabBar extends ConsumerStatefulWidget {
  const GroupTabBar({
    Key? key,
    required this.controller,
    required this.leaveGroup,
    required this.deleteGroup,
    required this.inviteMember,
    required this.group,
  }) : super(key: key);

  final void Function(String) deleteGroup;
  final void Function(String) leaveGroup;

  final VoidCallback inviteMember;
  final V1Group group;
  final TabController controller;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GroupTabBarState();
}

class _GroupTabBarState extends ConsumerState<GroupTabBar> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          TabBar(
            controller: widget.controller,
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
              controller: widget.controller,
              dragStartBehavior: DragStartBehavior.down,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: NotesList(
                    title: null,
                    isRefresh: true,
                    groupId: widget.group.id,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: GroupMembersList(
                          members: widget.group.members!.toList(),
                          isPadding: false,
                          deleteGroupMember: widget.deleteGroup,
                          leaveGroup: widget.leaveGroup,
                          groupId: widget.group.id,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GroupActivities(groupId: widget.group.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
