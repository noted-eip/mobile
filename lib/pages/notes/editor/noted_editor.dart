// ignore_for_file: avoid_print

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:noted_mobile/components/common/custom_alerte.dart';
import 'package:noted_mobile/components/common/custom_modal.dart';
import 'package:noted_mobile/components/common/custom_toast.dart';
import 'package:noted_mobile/data/providers/note_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/pages/notes/comment_list.dart';
import 'package:noted_mobile/pages/notes/editor/_custom_component.dart';
import 'package:noted_mobile/pages/notes/editor/_toolbar.dart';
import 'package:noted_mobile/pages/notes/editor/note_utility.dart';
import 'package:noted_mobile/pages/notes/note_summary_screen.dart';
import 'package:noted_mobile/pages/quizz/quizz_home_screen.dart';
import 'package:noted_mobile/pages/recommendation/recommendation_screen.dart';
import 'package:noted_mobile/utils/color.dart';
import 'package:noted_mobile/utils/string_extension.dart';
import 'package:openapi/openapi.dart';
import 'package:super_editor/super_editor.dart';
import 'package:tuple/tuple.dart';

class NotedEditor extends ConsumerStatefulWidget {
  const NotedEditor({
    Key? key,
    required this.note,
    required this.infos,
    this.needInternet = true,
  }) : super(key: key);

  final V1Note note;
  final Tuple2<String, String> infos;
  final bool? needInternet;

  @override
  ConsumerState<NotedEditor> createState() => _NotedEditorState();
}

class _NotedEditorState extends ConsumerState<NotedEditor> {
  late MutableDocument _doc;
  late MutableDocument _docReadOnly;

  final GlobalKey _docLayoutKey = GlobalKey();

  late DocumentComposer _composer;
  late DocumentEditor _docEditor;
  late CommonEditorOperations _docOps;

  late FocusNode _editorFocusNode;

  final _brightness = ValueNotifier<Brightness>(Brightness.light);

  OverlayEntry? _textFormatBarOverlayEntry;

  final _overlayController = MagnifierAndToolbarController()
    ..screenPadding = const EdgeInsets.all(20.0);

  Timer? _timer;

  void _resetTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
  }

  bool isUpdateInProgress = false;

  bool isReadOnly = false;

  void updateNote() {
    setState(() {
      isUpdateInProgress = true;
    });

    _timer = Timer(const Duration(seconds: 5), () async {
      V1Note updatedNote = getV1NoteFromDoc(_doc, widget.note);

      try {
        V1Note? updatedNoteResponse =
            await ref.read(noteClientProvider).updateNote(
                  noteId: widget.infos.item1,
                  groupId: widget.infos.item2,
                  note: updatedNote,
                );

        if (updatedNoteResponse == null) {
          return;
        }

        setState(() {
          isUpdateInProgress = false;
        });

        for (var i = 0; i < _doc.nodes.length; i++) {
          DocumentNode oldNode = _doc.nodes[i];

          if (oldNode.id == updatedNoteResponse.blocks![i].id) {
            continue;
          }

          DocumentNode newNode =
              getNodeFromBlock(updatedNoteResponse.blocks![i]);

          _doc.replaceNode(
            oldNode: oldNode,
            newNode: newNode,
          );

          if (_composer.selection!.extent.nodeId == oldNode.id) {
            _composer.selection = DocumentSelection.collapsed(
              position: DocumentPosition(
                nodeId: newNode.id,
                nodePosition: _composer.selection!.extent.nodePosition,
              ),
            );
          }
        }

        updatedNoteResponse.blocks?.forEach((p0) {
          print(p0.id);
        });

        ref.invalidate(noteProvider(widget.infos));
      } catch (e) {
        setState(() {
          isUpdateInProgress = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _composer = DocumentComposer();

    _doc = createInitialDocument(note: widget.note);
    _docReadOnly = createInitialDocument(note: widget.note, readOnly: true);

    _doc.addListener(updateNote);
    _docEditor = DocumentEditor(document: _doc);

    _docOps = CommonEditorOperations(
      editor: _docEditor,
      composer: _composer,
      documentLayoutResolver: () =>
          _docLayoutKey.currentState as DocumentLayout,
    );
    _editorFocusNode = FocusNode();

    Future.delayed(Duration.zero, () {
      ref.read(noteIdProvider.notifier).update((state) => widget.infos.item1);
      ref.read(groupIdProvider.notifier).update((state) => widget.infos.item2);
    });

    userId = ref.read(userProvider).id;
  }

  late String userId;

  @override
  void dispose() {
    if (_textFormatBarOverlayEntry != null) {
      _textFormatBarOverlayEntry!.remove();
    }

    _editorFocusNode.dispose();
    _composer.dispose();
    _resetTimer();
    super.dispose();
  }

  DocumentGestureMode get _gestureMode {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return DocumentGestureMode.android;
      case TargetPlatform.iOS:
        return DocumentGestureMode.iOS;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return DocumentGestureMode.mouse;
    }
  }

  bool get _isMobile => _gestureMode != DocumentGestureMode.mouse;

  void _cut() {
    _docOps.cut();
    _overlayController.hideToolbar();
  }

  void _copy() {
    _docOps.copy();
    _overlayController.hideToolbar();
  }

  void _paste() {
    _docOps.paste();
    _overlayController.hideToolbar();
  }

  void _selectAll() => _docOps.selectAll();

  bool isLoading = false;
  bool isLoadingQuizz = false;
  bool isLoadingRecommendation = false;
  bool isLoadingSummary = false;
  String? selectedAction;
  MenuController menuController = MenuController();
  bool allowToggle = true;

  Future<void> deleteNoteDialog(WidgetRef ref) async {
    return await showDialog(
      context: context,
      builder: ((context) {
        return CustomAlertDialog(
          title: "pop-up.delete-note.title".tr(),
          content: "pop-up.delete-note.description".tr(),
          onConfirm: () async {
            await ref.read(noteClientProvider).deleteNote(
                  noteId: widget.infos.item1,
                  groupId: widget.infos.item2,
                );

            ref.invalidate(groupNotesProvider(widget.infos.item2));
            ref.invalidate(notesProvider);
            if (!mounted) {
              return;
            }
            CustomToast.show(
              message: "pop-up.delete-note.success".tr(),
              type: ToastType.success,
              context: context,
              gravity: ToastGravity.BOTTOM,
            );
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isUpdateInProgress) {
          CustomToast.show(
            message: "note.inProgress".tr(),
            type: ToastType.warning,
            context: context,
            gravity: ToastGravity.BOTTOM,
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        floatingActionButtonLocation: ExpandableFab.location,
        floatingActionButton:
            !widget.needInternet! ? null : _buildNoteTools(ref),
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: kToolbarHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (isUpdateInProgress) {
                              CustomToast.show(
                                message: "note.inProgress".tr(),
                                type: ToastType.warning,
                                context: context,
                                gravity: ToastGravity.TOP,
                              );
                              return;
                            }
                            if (userId != widget.note.authorAccountId) {
                              ref.invalidate(noteProvider(widget.infos));
                            }

                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.arrow_back),
                        ),
                        Expanded(
                          flex: 6,
                          child: Text(
                            widget.note.title.capitalize(),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                            height: 16,
                            width: 16,
                            child: isUpdateInProgress
                                ? LoadingAnimationWidget.flickr(
                                    leftDotColor: NotedColors.primary,
                                    rightDotColor: NotedColors.tertiary,
                                    size: 16)
                                : null),
                        if (widget.note.authorAccountId == userId)
                          IconButton(
                            onPressed: () {
                              if (isUpdateInProgress) {
                                CustomToast.show(
                                  message: "note.inProgress".tr(),
                                  type: ToastType.warning,
                                  context: context,
                                  gravity: ToastGravity.TOP,
                                );
                                return;
                              }

                              setState(() {
                                isReadOnly = !isReadOnly;

                                if (isReadOnly) {
                                  _composer.selection = null;
                                  V1Note updatedNote =
                                      getV1NoteFromDoc(_doc, widget.note);
                                  _docReadOnly = createInitialDocument(
                                    note: updatedNote,
                                    readOnly: true,
                                  );
                                }
                              });
                            },
                            icon: Icon(
                              isReadOnly
                                  ? Icons.comment
                                  : Icons.comments_disabled,
                              color: NotedColors.primary,
                            ),
                          ),
                        PopupMenuButton(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(16),
                            ),
                          ),
                          itemBuilder: (context) => [
                            if (userId == widget.note.authorAccountId) ...[
                              PopupMenuItem(
                                child: ListTile(
                                  leading: const Icon(Icons.delete),
                                  title: Text("note.delete".tr()),
                                ),
                                onTap: () async {
                                  await deleteNoteDialog(ref);
                                  if (mounted) {
                                    ref.invalidate(
                                        groupNotesProvider(widget.infos.item2));
                                    ref.invalidate(notesProvider);

                                    Navigator.of(context).pop();
                                  }
                                },
                              ),
                            ],
                            PopupMenuItem(
                              child: ListTile(
                                leading: const Icon(Icons.comment),
                                title: Text("note.comments".tr()),
                              ),
                              onTap: () async {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return const CommentList();
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _buildEditor(context, ref),
                  ),
                  if (_isMobile) _buildMountedToolbar(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteTools(
    WidgetRef ref,
  ) {
    if (!widget.needInternet!) return const SizedBox();

    return ExpandableFab(
      overlayStyle: ExpandableFabOverlayStyle(
        color: Colors.black.withOpacity(0.5),
      ),
      distance: 80,
      type: ExpandableFabType.up,
      pos: ExpandableFabPos.right,
      openButtonBuilder: RotateFloatingActionButtonBuilder(
        child: const Icon(Icons.bolt),
        fabSize: ExpandableFabSize.regular,
        backgroundColor: NotedColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      closeButtonBuilder: DefaultFloatingActionButtonBuilder(
        child: const Icon(Icons.close),
        fabSize: ExpandableFabSize.regular,
        backgroundColor: NotedColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: NotedColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                "note-detail.quiz".tr(),
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(color: Colors.white),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                heroTag: "quiz",
                tooltip: "note-detail.quiz".tr(),
                elevation: 5,
                backgroundColor: NotedColors.secondary,
                foregroundColor: Colors.white,
                onPressed: () async {
                  bool validNote = noteContainMoreThan100Words(widget.note);

                  if (!validNote) {
                    CustomToast.show(
                      message:
                          "${"note-detail.100words.base".tr()}${"note-detail.100words.quiz".tr()}",
                      type: ToastType.warning,
                      context: context,
                      gravity: ToastGravity.TOP,
                    );

                    return;
                  }

                  return showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return CustomModal(
                        height: 1,
                        onClose: (context) {
                          print("close");
                          ref.invalidate(quizzListProvider(widget.infos));
                          Navigator.pop(context);
                        },
                        child: QuizzHomeScreen(
                          infos: widget.infos,
                          note: widget.note,
                        ),
                      );
                    },
                  );
                },
                child: isLoadingQuizz
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Icon(
                        Icons.quiz,
                      ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: NotedColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                "note-detail.summary".tr(),
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(color: Colors.white),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                heroTag: "summary",
                tooltip: "note-detail.summary".tr(),
                backgroundColor: NotedColors.secondary,
                foregroundColor: Colors.white,
                elevation: 5,
                onPressed: () async {
                  bool validNote = noteContainMoreThan100Words(widget.note);

                  if (!validNote) {
                    CustomToast.show(
                      message:
                          "${"note-detail.100words.base".tr()}${"note-detail.100words.summary".tr()}",
                      type: ToastType.warning,
                      context: context,
                      gravity: ToastGravity.TOP,
                    );

                    return;
                  }

                  setState(() {
                    isLoadingSummary = true;
                  });

                  String? summary = await createSummary(
                    ref,
                    widget.infos,
                    widget.note,
                  );

                  setState(() {
                    isLoadingSummary = false;
                  });

                  if (summary == null) {
                    if (!mounted) {
                      return;
                    }
                    CustomToast.show(
                      message: "note-detail.error.summary".tr(),
                      type: ToastType.error,
                      context: context,
                      gravity: ToastGravity.TOP,
                    );
                    return;
                  }

                  if (!mounted) {
                    return;
                  }

                  return showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return CustomModal(
                        height: 1,
                        onClose: (context) {
                          Navigator.pop(context);
                        },
                        child: SummaryScreen(
                          infos: widget.infos,
                          summary: summary,
                        ),
                      );
                    },
                  );
                },
                child: isLoadingSummary
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Icon(
                        Icons.summarize,
                      ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: NotedColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                "note-detail.recommandations".tr(),
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(color: Colors.white),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                heroTag: "recommendation",
                tooltip: "note-detail.recommandations".tr(),
                backgroundColor: NotedColors.secondary,
                foregroundColor: Colors.white,
                elevation: 5,
                onPressed: () async {
                  bool validNote = noteContainMoreThan100Words(widget.note);

                  if (!validNote) {
                    CustomToast.show(
                      message:
                          "${"note-detail.100words.base".tr()}${"note-detail.100words.recommandations".tr()}",
                      type: ToastType.warning,
                      context: context,
                      gravity: ToastGravity.TOP,
                    );

                    return;
                  }

                  setState(() {
                    isLoadingRecommendation = true;
                  });

                  List<V1Widget>? widgetList = await createRecommendation(
                    ref,
                    widget.infos,
                    widget.note,
                  );

                  setState(() {
                    isLoadingRecommendation = false;
                  });

                  if (widgetList == null && mounted) {
                    CustomToast.show(
                      message: "note-detail.error.recommendations".tr(),
                      type: ToastType.error,
                      context: context,
                      gravity: ToastGravity.TOP,
                    );
                    return;
                  }

                  if (widgetList!.isEmpty && mounted) {
                    CustomToast.show(
                      message: "note-detail.error.recommendations-empty".tr(),
                      type: ToastType.warning,
                      context: context,
                      gravity: ToastGravity.TOP,
                    );
                    return;
                  }

                  if (!mounted) {
                    return;
                  }

                  return showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return CustomModal(
                        height: 1,
                        onClose: (context) {
                          Navigator.pop(context);
                        },
                        child: RecommendationPage(
                          infos: widget.infos,
                          widgetList: widgetList,
                        ),
                      );
                    },
                  );
                },
                child: isLoadingRecommendation
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Icon(
                        Icons.recommend,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditor(BuildContext context, WidgetRef ref) {
    var userId = ref.read(userProvider).id;

    if (userId != widget.note.authorAccountId || isReadOnly) {
      return SuperReader(
        document: _docReadOnly,
        componentBuilders: [
          CustomParagraphComponentBuilder(),
          ...defaultComponentBuilders,
        ],
      );
    }

    return SuperEditor(
      editor: _docEditor,
      composer: _composer,
      focusNode: _editorFocusNode,
      documentLayoutKey: _docLayoutKey,
      documentOverlayBuilders: const [
        DefaultCaretOverlayBuilder(),
      ],
      selectionStyle: SelectionStyles(
          selectionColor: NotedColors.secondary.withOpacity(0.5)),
      stylesheet: defaultStylesheet,
      componentBuilders: [
        // CustomParagraphComponentBuilder(),
        ...defaultComponentBuilders,
      ],
      gestureMode: _gestureMode,
      inputSource: TextInputSource.ime,
      keyboardActions: [
        // ...notedCustomKeyboardActions,
        ...defaultKeyboardActions,
      ],
      androidToolbarBuilder: (_) => AndroidTextEditingFloatingToolbar(
        onCutPressed: _cut,
        onCopyPressed: _copy,
        onPastePressed: _paste,
        onSelectAllPressed: _selectAll,
      ),
      iOSToolbarBuilder: (_) => IOSTextEditingFloatingToolbar(
        onCutPressed: _cut,
        onCopyPressed: _copy,
        onPastePressed: _paste,
        focalPoint: _overlayController.toolbarTopAnchor!,
      ),
      overlayController: _overlayController,
    );
  }

  Widget _buildMountedToolbar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MultiListenableBuilder(
        listenables: <Listenable>{
          _composer.selectionNotifier,
        },
        builder: (_) {
          final selection = _composer.selection;

          if (selection == null) {
            return const SizedBox();
          }
          return MyToolBar(
            document: _doc,
            composer: _composer,
            commonOps: _docOps,
            brightness: _brightness.value,
            docEditor: _docEditor,
          );
        },
      ),
    );
  }

  Future<String?> createSummary(
    WidgetRef ref,
    Tuple2<String, String> infos,
    V1Note note,
  ) async {
    try {
      String? summary = await ref.read(noteClientProvider).summaryGenerator(
            noteId: widget.infos.item1,
            groupId: widget.infos.item2,
          );

      return summary;
    } catch (e) {
      print("catch failed to generate summary");
      return null;
    }
  }

  Future<List<V1Widget>?> createRecommendation(
    WidgetRef ref,
    Tuple2<String, String> infos,
    V1Note note,
  ) async {
    try {
      print("note : ${note.blocks?.length}");

      print(note.blocks?.first.paragraph);

      List<V1Widget>? recommendations =
          await ref.read(noteClientProvider).recommendationGenerator(
                noteId: widget.infos.item1,
                groupId: widget.infos.item2,
              );

      return recommendations;
    } catch (e) {
      debugPrint("catch failed to generate recommendation");
      return null;
    }
  }

  bool noteContainMoreThan100Words(V1Note note) {
    int nbWords = 0;

    for (var block in note.blocks!) {
      if (block.type == V1BlockType.PARAGRAPH) {
        nbWords += block.paragraph!.split(" ").length;
      } else if (block.type == V1BlockType.hEADING1 ||
          block.type == V1BlockType.hEADING2 ||
          block.type == V1BlockType.hEADING3) {
        nbWords += block.heading!.split(" ").length;
      } else if (block.type == V1BlockType.BULLET_POINT) {
        nbWords += block.bulletPoint!.split(" ").length;
      } else if (block.type == V1BlockType.NUMBER_POINT) {
        nbWords += block.numberPoint!.split(" ").length;
      }
    }

    if (nbWords < 100) {
      return false;
    }
    return true;
  }
}

class NotedEditorTextStyle {
  final int start;
  final int end;
  final Attribution attribution;
  final DocumentNode node;

  NotedEditorTextStyle({
    required this.start,
    required this.end,
    required this.attribution,
    required this.node,
  });

  @override
  String toString() {
    return "start: $start, end: $end, attribution: ${attribution.id}, node: ${node.id}";
  }
}
