import 'package:flutter/material.dart';
import 'package:noted_mobile/components/common/base_container.dart';
import 'package:noted_mobile/components/notes_list_widget.dart';
import 'package:noted_mobile/components/group_info_widget.dart';
import 'package:noted_mobile/data/fake_groups_list.dart';
import 'package:noted_mobile/data/group.dart';

// TODO:
//ajouter un scroll sur la page entière et faire disparaitre le header
//avec l'effet d'apple en gardant le nom du fichier dans l'app bar
// Voir pour refaire le design de la page

class GroupDetailPage extends StatelessWidget {
  const GroupDetailPage({Key? key}) : super(key: key);

  Group getGroup(String groupId) {
    return kFakeGroupsList.firstWhere((element) => element.id == groupId);
  }

  @override
  Widget build(BuildContext context) {
    final String groupId = ModalRoute.of(context)!.settings.arguments as String;
    Group group = getGroup(groupId);

    return Material(
      child: BaseContainer(
        titleWidget: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.group,
                  color: Colors.white,
                  size: 30,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  group.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            IconButton(
              onPressed: (() {}),
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
            ),
          ],
        ),
        primaryColor: Colors.grey.shade900,
        secondaryColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              GroupInfos(groupId: groupId),
              NotesList(notes: group.notes),
            ],
          ),
        ),
      ),
    );
  }
}
