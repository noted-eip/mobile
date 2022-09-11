import 'package:noted_mobile/data/fake_note.dart';
import 'package:noted_mobile/data/folder.dart';

Folder kFakeFolder1 = Folder(
  title: 'Folder 1',
  nbNotes: 2,
  notes: [
    kFakeNote1,
    kFakeNote2,
  ],
  id: 'f1',
  author: 'Faker',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

Folder kFakeFolder2 = Folder(
  title: 'Folder 2',
  nbNotes: 2,
  notes: [
    kFakeNote1,
    kFakeNote2,
  ],
  id: 'f2',
  author: 'Faker',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

Folder kFakeFolder3 = Folder(
  title: 'Folder 3',
  nbNotes: 2,
  notes: [
    kFakeNote1,
    kFakeNote2,
  ],
  id: 'f3',
  author: 'Faker',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
