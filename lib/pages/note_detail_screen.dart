import 'package:flutter/material.dart';
import 'package:noted_mobile/data/fake_note.dart';
import 'package:noted_mobile/data/fake_notes_list.dart';
import 'package:noted_mobile/data/note.dart';
import 'package:noted_mobile/data/note_block.dart';

class NoteDetail extends StatelessWidget {
  const NoteDetail({Key? key}) : super(key: key);

  List<Widget> _buildBlocks(Note note) {
    List<Widget> blocks = [];
    for (var block in note.blocks) {
      switch (block.type) {
        case BlockType.heading1:
          {
            blocks.add(
              Text(
                block.text,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
            blocks.add(const SizedBox(height: 16));
          }
          break;
        case BlockType.heading2:
          {
            blocks.add(
              Text(
                block.text,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
            blocks.add(const SizedBox(height: 14));
          }
          break;
        case BlockType.heading3:
          {
            blocks.add(
              Text(
                block.text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
            blocks.add(const SizedBox(height: 12));
          }
          break;

        default:
          {
            blocks.add(
              Text(
                block.text,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            );
            blocks.add(const SizedBox(height: 10));
          }
      }
    }
    return blocks;
  }

  @override
  Widget build(BuildContext context) {
    final String noteId = ModalRoute.of(context)!.settings.arguments as String;
    Note note = kFakeNotesList.firstWhere((element) => element.id == noteId);

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
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                kFakeNote1.title,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                kFakeNote1.authorId,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ..._buildBlocks(note),
              ..._buildBlocks(note),
              ..._buildBlocks(note),
            ],
          ),
        ),
      ),
    );
  }
}
