import 'package:noted_mobile/data/fake_note.dart';
import 'package:noted_mobile/data/note.dart';

List<Note> kFakeNotesList = List.generate(
  20,
  (index) => Note(
    title: 'Note N°${index + 1}',
    blocks: kFakeNote1.blocks,
    id: 'N$index',
    authorId: 'Author ${index + 1}',
  ),
);
