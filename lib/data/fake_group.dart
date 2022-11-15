import 'package:noted_mobile/data/fake_note.dart';
import 'package:noted_mobile/data/group.dart';

Group kFakeGroup1 = Group(
  title: 'Group 1',
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

Group kFakeGroup2 = Group(
  title: 'Group 2',
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

Group kFakeGroup3 = Group(
  title: 'Group 3',
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
