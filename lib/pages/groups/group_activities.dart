import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/providers/group_provider.dart';
import 'package:noted_mobile/pages/groups/group_activity_card.dart';
import 'package:openapi/openapi.dart';

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
    final AsyncValue<List<V1GroupActivity>?> activites =
        ref.watch(groupActivitiesProvider(widget.groupId));

    return activites.when(
        data: ((data) {
          if (data == null) {
            return const Center(
              child: Text("Pas d'activitées"),
            );
          }

          if (data.isEmpty) {
            return const Center(
              child: Text("Pas d'activitées"),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.length,
            itemBuilder: (context, index) {
              return GroupActivityCard(
                  groupActivity: data[index], groupId: widget.groupId);
            },
          );
        }),
        error: ((error, stackTrace) => Center(child: Text(error.toString()))),
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
