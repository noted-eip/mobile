import 'package:flutter/material.dart';
import 'package:noted_mobile/components/note_card_widget.dart';
import 'package:noted_mobile/data/fake_groups_list.dart';
import 'package:noted_mobile/data/group.dart';

class LatestFilesList extends StatelessWidget {
  const LatestFilesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
                onPressed: (() {
                  Navigator.pushNamed(context, '/profile');
                }),
                icon: const Icon(Icons.person, color: Colors.black)),
          ],
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("All Notes",
                    style:
                        TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                const SizedBox(
                  height: 20,
                ),
                ..._buildList(kFakeGroupsList, context),
              ],
            ),
          ),
        ));
  }

  List<Widget> _buildList(List<Group> groups, BuildContext context) {
    List<Widget> widgets = [];
    for (var group in groups) {
      widgets.add(
        Text(
          group.title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      );
      widgets.add(
        const SizedBox(
          height: 10,
        ),
      );

      for (var note in group.notes) {
        widgets.add(NoteCard(
          title: note.title,
          authorId: note.authorId,
          onTap: () {
            Navigator.pushNamed(context, '/note-detail', arguments: note.id);
          },
        ));
      }
    }
    return widgets;
  }
}
