import 'package:flutter/material.dart' hide ListenableBuilder;
import 'package:super_editor/super_editor.dart';

/// Toolbar that provides document editing capabilities, like converting
/// paragraphs to blockquotes and list items, and inserting horizontal
/// rules.
///
/// This toolbar is intended to be placed just above the keyboard on a
/// mobile device.
class MyToolBar extends StatelessWidget {
  const MyToolBar({
    Key? key,
    required this.document,
    required this.composer,
    required this.commonOps,
    required this.docEditor,
    this.brightness,
  }) : super(key: key);

  final Document document;
  final DocumentComposer composer;
  final CommonEditorOperations commonOps;
  final Brightness? brightness;
  final DocumentEditor docEditor;

  bool get _isBoldActive => _doesSelectionHaveAttributions({boldAttribution});
  void _toggleBold() => _toggleAttributions({boldAttribution});

  bool get _isItalicsActive =>
      _doesSelectionHaveAttributions({italicsAttribution});
  void _toggleItalics() => _toggleAttributions({italicsAttribution});

  bool get _isUnderlineActive =>
      _doesSelectionHaveAttributions({underlineAttribution});
  void _toggleUnderline() => _toggleAttributions({underlineAttribution});

  bool _doesSelectionHaveAttributions(Set<Attribution> attributions) {
    final selection = composer.selection;
    if (selection == null) {
      return false;
    }

    if (selection.isCollapsed) {
      return composer.preferences.currentAttributions.containsAll(attributions);
    }

    return document.doesSelectedTextContainAttributions(
        selection, attributions);
  }

  void _toggleAttributions(Set<Attribution> attributions) {
    final selection = composer.selection;
    if (selection == null) {
      return;
    }

    selection.isCollapsed
        ? commonOps.toggleComposerAttributions(attributions)
        : commonOps.toggleAttributionsOnSelection(attributions);
  }

  void _convertToHeader1() {
    final selectedNode =
        document.getNodeById(composer.selection!.extent.nodeId);
    if (selectedNode is! TextNode) {
      return;
    }

    if (selectedNode is ListItemNode) {
      commonOps.convertToParagraph(
        newMetadata: {
          'blockType': header1Attribution,
        },
      );
    } else {
      selectedNode.putMetadataValue('blockType', header1Attribution);
    }
  }

  void _convertToHeader2() {
    final selectedNode =
        document.getNodeById(composer.selection!.extent.nodeId);
    if (selectedNode is! TextNode) {
      return;
    }

    if (selectedNode is ListItemNode) {
      commonOps.convertToParagraph(
        newMetadata: {
          'blockType': header2Attribution,
        },
      );
    } else {
      selectedNode.putMetadataValue('blockType', header2Attribution);
    }
  }

  void _convertToHeader3() {
    final selectedNode =
        document.getNodeById(composer.selection!.extent.nodeId);
    if (selectedNode is! TextNode) {
      return;
    }

    if (selectedNode is ListItemNode) {
      commonOps.convertToParagraph(
        newMetadata: {
          'blockType': header3Attribution,
        },
      );
    } else {
      selectedNode.putMetadataValue('blockType', header3Attribution);
    }
  }

  void _convertToParagraph() {
    commonOps.convertToParagraph();

    final selectedNode =
        document.getNodeById(composer.selection!.extent.nodeId)!;

    if (selectedNode is TextNode) {
      selectedNode.putMetadataValue('blockType', null);
    }
  }

  void _convertToOrderedListItem() {
    final selectedNode =
        document.getNodeById(composer.selection!.extent.nodeId)! as TextNode;

    commonOps.convertToListItem(ListItemType.ordered, selectedNode.text);
  }

  void _convertToUnorderedListItem() {
    final selectedNode =
        document.getNodeById(composer.selection!.extent.nodeId)! as TextNode;

    commonOps.convertToListItem(ListItemType.unordered, selectedNode.text);
  }

  void _closeKeyboard() {
    composer.selection = null;
  }

  @override
  Widget build(BuildContext context) {
    final selection = composer.selection;

    if (selection == null) {
      return const SizedBox();
    }

    final brightness =
        this.brightness ?? MediaQuery.of(context).platformBrightness;

    return Theme(
      data: Theme.of(context).copyWith(
        brightness: brightness,
        disabledColor: brightness == Brightness.light
            ? Colors.black.withOpacity(0.5)
            : Colors.white.withOpacity(0.5),
      ),
      child: IconTheme(
        data: IconThemeData(
          color: brightness == Brightness.light ? Colors.black : Colors.white,
        ),
        child: Material(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: double.infinity,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(8)),
              border: Border(
                top: BorderSide(color: Color(0xFFCCCCCC)),
                bottom: BorderSide(color: Color(0xFFCCCCCC)),
                left: BorderSide(color: Color(0xFFCCCCCC)),
                right: BorderSide(color: Color(0xFFCCCCCC)),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _closeKeyboard,
                  icon: const Icon(Icons.keyboard_hide),
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: const Color(0xFFCCCCCC),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ListenableBuilder(
                        listenable: composer,
                        builder: (context) {
                          final selectedNode =
                              document.getNodeById(selection.extent.nodeId);
                          final isSingleNodeSelected =
                              selection.extent.nodeId == selection.base.nodeId;

                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: _convertToHeader1,
                                icon: const Icon(Icons.title),
                              ),
                              IconButton(
                                onPressed: _convertToHeader2,
                                icon: const Icon(Icons.title),
                                iconSize: 18,
                              ),
                              IconButton(
                                onPressed: _convertToHeader3,
                                icon: const Icon(Icons.title),
                                iconSize: 16,
                              ),
                              IconButton(
                                onPressed: isSingleNodeSelected &&
                                        ((selectedNode is ParagraphNode &&
                                                selectedNode.hasMetadataValue(
                                                    'blockType')) ||
                                            (selectedNode is TextNode &&
                                                selectedNode is! ParagraphNode))
                                    ? _convertToParagraph
                                    : null,
                                icon: const Icon(Icons.format_clear_outlined),
                              ),
                              IconButton(
                                onPressed: isSingleNodeSelected &&
                                        (selectedNode is TextNode &&
                                                selectedNode is! ListItemNode ||
                                            (selectedNode is ListItemNode &&
                                                selectedNode.type !=
                                                    ListItemType.ordered))
                                    ? _convertToOrderedListItem
                                    : null,
                                icon: const Icon(
                                    Icons.format_list_numbered_rounded),
                              ),
                              IconButton(
                                onPressed: isSingleNodeSelected &&
                                        (selectedNode is TextNode &&
                                                selectedNode is! ListItemNode ||
                                            (selectedNode is ListItemNode &&
                                                selectedNode.type !=
                                                    ListItemType.unordered))
                                    ? _convertToUnorderedListItem
                                    : null,
                                icon: const Icon(Icons.format_list_bulleted),
                              ),
                              IconButton(
                                onPressed: selectedNode is TextNode
                                    ? _toggleBold
                                    : null,
                                icon: const Icon(Icons.format_bold),
                                color: _isBoldActive
                                    ? Theme.of(context).primaryColor
                                    : null,
                              ),
                              IconButton(
                                onPressed: selectedNode is TextNode
                                    ? _toggleItalics
                                    : null,
                                icon: const Icon(Icons.format_italic),
                                color: _isItalicsActive
                                    ? Theme.of(context).primaryColor
                                    : null,
                              ),
                              IconButton(
                                onPressed: selectedNode is TextNode
                                    ? _toggleUnderline
                                    : null,
                                icon: const Icon(Icons.format_underline),
                                color: _isUnderlineActive
                                    ? Theme.of(context).primaryColor
                                    : null,
                              ),
                            ],
                          );
                        }),
                  ),
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: const Color(0xFFCCCCCC),
                ),
                const SizedBox(width: 70),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
