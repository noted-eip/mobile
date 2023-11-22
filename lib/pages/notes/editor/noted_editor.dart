// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:noted_mobile/components/common/custom_alerte.dart';
import 'package:noted_mobile/components/common/custom_modal.dart';
import 'package:noted_mobile/components/common/custom_toast.dart';
import 'package:noted_mobile/components/common/loading_button.dart';
import 'package:noted_mobile/data/providers/note_provider.dart';
import 'package:noted_mobile/pages/notes/editor/_toolbar.dart';
import 'package:noted_mobile/pages/notes/editor/note_utility.dart';
import 'package:noted_mobile/pages/notes/note_summary_screen.dart';
import 'package:noted_mobile/pages/quizz/quizz_screen.dart';
import 'package:noted_mobile/pages/recommendation/recommendation_screen.dart';
import 'package:noted_mobile/utils/color.dart';
import 'package:noted_mobile/utils/string_extension.dart';
import 'package:openapi/openapi.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:super_editor/super_editor.dart';
import 'package:tuple/tuple.dart';

enum SampleItem { itemOne, itemTwo, itemThree }

class NotedEditor extends ConsumerStatefulWidget {
  const NotedEditor({
    Key? key,
    required this.note,
    required this.infos,
  }) : super(key: key);

  // final Note note;
  final V1Note note;
  final Tuple2<String, String> infos;

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

  final _darkBackground = const Color(0xFF222222);
  final _lightBackground = Colors.white;
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
    _resetTimer();
    print("reset timer");
    print("call update note");

    setState(() {
      isUpdateInProgress = true;
    });

    //

    _timer = Timer(const Duration(seconds: 5), () async {
      print("try update note");

      V1Note updatedNote = getNodeFromDoc(_doc, widget.note);

      print(updatedNote.blocks!.length);

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

        setState(() {
          isUpdateInProgress = false;
        });

        // setState(() {
        //   message = "Note mise à jour";
        //   type = ToastType.success;
        // });
        print("note updated");

        ref.invalidate(noteProvider(widget.infos));
      } catch (e) {
        print("catch failed to update note");
        setState(() {
          isUpdateInProgress = false;
        });
        if (kDebugMode) {
          print("Failed to update Note, Api response :${e.toString()}");
        }
        // if (mounted) {
        //   CustomToast.show(
        //     message: e.toString().capitalize(),
        //     type: ToastType.error,
        //     context: context,
        //     gravity: ToastGravity.BOTTOM,
        //   );
        // }
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
  String? selectedAction;
  SampleItem? selectedMenu;
  MenuController menuController = MenuController();
  bool allowToggle = true;

  Future<void> fetchData() async {
    // Ici, vous pouvez placer votre appel API
    print("fetch data");
    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isLoading = false;
    });
  }

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
    final AsyncValue<List<V1Widget>?> widgetsList =
        ref.watch(recommendationListProvider(widget.infos));
    final AsyncValue<String?> summary =
        ref.watch(noteSummaryProvider(widget.infos));

    final AsyncValue<List<V1Quiz>?> quizzList =
        ref.watch(quizzListProvider(widget.infos));

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
            _buildNoteTools(ref, summary, quizzList, widgetsList),
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
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        ],
                      ),
                      // MenuAnchor(
                      //   controller: menuController,
                      //   style: MenuStyle(
                      //     padding: const MaterialStatePropertyAll<EdgeInsets>(
                      //       EdgeInsets.all(16),
                      //     ),
                      //     shadowColor: MaterialStatePropertyAll<Color>(
                      //       Colors.grey.shade900,
                      //     ),
                      //     side: const MaterialStatePropertyAll<BorderSide>(
                      //       BorderSide(
                      //         color: Colors.grey,
                      //         width: 0.5,
                      //       ),
                      //     ),
                      //     backgroundColor:
                      //         const MaterialStatePropertyAll<Color>(
                      //       Colors.white,
                      //     ),
                      //     elevation: const MaterialStatePropertyAll<double>(4),
                      //     shape: MaterialStatePropertyAll<OutlinedBorder>(
                      //       RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(16),
                      //       ),
                      //     ),
                      //   ),
                      //   onClose: () {
                      //     print("onClose---------------------");
                      //     print("is open: ${menuController.isOpen}");
                      //     print("is loading: $isLoading");

                      //     if (menuController.isOpen && !isLoading) {
                      //       print("is open and not loading");
                      //       menuController.close();
                      //     } else if (menuController.isOpen && isLoading) {
                      //       menuController.close();
                      //       print("is open and loading");
                      //     } else {
                      //       print("is not open and loading");
                      //       menuController.open();
                      //     }
                      //   },
                      //   onOpen: () {
                      //     print("open");
                      //   },
                      //   builder: (
                      //     BuildContext context,
                      //     MenuController controller,
                      //     Widget? child,
                      //   ) {
                      //     return IconButton(
                      //       onPressed: () {
                      //         // if (controller.isOpen && !isLoading) {
                      //         //   controller.close();
                      //         // } else {
                      //         //   controller.open();
                      //         // }
                      //         if (controller.isOpen) {
                      //           controller.close();
                      //         } else {
                      //           controller.open();
                      //         }
                      //       },
                      //       icon: const Icon(Icons.more_horiz),
                      //       tooltip: 'Show menu',
                      //     );
                      //   },
                      //   menuChildren: List<MenuItemButton>.generate(
                      //     3,
                      //     (int index) => MenuItemButton(
                      //       onPressed: () {
                      //         print("onPressed");
                      //         // menuController.open();
                      //         fetchData();
                      //       },
                      //       trailingIcon: SizedBox(
                      //         width: 20,
                      //         height: 20,
                      //         child: isLoading
                      //             ? const CircularProgressIndicator(
                      //                 strokeWidth: 2,
                      //               )
                      //             : null,
                      //       ),
                      //       child: Text('Item ${index + 1}'),
                      //     ),
                      //   ),
                      // ),
                      // quizz.when(
                      //   data: (quiz) {
                      //     if (quiz == null) {
                      //       return const SizedBox();
                      //     }
                      //     return Material(
                      //       color: Colors.transparent,
                      //       child: PopupMenuButton(
                      //         shape: const RoundedRectangleBorder(
                      //           borderRadius: BorderRadius.all(
                      //             Radius.circular(16),
                      //           ),
                      //         ),
                      //         itemBuilder: ((context) {
                      //           return [
                      //             PopupMenuItem(
                      //               child: TextButton(
                      //                 onPressed: () async {
                      //                   Navigator.pop(context);
                      //                   return showModalBottomSheet(
                      //                     backgroundColor: Colors.transparent,
                      //                     context: context,
                      //                     isScrollControlled: true,
                      //                     builder: (context) {
                      //                       return CustomModal(
                      //                         height: 0.9,
                      //                         onClose: (context) {
                      //                           print("close");
                      //                           ref.invalidate(quizzProvider(
                      //                               widget.infos));
                      //                           Navigator.pop(context);
                      //                         },
                      //                         child: QuizzPage(
                      //                           quiz: quiz,
                      //                           infos: widget.infos,
                      //                         ),
                      //                       );
                      //                     },
                      //                   );
                      //                 },
                      //                 child: Row(
                      //                   children: [
                      //                     Icon(
                      //                       Icons.quiz,
                      //                       color: Colors.grey.shade900,
                      //                       size: 30,
                      //                     ),
                      //                     const SizedBox(
                      //                       width: 10,
                      //                     ),
                      //                     Text(
                      //                       "Quiz",
                      //                       style: TextStyle(
                      //                         color: Colors.grey.shade900,
                      //                         fontSize: 14,
                      //                         fontWeight: FontWeight.bold,
                      //                       ),
                      //                     ),
                      //                   ],
                      //                 ),
                      //               ),
                      //             ),
                      //             PopupMenuItem(
                      //               child: TextButton(
                      //                 onPressed: () async {
                      //                   Navigator.of(context).pop();
                      //                   if (!widgetsList.hasValue) {
                      //                     return;
                      //                   }

                      //                   return showModalBottomSheet(
                      //                     backgroundColor: Colors.transparent,
                      //                     context: context,
                      //                     isScrollControlled: true,
                      //                     builder: (context) {
                      //                       return CustomModal(
                      //                         height: 1,
                      //                         onClose: (context) {
                      //                           Navigator.pop(context);
                      //                         },
                      //                         child: RecommendationPage(
                      //                           infos: widget.infos,
                      //                           widgetList: widgetsList.value!,
                      //                         ),
                      //                       );
                      //                     },
                      //                   );
                      //                 },
                      //                 child: Row(
                      //                   children: [
                      //                     Icon(
                      //                       Icons.recommend,
                      //                       color: Colors.grey.shade900,
                      //                       size: 30,
                      //                     ),
                      //                     const SizedBox(
                      //                       width: 10,
                      //                     ),
                      //                     Text(
                      //                       "Recommandation",
                      //                       style: TextStyle(
                      //                         color: Colors.grey.shade900,
                      //                         fontSize: 14,
                      //                         fontWeight: FontWeight.bold,
                      //                       ),
                      //                     ),
                      //                   ],
                      //                 ),
                      //               ),
                      //             ),
                      //             PopupMenuItem(
                      //               child: TextButton(
                      //                 onPressed: () async {
                      //                   Navigator.of(context).pop();
                      //                   if (!summary.hasValue) {
                      //                     return;
                      //                   }
                      //                   return showModalBottomSheet(
                      //                     backgroundColor: Colors.transparent,
                      //                     context: context,
                      //                     isScrollControlled: true,
                      //                     builder: (context) {
                      //                       return CustomModal(
                      //                         height: 1,
                      //                         onClose: (context) {
                      //                           Navigator.pop(context);
                      //                         },
                      //                         child: SummaryScreen(
                      //                           infos: widget.infos,
                      //                           summary: summary.value ?? "",
                      //                         ),
                      //                       );
                      //                     },
                      //                   );
                      //                 },
                      //                 child: Row(
                      //                   children: [
                      //                     Icon(
                      //                       Icons.summarize,
                      //                       color: Colors.grey.shade900,
                      //                       size: 30,
                      //                     ),
                      //                     const SizedBox(
                      //                       width: 10,
                      //                     ),
                      //                     Text(
                      //                       "Résumé",
                      //                       style: TextStyle(
                      //                         color: Colors.grey.shade900,
                      //                         fontSize: 14,
                      //                         fontWeight: FontWeight.bold,
                      //                       ),
                      //                     ),
                      //                   ],
                      //                 ),
                      //               ),
                      //             ),
                      //           ];
                      //         }),
                      //         child: Padding(
                      //           padding:
                      //               const EdgeInsets.symmetric(horizontal: 16),
                      //           child: Icon(
                      //             Icons.more_vert,
                      //             color: Colors.grey.shade900,
                      //             size: 32,
                      //           ),
                      //         ),
                      //       ),
                      //     );
                      //   },
                      //   error: (err, stack) => const SizedBox(),
                      //   loading: () => const SizedBox(
                      //     height: 36,
                      //     child: Padding(
                      //         padding: EdgeInsets.only(right: 16),
                      //         child: CircularProgressIndicator()),
                      //   ),
                      // ),
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
    AsyncValue<String?> summary,
    AsyncValue<List<V1Quiz>?> quizzList,
    AsyncValue<List<V1Widget>?> widgetsList,
  ) {
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
              bool validNote = canGenerateQuizz(widget.note);

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
            if (!widgetsList.hasValue) {
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
                    widgetList: widgetsList.value!,
                  ),
                );
              },
            );
          },
          child: const Icon(
            Icons.recommend,
          ),
        ),
        FloatingActionButton(
          heroTag: "summary",
          backgroundColor: NotedColors.secondary,
          foregroundColor: Colors.white,
          elevation: 5,
          onPressed: () async {
            // Navigator.of(context).pop();

            if (!summary.hasValue) {
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
                    summary: summary.value ?? "",
                  ),
                );
              },
            );
          },
          child: const Icon(
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
        selectionStyle: defaultSelectionStyle,
        stylesheet: defaultStylesheet.copyWith(
          addRulesAfter: [
            taskStyles,
          ],
        ),
        componentBuilders: [
          TaskComponentBuilder(_docEditor),
          ...defaultComponentBuilders,
        ],
        gestureMode: _gestureMode,
        inputSource: _inputSource,
        keyboardActions: _inputSource == TextInputSource.ime
            ? defaultImeKeyboardActions
            : defaultKeyboardActions,
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
    return MultiListenableBuilder(
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
        );
      },
    );
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

  bool canGenerateQuizz(V1Note note) {
    // si le nombre de mots dans tous les blocs est inférieur à 100, on ne peut pas générer de quizz

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
