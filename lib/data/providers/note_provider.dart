import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/clients/note_client.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:openapi/openapi.dart';
import 'package:tuple/tuple.dart';

final noteIdProvider = StateProvider<String>((ref) => '');
final groupIdProvider = StateProvider<String>((ref) => '');

final blocksWithCommentsProvider = FutureProvider.autoDispose
    .family<List<V1Block>?, Tuple2<String, String>>((ref, infos) async {
  final blocks = await ref.watch(noteClientProvider).listBlockWithComments(
        groupId: infos.item1,
        noteId: infos.item2,
      );

  return blocks;
});

final noteComments = FutureProvider.autoDispose
    .family<List<BlockComment>?, Tuple3<String, String, String>>(
        (ref, infos) async {
  final comments = await ref.watch(noteClientProvider).listComments(
        groupId: infos.item1,
        noteId: infos.item2,
        blockId: infos.item3,
      );

  return comments;
});

final searchNoteProvider = StateProvider((ref) => '');

final noteClientProvider = Provider<NoteClient>((ref) => NoteClient(ref: ref));

final notesProvider = FutureProvider<List<V1Note>?>((ref) async {
  final account = ref.watch(userProvider);
  final notelist = await ref
      .watch(noteClientProvider)
      .listNotes(authorId: account.id, token: account.token);

  final search = ref.watch(searchNoteProvider);

  if (search == "") {
    return notelist;
  } else {
    return notelist
        ?.where(
            (note) => note.title.toLowerCase().contains(search.toLowerCase()))
        .toList();
  }
});

final groupNotesProvider =
    FutureProvider.family<List<V1Note>?, String>((ref, groupId) async {
  final account = ref.watch(userProvider);
  final notelist = await ref
      .watch(noteClientProvider)
      .listGroupNotes(groupId: groupId, token: account.token);

  return notelist;
});

final noteProvider =
    FutureProvider.family<V1Note?, Tuple2<String, String>>((ref, infos) async {
  final account = ref.watch(userProvider);
  final note = await ref.watch(noteClientProvider).getNote(
        noteId: infos.item1,
        groupId: infos.item2,
        token: account.token,
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
