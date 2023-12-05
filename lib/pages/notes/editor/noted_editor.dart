// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:noted_mobile/components/common/custom_alerte.dart';
import 'package:noted_mobile/components/common/custom_modal.dart';
import 'package:noted_mobile/components/common/custom_toast.dart';
import 'package:noted_mobile/data/providers/note_provider.dart';
import 'package:noted_mobile/pages/notes/comment_list.dart';
import 'package:noted_mobile/pages/notes/editor/_custom_component.dart';
import 'package:noted_mobile/pages/notes/editor/_toolbar.dart';
import 'package:noted_mobile/pages/notes/editor/note_utility.dart';
import 'package:noted_mobile/pages/notes/note_summary_screen.dart';
import 'package:noted_mobile/pages/quizz/quizz_screen.dart';
import 'package:noted_mobile/pages/recommendation/recommendation_screen.dart';
import 'package:noted_mobile/utils/color.dart';
import 'package:noted_mobile/utils/string_extension.dart';
import 'package:openapi/openapi.dart';
import 'package:super_editor/super_editor.dart';
import 'package:tuple/tuple.dart';

enum SampleItem { itemOne, itemTwo, itemThree }

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

  final GlobalKey _viewportKey = GlobalKey();
  final GlobalKey _docLayoutKey = GlobalKey();

  late DocumentComposer _composer;
  late DocumentEditor _docEditor;
  late CommonEditorOperations _docOps;

  late FocusNode _editorFocusNode;

  final _brightness = ValueNotifier<Brightness>(Brightness.light);

  OverlayEntry? _textFormatBarOverlayEntry;

  final _overlayController = MagnifierAndToolbarController() //
    ..screenPadding = const EdgeInsets.all(20.0);

  Timer? _timer;

  void _resetTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
  }

  bool isUpdateInProgress = false;

  void updateNote() {
    print("note before update");
    print("length: ${widget.note.blocks?.length}");

    widget.note.blocks?.forEach((p0) {
      print(p0.id);
      print("p0.thread?.length ${p0.thread?.length}");
    });
    _resetTimer();
    print("reset timer");
    print("call update note");

    setState(() {
      isUpdateInProgress = true;
    });

    _timer = Timer(const Duration(seconds: 5), () async {
      print("try update note");

      V1Note updatedNote = getNodeFromDoc(_doc, widget.note);

      print("note after update");
      print("length: ${updatedNote.blocks?.length}");
      updatedNote.blocks?.forEach((p0) {
        print(p0.id);
      });

      try {
        V1Note? updatedNoteResponse =
            await ref.read(noteClientProvider).updateNote(
                  noteId: widget.infos.item1,
                  groupId: widget.infos.item2,
                  note: updatedNote,
                );

        if (updatedNoteResponse == null) {
          print("note is null");
          return;
        }

        // print(updatedNote.toString());

        setState(() {
          isUpdateInProgress = false;
        });

        print("note updated");

        print("length: ${updatedNoteResponse.blocks?.length}");

        for (var element in _doc.nodes) {
          print("element: ${element.id}");
        }

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
        print("catch failed to update note");
        setState(() {
          isUpdateInProgress = false;
        });
        if (kDebugMode) {
          print("Failed to update Note, Api response :${e.toString()}");
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _composer = DocumentComposer();

    _doc = createInitialDocument(widget.note);

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
  }

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

  TextInputSource get _inputSource {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return TextInputSource.ime;
    }
  }

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
  SampleItem? selectedMenu;
  MenuController menuController = MenuController();
  bool allowToggle = true;

  Future<void> deleteNoteDialog(WidgetRef ref) async {
    return await showDialog(
      context: context,
      builder: ((context) {
        return CustomAlertDialog(
          title: "Supprimer la note",
          content: "Voulez-vous vraiment supprimer cette note ?",
          onConfirm: () async {
            await ref.read(noteClientProvider).deleteNote(
                  noteId: widget.infos.item1,
                  groupId: widget.infos.item2,
                );
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<List<V1Quiz>?>? quizzList;

    if (!widget.needInternet!) {
    } else {
      quizzList = ref.watch(quizzListProvider(widget.infos));
    }

    return PopScope(
      canPop: !isUpdateInProgress,
      onPopInvoked: (bool isPop) {
        if (isUpdateInProgress) {
          CustomToast.show(
            message: "Mise à jour en cours",
            type: ToastType.warning,
            context: context,
            gravity: ToastGravity.BOTTOM,
          );
          return;
        }
      },
      child: Scaffold(
        floatingActionButtonLocation: ExpandableFab.location,
        floatingActionButton:
            !widget.needInternet! ? null : _buildNoteTools(ref, quizzList!),
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        body: Stack(
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
                              message: "Mise à jour en cours",
                              type: ToastType.warning,
                              context: context,
                              gravity: ToastGravity.BOTTOM,
                            );
                            return;
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
                      PopupMenuButton(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(16),
                          ),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: const ListTile(
                              leading: Icon(Icons.delete),
                              title: Text("Supprimer"),
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
                          PopupMenuItem(
                            child: const ListTile(
                              leading: Icon(Icons.comment),
                              title: Text("Commentaires"),
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
                  child: _buildEditor(context),
                ),
                if (_isMobile) _buildMountedToolbar(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteTools(
    WidgetRef ref,
    AsyncValue<List<V1Quiz>?> quizzList,
  ) {
    if (!widget.needInternet!) return const SizedBox();

    return ExpandableFab(
      distance: 150,
      type: ExpandableFabType.fan,
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
        FloatingActionButton(
          heroTag: "quiz",
          elevation: 5,
          backgroundColor: NotedColors.secondary,
          foregroundColor: Colors.white,
          onPressed: () async {
            if (quizzList.hasError) {
              print("error quizz list");
              return;
            }
            if (quizzList.isLoading) {
              print("loading quizz list");
              return;
            }

            if (quizzList.value == null) {
              print("quizz list is null");
              return;
            }

            if (quizzList.value!.isEmpty) {
              bool validNote = noteContainMoreThan100Words(widget.note);

              if (!validNote) {
                CustomToast.show(
                  message:
                      "La note doit contenir au moins 100 mots pour générer un quizz",
                  type: ToastType.warning,
                  context: context,
                  gravity: ToastGravity.TOP,
                );

                return;
              }

              setState(() {
                isLoadingQuizz = true;
              });
              bool isQuizzGenerated = await creatQuiz(
                ref,
                widget.infos,
                widget.note,
              );
              if (mounted) {
                if (isQuizzGenerated) {
                  ref.invalidate(quizzListProvider(widget.infos));
                  CustomToast.show(
                    message: "Quizz généré",
                    type: ToastType.success,
                    context: context,
                    gravity: ToastGravity.TOP,
                  );
                } else {
                  CustomToast.show(
                    message: "Erreur lors de la génération du quizz",
                    type: ToastType.error,
                    context: context,
                    gravity: ToastGravity.TOP,
                  );
                }
              }
              setState(() {
                isLoadingQuizz = false;
              });

              print("quizz list is empty");
              return;
            }

            V1Quiz quiz = quizzList.value!.first;

            return showModalBottomSheet(
              backgroundColor: Colors.transparent,
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return CustomModal(
                  height: 0.9,
                  onClose: (context) {
                    print("close");
                    ref.invalidate(quizzListProvider(widget.infos));
                    Navigator.pop(context);
                  },
                  child: QuizzPage(
                    quiz: quiz,
                    infos: widget.infos,
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
        FloatingActionButton(
          heroTag: "recommendation",
          backgroundColor: NotedColors.secondary,
          foregroundColor: Colors.white,
          elevation: 5,
          onPressed: () async {
            bool validNote = noteContainMoreThan100Words(widget.note);

            if (!validNote) {
              CustomToast.show(
                message:
                    "La note doit contenir au moins 100 mots pour générer une recommandation",
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
                message: "Erreur lors de la génération de la recommandation",
                type: ToastType.error,
                context: context,
                gravity: ToastGravity.TOP,
              );
              return;
            }

            if (widgetList!.isEmpty && mounted) {
              CustomToast.show(
                message:
                    "Aucune recommandation n'a été générée.\nContinuer d'écrire pour générer une recommandation",
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
        FloatingActionButton(
          heroTag: "summary",
          backgroundColor: NotedColors.secondary,
          foregroundColor: Colors.white,
          elevation: 5,
          onPressed: () async {
            bool validNote = noteContainMoreThan100Words(widget.note);

            if (!validNote) {
              CustomToast.show(
                message:
                    "La note doit contenir au moins 100 mots pour générer un résumé",
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
                message: "Erreur lors de la génération du résumé",
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
    );
  }

  Widget _buildEditor(BuildContext context) {
    return KeyedSubtree(
      key: _viewportKey,
      child: SuperEditor(
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
          CustomParagraphComponentBuilder(),
          ...defaultComponentBuilders,
        ],
        gestureMode: _gestureMode,
        inputSource: _inputSource,
        keyboardActions: [
          ...defaultKeyboardActions,
          ...notedCustomKeyboardActions
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
      ),
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
      print("catch failed to generate recommendation");
      return null;
    }
  }

  Future<bool> creatQuiz(
      WidgetRef ref, Tuple2<String, String> infos, V1Note note) async {
    try {
      await ref.read(noteClientProvider).quizzGenerator(
            noteId: widget.infos.item1,
            groupId: widget.infos.item2,
          );
      print("quizz generated");
      return true;
    } catch (e) {
      print("catch failed to generate quizz");
      return false;
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

  NotedEditorTextStyle({
    required this.start,
    required this.end,
    required this.attribution,
  });

  @override
  String toString() {
    return "start: $start, end: $end, attribution: $attribution";
  }
}
