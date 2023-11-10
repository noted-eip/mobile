import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/notes/create_note.dart';
import 'package:noted_mobile/components/notes/note_card_widget.dart';
import 'package:noted_mobile/data/clients/tracker_client.dart';
import 'package:noted_mobile/data/providers/note_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/pages/groups/groups_list_screen.dart';
import 'package:noted_mobile/utils/theme_helper.dart';
import 'package:openapi/openapi.dart';
import 'package:tuple/tuple.dart';

class LatestsFilesList extends ConsumerStatefulWidget {
  const LatestsFilesList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LatestsFilesListState();
}

class _LatestsFilesListState extends ConsumerState<LatestsFilesList> {
  Widget buildSearchBar() {
    return TextField(
      decoration: ThemeHelper()
          .textInputDecoration('', 'my-notes.search'.tr())
          .copyWith(
              prefixIcon: const Icon(
                Icons.search_outlined,
                color: Colors.grey,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always),
      onChanged: (value) {
        ref.read(searchNoteProvider.notifier).update((state) => value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // final AsyncValue<List<Note>?> notes = ref.watch(notesProvider);
    final AsyncValue<List<V1Note>?> notes = ref.watch(notesProvider);

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: CupertinoPageScaffold(
            child: RefreshIndicator(
              triggerMode: RefreshIndicatorTriggerMode.onEdge,
              displacement: 60,
              edgeOffset: kToolbarHeight +
                  16 +
                  MediaQuery.of(context).padding.top +
                  100,
              onRefresh: () async {
                return await Future.delayed(
                  const Duration(milliseconds: 200),
                ).then((value) => ref.invalidate(notesProvider));
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: <Widget>[
                  CupertinoSliverNavigationBar(
                    border: Border.all(color: CupertinoColors.white),
                    padding: const EdgeInsetsDirectional.only(
                      start: 8,
                      end: 8,
                    ),
                    backgroundColor: Colors.white,
                    leading: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 32,
                        icon: Icon(
                          Icons.menu,
                          color: Colors.grey.shade900,
                        ),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                    ),
                    largeTitle: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          "my-notes.title".tr(),
                        ),
                        const Spacer(),
                        Material(
                          color: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              color: Colors.grey.shade900,
                              splashColor: Colors.black,
                              splashRadius: 35,
                              focusColor: Colors.blueAccent,
                              iconSize: 32,
                              onPressed: () => openCreateNoteModal(),
                              icon: const Icon(Icons.add),
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Material(
                          color: Colors.transparent,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 24,
                            onPressed: (() {
                              if (kDebugMode) {
                                print("Send button pressed");
                              }
                              ref
                                  .read(trackerProvider)
                                  .trackPage(TrackPage.notification);
                              Navigator.pushNamed(context, "/notif");
                            }),
                            icon: Icon(Icons.send_rounded,
                                color: Colors.grey.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: OurDelegate(
                      closedHeight: 16,
                      openHeight: 16,
                      toolBarHeight: kToolbarHeight,
                      child: buildSearchBar(),
                    ),
                  ),
                  notes.when(
                    data: (data) {
                      if (data == null || data.isEmpty) {
                        final media = MediaQuery.of(context);
                        final bodyHeight = media.size.height -
                            media.padding.top -
                            16 -
                            media.viewPadding.top -
                            media.viewPadding.bottom -
                            media.padding.bottom -
                            kToolbarHeight;

                        return SliverSafeArea(
                          top: false,
                          sliver: SliverFixedExtentList(
                            itemExtent: bodyHeight,
                            delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                                return const Material(
                                  color: Colors.transparent,
                                  child: Center(
                                    child: Text("No notes found",
                                        style: TextStyle(fontSize: 18)),
                                  ),
                                );
                              },
                              childCount: 1,
                            ),
                          ),
                        );
                      }

                      return SliverSafeArea(
                        top: false,
                        minimum: const EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final note = data[index];
                              return Material(
                                color: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: NoteCard(
                                    baseColor: Colors.white,
                                    note: note,
                                    onTap: () async {
                                      ref
                                          .read(trackerProvider)
                                          .trackPage(TrackPage.noteDetail);
                                      final res = await Navigator.pushNamed(
                                          context, "/note-detail",
                                          arguments:
                                              Tuple2(note.id, note.groupId));

                                      if (res == true) {
                                        ref.invalidate(notesProvider);
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                            childCount: data.length,
                          ),
                        ),
                      );
                    },
                    loading: () => SliverSafeArea(
                      top: false,
                      minimum: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: NoteCard.empty(),
                            );
                          },
                          childCount: 6,
                        ),
                      ),
                    ),
                    error: (error, stack) => SliverSafeArea(
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: NoteCard.empty(),
                            );
                          },
                          childCount: 6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openCreateNoteModal() async {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return const CreateNoteModal();
      },
    );
  }
}
