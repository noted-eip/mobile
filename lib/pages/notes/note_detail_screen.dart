import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/providers/note_provider.dart';
import 'package:noted_mobile/pages/notes/editor/noted_editor.dart';
import 'package:tuple/tuple.dart';

class NoteDetail extends ConsumerStatefulWidget {
  const NoteDetail({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NoteDetailState();
}

class _NoteDetailState extends ConsumerState<NoteDetail> {
  @override
  Widget build(BuildContext context) {
    final Tuple2<String, String> infos =
        ModalRoute.of(context)!.settings.arguments as Tuple2<String, String>;
    final note = ref.watch(noteProvider(infos));

    return Scaffold(
      body: note.when(
        data: (data) {
          if (data == null) {
            return const Center(
              child: Text("No data"),
            );
          }
          return NotedEditor(
            note: data,
            infos: infos,
          );
        },
        error: (error, stackTrace) => Text(error.toString()),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
