import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/notes/notes_list_widget.dart';
import 'package:noted_mobile/pages/groups/group_activities.dart';

class WorkspaceTabBar extends ConsumerStatefulWidget {
  const WorkspaceTabBar(
      {Key? key, required this.controller, required this.groupId})
      : super(key: key);

  final TabController controller;
  final String groupId;

  @override
  ConsumerState<WorkspaceTabBar> createState() => _WorkspaceTabBarState();
}

class _WorkspaceTabBarState extends ConsumerState<WorkspaceTabBar> {
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
                    groupId: widget.groupId,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GroupActivities(groupId: widget.groupId),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
