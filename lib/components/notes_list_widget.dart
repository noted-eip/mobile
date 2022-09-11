import 'package:flutter/material.dart';
import 'package:noted_mobile/components/note_card_widget.dart';
import 'package:noted_mobile/data/note.dart';

class NotesList extends StatelessWidget {
  const NotesList({Key? key, required this.notes}) : super(key: key);
  final List<Note> notes;

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.white,
      padding: const EdgeInsets.all(20),
      height: 500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Notes List",
              style: TextStyle(fontSize: 20, color: Colors.white)),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                Note note = notes[index];
                return NoteCard(
                  baseColor: Colors.white,
                  title: note.title,
                  authorId: note.authorId,
                  onTap: () {
                    Navigator.pushNamed(context, '/note-detail',
                        arguments: note.id);
                  },
                );
              },
              itemCount: notes.length,
            ),
          ),
        ],
      ),
    );
  }
}
