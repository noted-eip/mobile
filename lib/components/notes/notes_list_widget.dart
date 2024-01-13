import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:noted_mobile/components/notes/note_card_widget.dart';
import 'package:noted_mobile/data/clients/tracker_client.dart';
import 'package:noted_mobile/data/providers/group_provider.dart';
import 'package:noted_mobile/data/providers/note_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:openapi/openapi.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tuple/tuple.dart';

class NotesList extends ConsumerStatefulWidget {
  const NotesList({
    super.key,
    required this.isRefresh,
    required this.title,
    this.groupId,
    this.isNotePage = false,
  });

  const NotesList.empty({Key? key})
      : this(key: key, isRefresh: null, title: null);

  final bool? isRefresh;
  final bool isNotePage;
  final Widget? title;
  final String? groupId;

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
          if (widget.title != null) ...[
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
            const SizedBox(
              height: 16,
            ),
          ],
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
                      child: NoteCard.empty(),
                    );
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

  List<bool> isExpandedList = [];

  Widget builList(List<V1Note> notes, bool isRefresh) {
    List<String> groupIds = notes.map((note) => note.groupId).toSet().toList();

    notes.sort((a, b) => a.groupId.compareTo(b.groupId));
    // créer une map avec comme clé l'id du groupe et comme valeur la liste des notes
    Map<String, List<V1Note>> notesByGroup = {};

    for (var groupId in groupIds) {
      notesByGroup[groupId] =
          notes.where((note) => note.groupId == groupId).toList();
    }

    List<Widget> expansionTiles = [];

    for (var groupId in groupIds) {
      AsyncValue<V1Group?> groupFromApi =
          ref.read(groupProvider(notesByGroup[groupId]![0].groupId));
      isExpandedList.add(false);
      expansionTiles.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            initiallyExpanded: true,
            tilePadding: const EdgeInsets.all(12),
            collapsedBackgroundColor: Colors.grey.shade900,
            backgroundColor: Colors.grey.shade100,
            collapsedTextColor: Colors.white,
            textColor: Colors.grey.shade900,
            iconColor: Colors.grey.shade900,
            collapsedIconColor: Colors.white,
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              groupFromApi.when(
                data: (group) => group == null ? "" : group.name,
                loading: () => '',
                error: (error, stackTrace) => '',
              ),
            ),
            children: [
              for (var note in notesByGroup[groupId]!)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: NoteCard(
                    note: note,
                    baseColor: Colors.white,
                    onTap: () {
                      ref.read(trackerProvider).trackPage(TrackPage.noteDetail);
                      Navigator.pushNamed(context, '/note-detail',
                          arguments: Tuple2(note.id, note.groupId));
                    },
                  ),
                ),
            ],
            onExpansionChanged: (value) => setState(() {
              isExpandedList[groupIds.indexOf(groupId)] = value;
            }),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (widget.title != null) widget.title!,
          if (widget.title != null) const SizedBox(height: 16),
          if (widget.isNotePage)
            Theme(
              data: ThemeData(dividerColor: Colors.transparent),
              child: Expanded(
                  child: ListView(
                children: expansionTiles,
              )),
            ),
          if (!widget.isNotePage && isRefresh)
            Expanded(
              child: RefreshIndicator(
                displacement: 0,
                onRefresh: () async {
                  ref.invalidate(notesProvider);
                },
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    // Note note = notes[index];
                    V1Note note = notes[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: NoteCard(
                        note: note,
                        baseColor: Colors.white,
                        onTap: () {
                          ref
                              .read(trackerProvider)
                              .trackPage(TrackPage.noteDetail);
                          Navigator.pushNamed(context, '/note-detail',
                              arguments: Tuple2(note.id, note.groupId));
                        },
                      ),
                    );
                  },
                  itemCount: notes.length,
                ),
              ),
            ),
          if (!widget.isNotePage && !isRefresh && notes.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  V1Note note = notes[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: NoteCard(
                      note: note,
                      baseColor: Colors.white,
                      onTap: () {
                        ref
                            .read(trackerProvider)
                            .trackPage(TrackPage.noteDetail);
                        Navigator.pushNamed(context, '/note-detail',
                            arguments: Tuple2(note.id, note.groupId));
                      },
                    ),
                  );
                },
                itemCount: notes.length,
              ),
            ),
          if (!widget.isNotePage && !isRefresh && notes.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  "home.no-notes".tr(),
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 16,
                  ),
                ),
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

    if (widget.groupId != null) {
      return buildListByGroup(widget.groupId!);
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

  Widget buildListByGroup(String groupId) {
    final notes = ref.watch(groupNotesProvider(groupId));

    return notes.when(
      data: (data) {
        if (data == null) {
          return buildLoading(widget.isRefresh!);
        }

        return RefreshIndicator(
          displacement: 0,
          onRefresh: () async {
            ref.invalidate(groupNotesProvider(groupId));
          },
          child: data.isEmpty
              ? ListView(
                  children: [
                    Lottie.asset(
                      'assets/animations/empty-box.json',
                      height: 250,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "home.no-notes".tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    V1Note note = data[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: NoteCard(
                        note: note,
                        baseColor: Colors.white,
                        onTap: () {
                          ref
                              .read(trackerProvider)
                              .trackPage(TrackPage.noteDetail);
                          Navigator.pushNamed(context, '/note-detail',
                              arguments: Tuple2(note.id, note.groupId));
                        },
                      ),
                    );
                  },
                  itemCount: data.length,
                ),
        );
      },
      error: (error, stackTrace) => Text(error.toString()),
      loading: () => buildLoading(widget.isRefresh!),
    );
  }
}
