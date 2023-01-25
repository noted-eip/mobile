import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/clients/note_client.dart';
import 'package:noted_mobile/data/note.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';

final noteClientProvider = Provider<NoteClient>((ref) => NoteClient());

final notesProvider = FutureProvider<List<Note>?>((ref) async {
  final account = ref.watch(userProvider);
  final notelist =
      await ref.watch(noteClientProvider).listNotes(account.id, account.token);

  return notelist;
});

final noteProvider = FutureProvider.family<Note?, String>((ref, noteId) async {
  final account = ref.watch(userProvider);
  final note = await ref.watch(noteClientProvider).getNote(
        noteId,
        account.token,
      );

  return note;
});
