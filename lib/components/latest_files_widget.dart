import 'package:flutter/material.dart';
import 'package:noted_mobile/components/note_card_widget.dart';
import 'package:noted_mobile/data/fake_notes_list.dart';
import 'package:noted_mobile/data/note.dart';

class LatestFiles extends StatelessWidget {
  const LatestFiles({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 370,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Latest Files", style: TextStyle(fontSize: 20)),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                Note note = kFakeNotesList[index];
                return index == 4
                    ? NoteCard(
                        title: "See More ...",
                        icon: Icons.add,
                        displaySeeMore: true,
                        onTap: () {
                          Navigator.pushNamed(context, '/latest-files');
                        },
                      )
                    : NoteCard(
                        authorId: note.authorId,
                        title: note.title,
                        onTap: () {
                          Navigator.pushNamed(context, '/note-detail',
                              arguments: note.id);
                        },
                      );
              },
              itemCount: 5,
            ),
          ),
        ],
      ),
    );
  }
}
