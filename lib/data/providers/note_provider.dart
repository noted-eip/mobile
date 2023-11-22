import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/clients/note_client.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:openapi/openapi.dart';
import 'package:tuple/tuple.dart';
// TODO: add cache timeout

final searchNoteProvider = StateProvider((ref) => '');

final noteClientProvider = Provider<NoteClient>((ref) => NoteClient(ref: ref));

final notesProvider = FutureProvider<List<V1Note>?>((ref) async {
  final account = ref.watch(userProvider);
  final notelist =
      await ref.watch(noteClientProvider).listNotes(account.id, account.token);

  final search = ref.watch(searchNoteProvider);

  // cacheTimeout(ref, 'fetchGroups');

  if (search == "") {
    return notelist;
  } else {
    return notelist
        ?.where(
            (note) => note.title.toLowerCase().contains(search.toLowerCase()))
        .toList();
  }
  // return notelist;
});

final groupNotesProvider =
    FutureProvider.family<List<V1Note>?, String>((ref, groupId) async {
  final account = ref.watch(userProvider);
  final notelist = await ref
      .watch(noteClientProvider)
      .listGroupNotes(groupId, account.token);

  return notelist;
});

// final groupNotesProvider =
//     FutureProvider.family<List<Note>?, String>((ref, groupId) async {
//   final account = ref.watch(userProvider);
//   final notelist = await ref
//       .watch(noteClientProvider)
//       .listGroupNotes(groupId, account.token);

//   return notelist;
// });

// final noteProvider =
//     FutureProvider.family<Note?, Tuple2<String, String>>((ref, infos) async {
//   final account = ref.watch(userProvider);
//   final note = await ref.watch(noteClientProvider).getNote(
//         infos.item1,
//         infos.item2,
//         account.token,
//       );

//   return note;
// });

final noteProvider =
    FutureProvider.family<V1Note?, Tuple2<String, String>>((ref, infos) async {
  final account = ref.watch(userProvider);
  final note = await ref.watch(noteClientProvider).getNote(
        infos.item1,
        infos.item2,
        account.token,
      );

  return note;
});

final quizzListProvider = FutureProvider.autoDispose
    .family<List<V1Quiz>?, Tuple2<String, String>>((ref, infos) async {
  final quizzList = await ref.watch(noteClientProvider).listNoteQuizzes(
        noteId: infos.item1,
        groupId: infos.item2,
      );

  return quizzList;
});

// final quizzProvider = StateNotifierProvider((ref) =>

// );

final recommendationListProvider = FutureProvider.autoDispose
    .family<List<V1Widget>?, Tuple2<String, String>>((ref, infos) async {
  final recommendationList =
      await ref.watch(noteClientProvider).recommendationGenerator(
            noteId: infos.item1,
            groupId: infos.item2,
          );

  return recommendationList;
});

final noteSummaryProvider =
    FutureProvider.family<String?, Tuple2<String, String>>((ref, infos) async {
  final noteAnalysis = await ref.watch(noteClientProvider).summaryGenerator(
        noteId: infos.item1,
        groupId: infos.item2,
      );

  return noteAnalysis;
});
