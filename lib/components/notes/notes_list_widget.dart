import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/notes/note_card_widget.dart';
import 'package:noted_mobile/data/models/note/note.dart';
import 'package:noted_mobile/data/providers/note_provider.dart';
import 'package:shimmer/shimmer.dart';

class NotesList extends ConsumerStatefulWidget {
  const NotesList({
    super.key,
    required this.isRefresh,
    required this.title,
  });

  const NotesList.empty({Key? key})
      : this(key: key, isRefresh: null, title: null);

  final bool? isRefresh;
  final Widget? title;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NotesListState();
}

class _NotesListState extends ConsumerState<NotesList> {
  Widget buildLoading(bool isRefresh) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null)
            Shimmer.fromColors(
              baseColor: Colors.grey.shade800,
              highlightColor: Colors.grey.shade700,
              child: Container(
                height: 22,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          if (widget.title != null)
            const SizedBox(
              height: 16,
            ),
          if (isRefresh)
            Expanded(
              child: RefreshIndicator(
                displacement: 0,
                onRefresh: () async {
                  ref.invalidate(notesProvider);
                },
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: NoteCard.empty());
                  },
                ),
              ),
            ),
          if (!isRefresh)
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: 3,
                itemBuilder: (context, index) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: NoteCard.empty(),
                  );
                },
              ),
            )
        ],
      ),
    );
  }

  Widget builList(List<Note> notes, bool isRefresh) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (widget.title != null) widget.title!,
          if (widget.title != null) const SizedBox(height: 16),
          if (isRefresh)
            Expanded(
              child: RefreshIndicator(
                displacement: 0,
                onRefresh: () async {
                  ref.invalidate(notesProvider);
                },
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    Note note = notes[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: NoteCard(
                        note: note,
                        baseColor: Colors.white,
                        onTap: () {
                          Navigator.pushNamed(context, '/note-detail',
                              arguments: note.id);
                        },
                      ),
                    );
                  },
                  itemCount: notes.length,
                ),
              ),
            ),
          if (!isRefresh)
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  Note note = notes[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: NoteCard(
                      note: note,
                      baseColor: Colors.white,
                      onTap: () {
                        Navigator.pushNamed(context, '/note-detail',
                            arguments: note.id);
                      },
                    ),
                  );
                },
                itemCount: notes.length,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isRefresh == null) {
      return buildLoading(false);
    }

    final notes = ref.watch(notesProvider);

    return notes.when(
      data: (data) {
        if (data == null) {
          return buildLoading(widget.isRefresh!);
        }
        return builList(data, widget.isRefresh!);
      },
      error: (error, stackTrace) {
        return Text(error.toString());
      },
      loading: () {
        return buildLoading(widget.isRefresh!);
      },
    );
  }
}
