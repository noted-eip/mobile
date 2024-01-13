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

  bool get _isStrikethroughActive =>
      _doesSelectionHaveAttributions({strikethroughAttribution});
  void _toggleStrikethrough() =>
      _toggleAttributions({strikethroughAttribution});

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
    NamedAttribution? currentBlockType =
        selectedNode.metadata['blockType'] as NamedAttribution?;

    if (selectedNode is ListItemNode) {
      commonOps.convertToParagraph(
        newMetadata: {
          'blockType': header3Attribution,
        },
      );
    } else {
      NamedAttribution? newBlockType;

      if (currentBlockType == header1Attribution) {
        newBlockType = header1Attribution;
      } else if (currentBlockType == header2Attribution) {
        newBlockType = header1Attribution;
      } else if (currentBlockType == header3Attribution) {
        newBlockType = header2Attribution;
      } else {
        newBlockType = header3Attribution;
      }

      selectedNode.putMetadataValue('blockType', newBlockType);
    }
  }

  void _convertToHeader2() {
    final selectedNode =
        document.getNodeById(composer.selection!.extent.nodeId);
    if (selectedNode is! TextNode) {
      return;
    }
    NamedAttribution? currentBlockType =
        selectedNode.metadata['blockType'] as NamedAttribution?;

    if (selectedNode is ListItemNode) {
      commonOps.convertToParagraph();
    } else {
      NamedAttribution? newBlockType;

      if (currentBlockType == header1Attribution) {
        newBlockType = header2Attribution;
      } else if (currentBlockType == header2Attribution) {
        newBlockType = header3Attribution;
      }

      selectedNode.putMetadataValue('blockType', newBlockType);
    }
  }

  void _convertToParagraph() {
    commonOps.convertToParagraph();
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

  void _convertToBlockquote() {
    final selectedNode =
        document.getNodeById(composer.selection!.extent.nodeId)! as TextNode;

    commonOps.convertToBlockquote(selectedNode.text);
  }

  void _convertToHr() {
    final selectedNode =
        document.getNodeById(composer.selection!.extent.nodeId)! as TextNode;

    selectedNode.text = AttributedText(text: '--- ');
    composer.selection = DocumentSelection.collapsed(
      position: DocumentPosition(
        nodeId: selectedNode.id,
        nodePosition: const TextNodePosition(offset: 4),
      ),
    );
    commonOps.convertParagraphByPatternMatching(selectedNode.id);
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
                              IconButton(
                                onPressed: selectedNode is TextNode
                                    ? _toggleStrikethrough
                                    : null,
                                icon: const Icon(Icons.strikethrough_s),
                                color: _isStrikethroughActive
                                    ? Theme.of(context).primaryColor
                                    : null,
                              ),
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
                                onPressed: isSingleNodeSelected &&
                                        ((selectedNode is ParagraphNode &&
                                                selectedNode.hasMetadataValue(
                                                    'blockType')) ||
                                            (selectedNode is TextNode &&
                                                selectedNode is! ParagraphNode))
                                    ? _convertToParagraph
                                    : null,
                                icon: const Icon(Icons.wrap_text),
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
                                icon: const Icon(Icons.looks_one_rounded),
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
                                icon: const Icon(Icons.list),
                              ),
                              IconButton(
                                onPressed: isSingleNodeSelected &&
                                        selectedNode is TextNode &&
                                        (selectedNode is! ParagraphNode ||
                                            selectedNode.getMetadataValue(
                                                    'blockType') !=
                                                blockquoteAttribution)
                                    ? _convertToBlockquote
                                    : null,
                                icon: const Icon(Icons.format_quote),
                              ),
                              IconButton(
                                onPressed: isSingleNodeSelected &&
                                        selectedNode is ParagraphNode &&
                                        selectedNode.text.text.isEmpty
                                    ? _convertToHr
                                    : null,
                                icon: const Icon(Icons.horizontal_rule),
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
