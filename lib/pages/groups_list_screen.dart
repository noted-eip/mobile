import 'package:flutter/material.dart';
import 'package:noted_mobile/components/common/base_container.dart';
import 'package:noted_mobile/components/group_card_widget.dart';
import 'package:noted_mobile/data/fake_groups_list.dart';
import 'package:noted_mobile/data/group.dart';

class GroupsListPage extends StatelessWidget {
  const GroupsListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: BaseContainer(
        titleWidget: const Text(
          "All Groups",
        ),
        body: Padding(
          padding:
              const EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemBuilder: (context, index) {
                    Group group = kFakeGroupsList[index];
                    return GroupCard(
                      groupName: group.title,
                      groupCreatedAt: DateTime.now(),
                      groupUpdatedAt: DateTime.now(),
                      groupNotesCount: group.nbNotes,
                      onTap: () {
                        Navigator.pushNamed(context, '/group-detail',
                            arguments: group.id);
                      },
                      groupId: group.id,
                      groupUserId: group.author,
                    );
                  },
                  itemCount: kFakeGroupsList.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
