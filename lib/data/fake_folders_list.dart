import 'package:noted_mobile/data/fake_note.dart';
import 'package:noted_mobile/data/folder.dart';

List<Folder> kFakeFoldersList = List.generate(
  20,
  (index) => Folder(
    title: 'Folder N°${index + 1}',
    nbNotes: index + 1,
    notes: List.generate(index + 1, (i) {
      if (index % 2 == 0) {
        return kFakeNote1;
      } else {
        return kFakeNote2;
      }
    }),
    id: 'F$index',
    author: 'Author ${index + 1}',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
);
