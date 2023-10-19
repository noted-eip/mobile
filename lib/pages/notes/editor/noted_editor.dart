// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/common/custom_modal.dart';
import 'package:noted_mobile/data/providers/note_provider.dart';
import 'package:noted_mobile/pages/notes/editor/_toolbar.dart';
import 'package:noted_mobile/pages/notes/note_summary_screen.dart';
import 'package:noted_mobile/pages/quizz/quizz_screen.dart';
import 'package:noted_mobile/pages/recommendation/recommendation_screen.dart';
import 'package:openapi/openapi.dart';
import 'package:super_editor/super_editor.dart';
import 'package:tuple/tuple.dart';

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

  DocumentNode getNodeFromBlock(V1Block block) {
    String text = getBlockTextFromV1Block(block);

    switch (block.type) {
      case V1BlockType.hEADING1:
        return ParagraphNode(
          id: block.id != '' ? block.id : UniqueKey().toString(),
          text: AttributedText(text: text),
          metadata: {
            'blockType': header1Attribution,
          },
        );
      case V1BlockType.hEADING2:
        return ParagraphNode(
          id: block.id != '' ? block.id : UniqueKey().toString(),
          text: AttributedText(text: text),
          metadata: {
            'blockType': header2Attribution,
          },
        );
      case V1BlockType.hEADING3:
        return ParagraphNode(
          id: block.id != '' ? block.id : UniqueKey().toString(),
          text: AttributedText(text: text),
          metadata: {
            'blockType': header3Attribution,
          },
        );
      case V1BlockType.BULLET_POINT:
        return ListItemNode.unordered(
          id: block.id != '' ? block.id : UniqueKey().toString(),
          text: AttributedText(text: text),
        );

      case V1BlockType.NUMBER_POINT:
        return ListItemNode.ordered(
          id: block.id != '' ? block.id : UniqueKey().toString(),
          text: AttributedText(text: text),
        );

      default:
        return ParagraphNode(
          id: block.id != '' ? block.id : UniqueKey().toString(),
          text: AttributedText(text: text),
        );
    }
  }

  // DocumentNode getNodeFromBlock(Block block) {
  //   switch (block.type) {
  //     case BlockType.heading1:
  //       return ParagraphNode(
  //         id: block.id != '' ? block.id : UniqueKey().toString(),
  //         text: AttributedText(text: block.text),
  //         metadata: {
  //           'blockType': header1Attribution,
  //         },
  //       );
  //     case BlockType.heading2:
  //       return ParagraphNode(
  //         id: block.id != '' ? block.id : UniqueKey().toString(),
  //         text: AttributedText(text: block.text),
  //         metadata: {
  //           'blockType': header2Attribution,
  //         },
  //       );
  //     case BlockType.heading3:
  //       return ParagraphNode(
  //         id: block.id != '' ? block.id : UniqueKey().toString(),
  //         text: AttributedText(text: block.text),
  //         metadata: {
  //           'blockType': header3Attribution,
  //         },
  //       );
  //     case BlockType.bulletPoint:
  //       return ListItemNode.unordered(
  //         id: block.id != '' ? block.id : UniqueKey().toString(),
  //         text: AttributedText(text: block.text),
  //         // metadata: {
  //         //   'blockType': bulletAttribution,
  //         // },
  //       );

  //     case BlockType.numberPoint:
  //       return ListItemNode.ordered(
  //         id: block.id != '' ? block.id : UniqueKey().toString(),
  //         text: AttributedText(text: block.text),
  //         // metadata: {
  //         //   'blockType': bulletAttribution,
  //         // },
  //       );

  //     default:
  //       return ParagraphNode(
  //         id: block.id != '' ? block.id : UniqueKey().toString(),
  //         text: AttributedText(text: block.text),
  //       );
  //   }
  // }

  String getBlockTextFromV1Block(V1Block block) {
    switch (block.type) {
      case V1BlockType.hEADING1:
        return block.heading ?? '';
      case V1BlockType.hEADING2:
        return block.heading ?? '';
      case V1BlockType.hEADING3:
        return block.heading ?? '';
      case V1BlockType.BULLET_POINT:
        return block.bulletPoint ?? '';
      case V1BlockType.NUMBER_POINT:
        return block.numberPoint ?? '';
      default:
        return block.paragraph ?? '';
    }
  }

  MutableDocument createInitialDocument() {
    List<DocumentNode>? nodes = [];

    if (widget.note.blocks != null) {
      widget.note.blocks!.asMap().forEach((key, block) {
        print(
            "key: $key, block: ${getBlockTextFromV1Block(block)}, ${block.id}, ${block.type}");
        nodes.add(getNodeFromBlock(block));
      });
    }
    return MutableDocument(nodes: nodes);
  }

  void _resetTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
  }

  void updateNote() {
    print("updateNote");
    _resetTimer();

    _timer = Timer(const Duration(seconds: 5), () {
      V1Note updatedNote = V1Note();
      print("L'objet n'a pas été modifié depuis 5 secondes.");
      ref.read(noteClientProvider).updateNote(
          noteId: widget.infos.item1,
          groupId: widget.infos.item2,
          note: updatedNote);
    });
  }

  @override
  void initState() {
    super.initState();
    _composer = DocumentComposer();

    _doc = createInitialDocument();

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

  @override
  Widget build(BuildContext context) {
    final AsyncValue<V1Quiz?> quizz = ref.watch(quizzProvider(widget.infos));
    final AsyncValue<List<V1Widget>?> widgetsList =
        ref.watch(recommendationListProvider(widget.infos));

    return Stack(
      children: [
        Column(
          children: [
            SizedBox(
              height: kToolbarHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text(
                    widget.note.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  quizz.when(
                      data: (quiz) {
                        if (quiz == null) {
                          return const SizedBox();
                        }
                        return Material(
                          color: Colors.transparent,
                          child: PopupMenuButton(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(16),
                              ),
                            ),
                            itemBuilder: ((context) {
                              return [
                                PopupMenuItem(
                                  child: TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);

                                      return showModalBottomSheet(
                                        backgroundColor: Colors.transparent,
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (context) {
                                          return CustomModal(
                                            height: 0.9,
                                            onClose: (context) {
                                              print("close");
                                              ref.invalidate(
                                                  quizzProvider(widget.infos));
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
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.quiz,
                                          color: Colors.grey.shade900,
                                          size: 30,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          "Quiz",
                                          style: TextStyle(
                                            color: Colors.grey.shade900,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                PopupMenuItem(
                                  child: TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();

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
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.recommend,
                                          color: Colors.grey.shade900,
                                          size: 30,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          "Recommandation",
                                          style: TextStyle(
                                            color: Colors.grey.shade900,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                PopupMenuItem(
                                  child: TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();

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
                                            child: SummaryScreen(
                                              infos: widget.infos,
                                              summary:
                                                  "Ceci est un résumé, il est généré automatiquement. Vous pouvez le modifier à votre guise. Il est généré à partir de vos notes. Vous pouvez le modifier à votre guise. Il est généré à partir de vos notes. Vous pouvez le modifier à votre guise. Il est généré à partir de vos notes. Vous pouvez le modifier à votre guise. Il est généré à partir de vos notes. Vous pouvez le modifier à votre guise. Il est généré à partir de vos notes. Vous pouvez le modifier à votre guise. Il est généré à partir de vos notes. Vous pouvez le modifier à votre guise. Il est généré à partir de vos notes.",
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.summarize,
                                          color: Colors.grey.shade900,
                                          size: 30,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          "Résumé",
                                          style: TextStyle(
                                            color: Colors.grey.shade900,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ];
                            }),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Icon(
                                Icons.more_vert,
                                color: Colors.grey.shade900,
                                size: 32,
                              ),
                            ),
                          ),
                        );
                      },
                      error: (err, stack) => const SizedBox(),
                      loading: () => const SizedBox(
                            height: 36,
                            child: Padding(
                                padding: EdgeInsets.only(right: 16),
                                child: CircularProgressIndicator()),
                          )),
                ],
              ),
            ),
            Expanded(
              child: _buildEditor(context),
            ),
            if (_isMobile) _buildMountedToolbar(),
          ],
        ),
        Align(alignment: Alignment.bottomRight, child: _buildCornerFabs()),
      ],
    );
  }

  Widget _buildCornerFabs() {
    return const Padding(
      padding: EdgeInsets.only(right: 16, bottom: 16 + 40),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // _buildLightAndDarkModeToggle(),
        ],
      ),
    );
  }

  Widget _buildLightAndDarkModeToggle() {
    return FloatingActionButton(
      heroTag: "light_dark_mode_toggle",
      backgroundColor: _brightness.value == Brightness.light
          ? _darkBackground
          : _lightBackground,
      foregroundColor: _brightness.value == Brightness.light
          ? _lightBackground
          : _darkBackground,
      elevation: 5,
      onPressed: () {
        printDocument(_doc);
      },
      child: const Icon(
        Icons.print,
      ),
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

        // return KeyboardEditingToolbar(
        //   document: _doc,
        //   composer: _composer,
        //   commonOps: _docOps,
        //   brightness: _brightness.value,
        // );
      },
    );
  }

  List<NotedEditorTextStyle> getAttributionFromDoc(MutableDocument doc) {
    List<NotedEditorTextStyle> textStyles = [];

    for (var node in doc.nodes) {
      if (node is ParagraphNode) {
        AttributedSpans spans = node.text.spans;

        List<SpanMarker> spanMarkers = spans.markers.toList();

        for (SpanMarker startMarker
            in spanMarkers.where((m) => m.markerType == SpanMarkerType.start)) {
          SpanMarker correspondingEndMarker = spanMarkers.firstWhere(
            (m) =>
                m.markerType == SpanMarkerType.end &&
                m.attribution == startMarker.attribution &&
                m.offset >= startMarker.offset,
          );

          textStyles.add(NotedEditorTextStyle(
              start: startMarker.offset,
              end: correspondingEndMarker.offset,
              attribution: startMarker.attribution));
        }
      }
    }

    return textStyles;
  }

  void printDocument(MutableDocument doc) {
    print("printDocument");

    List<NotedEditorTextStyle> textStyles = getAttributionFromDoc(doc);

    print("---------------------------------");
    print("TEXT STYLES");

    for (var element in textStyles) {
      print(element);
    }

    print("---------------------------------");

    for (var node in doc.nodes) {
      // print(node);
      // print(node.)
      node.metadata.forEach((key, value) {
        print("  $key: $value");
      });

      if (node is ParagraphNode) {
        print(node.text.text);
        print("--------------------");
        // print(node.text.spans);

        // for (var marker in spans.markers) {
        //   print(marker);
        // }

        //

        print("--------------------");
      }
      if (node is ImageNode) {
        print(node.metadata);
      }
      if (node is ListItemNode) {
        print(node.text.text);
      }
      if (node is HorizontalRuleNode) {
        print(node.metadata);
      }
      if (node is TaskNode) {
        print(node.text.text);
      }
    }
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

// Makes text light, for use during dark mode styling.
final _darkModeStyles = [
  StyleRule(
    BlockSelector.all,
    (doc, docNode) {
      return {
        "textStyle": const TextStyle(
          color: Color(0xFFCCCCCC),
        ),
      };
    },
  ),
  StyleRule(
    const BlockSelector("header1"),
    (doc, docNode) {
      return {
        "textStyle": const TextStyle(
          color: Color(0xFF888888),
        ),
      };
    },
  ),
  StyleRule(
    const BlockSelector("header2"),
    (doc, docNode) {
      return {
        "textStyle": const TextStyle(
          color: Color(0xFF888888),
        ),
      };
    },
  ),
];
