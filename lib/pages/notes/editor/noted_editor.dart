import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:noted_mobile/components/common/custom_toast.dart';
import 'package:noted_mobile/data/providers/note_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/pages/notes/comment_app_bar.dart';
import 'package:noted_mobile/pages/notes/editor/_custom_component.dart';
import 'package:noted_mobile/pages/notes/editor/_style_sheet.dart';
import 'package:noted_mobile/pages/notes/editor/_toolbar.dart';
import 'package:noted_mobile/pages/notes/editor/note_tools.dart';
import 'package:noted_mobile/pages/notes/editor/note_utility.dart';
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
  }) : super(key: key);

  final V1Note note;
  final Tuple2<String, String> infos;

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
  final MagnifierAndToolbarController _overlayController =
      MagnifierAndToolbarController()
        ..screenPadding = const EdgeInsets.all(20.0);
  Timer? _timer;

  bool isUpdateInProgress = false;
  bool isReadOnly = false;
  late String userId;

  String? selectedAction;
  MenuController menuController = MenuController();
  bool allowToggle = true;

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

  void _resetTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
  }

  @override
  void initState() {
    super.initState();

    _composer = DocumentComposer();

    _doc = NotedNoteUtility.createInitialDocument(note: widget.note);
    _docReadOnly = NotedNoteUtility.createInitialDocument(
        note: widget.note, readOnly: true);

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

  void onBackButtonPressed() {
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
  }

  void onCommentChanged() {
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
            NotedNoteUtility.getV1NoteFromDoc(_doc, widget.note);
        _docReadOnly = NotedNoteUtility.createInitialDocument(
          note: updatedNote,
          readOnly: true,
        );
      }
    });
  }

  Future<bool> onWillPop() async {
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
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        floatingActionButtonLocation: ExpandableFab.location,
        floatingActionButton:
            NotedNoteTools(infos: widget.infos, note: widget.note),
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
                          onPressed: onBackButtonPressed,
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
                                  size: 16,
                                )
                              : null,
                        ),
                        CommentSectionAppBar(
                          note: widget.note,
                          infos: widget.infos,
                          isReadOnly: isReadOnly,
                          onCommentChanged: onCommentChanged,
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

  void updateNote() {
    setState(() {
      isUpdateInProgress = true;
    });

    _resetTimer();

    _timer = Timer(const Duration(seconds: 2), () async {
      V1Note updatedNote = NotedNoteUtility.getV1NoteFromDoc(_doc, widget.note);

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

        NotedNoteUtility.updateDocument(
          updatedNoteResponse: updatedNoteResponse,
          doc: _doc,
          composer: _composer,
        );

        ref.invalidate(noteProvider(widget.infos));
      } catch (e) {
        setState(() {
          isUpdateInProgress = false;
        });
      }
    });
  }

  Widget _buildEditor(BuildContext context, WidgetRef ref) {
    var userId = ref.read(userProvider).id;

    if (userId != widget.note.authorAccountId || isReadOnly) {
      return SuperReader(
        document: _docReadOnly,
        componentBuilders: [
          ...defaultComponentBuilders,
          CustomParagraphComponentBuilder(),
        ],
        stylesheet: styleSheet,
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
      stylesheet: styleSheet,
      componentBuilders: [
        ...defaultComponentBuilders,
      ],
      gestureMode: _gestureMode,
      inputSource: TextInputSource.ime,
      keyboardActions: [
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
}
