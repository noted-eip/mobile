import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/clients/note_client.dart';
import 'package:noted_mobile/data/models/note/note.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:openapi/openapi.dart';
import 'package:tuple/tuple.dart';
// TODO: add cache timeout

final searchNoteProvider = StateProvider((ref) => '');

final noteClientProvider = Provider<NoteClient>((ref) => NoteClient(ref: ref));

final notesProvider = FutureProvider<List<Note>?>((ref) async {
  final account = ref.watch(userProvider);
  final notelist =
      await ref.watch(noteClientProvider).listNotes(account.id, account.token);

  final search = ref.watch(searchNoteProvider);
  final grouplist =
      await ref.watch(noteClientProvider).listNotes(account.id, account.token);

  // cacheTimeout(ref, 'fetchGroups');

  if (search == "") {
    return grouplist;
  } else {
    return notelist
        ?.where(
            (note) => note.title.toLowerCase().contains(search.toLowerCase()))
        .toList();
  }
  // return notelist;
});

final groupNotesProvider =
    FutureProvider.family<List<Note>?, String>((ref, groupId) async {
  final account = ref.watch(userProvider);
  final notelist = await ref
      .watch(noteClientProvider)
      .listGroupNotes(groupId, account.token);

  return notelist;
});

final noteProvider =
    FutureProvider.family<Note?, Tuple2<String, String>>((ref, infos) async {
  final account = ref.watch(userProvider);
  final note = await ref.watch(noteClientProvider).getNote(
        infos.item1,
        infos.item2,
        account.token,
      );

  return note;
});

final quizzProvider = FutureProvider.autoDispose
    .family<V1Quiz?, Tuple2<String, String>>((ref, infos) async {
  final quizz = await ref.watch(noteClientProvider).quizzGenerator(
        noteId: infos.item1,
        groupId: infos.item2,
      );

  return quizz;
});

final recommendationListProvider = FutureProvider.autoDispose
    .family<List<V1Widget>?, Tuple2<String, String>>((ref, infos) async {
  final recommendationList =
      await ref.watch(noteClientProvider).recommendationGenerator(
            noteId: infos.item1,
            groupId: infos.item2,
          );

  return recommendationList;
});
