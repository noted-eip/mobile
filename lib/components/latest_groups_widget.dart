import 'package:flutter/material.dart';
import 'package:noted_mobile/components/group_card_widget.dart';
import 'package:noted_mobile/data/fake_groups_list.dart';
import 'package:noted_mobile/data/group.dart';

class LatestGroups extends StatelessWidget {
  const LatestGroups({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Latest Groups", style: TextStyle(fontSize: 20)),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                Group group = kFakeGroupsList[index];
                return index == 4
                    ? GroupCard(
                        groupName: "See More ...",
                        groupIcon: Icons.add,
                        displaySeeMore: true,
                        onTap: () {
                          Navigator.pushNamed(context, '/groups');
                        },
                      )
                    : GroupCard(
                        groupName: group.title,
                        groupNotesCount: group.nbNotes,
                        onTap: () {
                          Navigator.pushNamed(context, '/group-detail',
                              arguments: group.id);
                        },
                      );
              },
              itemCount: 5,
              scrollDirection: Axis.horizontal,
            ),
          ),
        ],
      ),
    );
  }
}
