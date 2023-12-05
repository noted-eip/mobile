import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noted_mobile/pages/notes/comment_section.dart';
import 'package:super_editor/super_editor.dart';

class CustomParagraphNode extends TextNode {
  CustomParagraphNode({
    required String id,
    required AttributedText text,
    Map<String, dynamic>? metadata,
  }) : super(id: id, text: text, metadata: metadata) {
    // putMetadataValue("blockType", const NamedAttribution("task"));
  }

  @override
  bool hasEquivalentContent(DocumentNode other) {
    return other is CustomParagraphNode && text == other.text;
  }
}

/// Styles all task components to apply top padding
// final customTaskStyles = StyleRule(
//   const BlockSelector("paragraph"),
//   (document, node) {
//     if (node is! CustomParagraphNode) {
//       return {};
//     }

//     return {
//       "padding": const CascadingPadding.only(top: 24),
//     };
//   },
// );

/// Builds [CustomTaskComponentViewModel]s and [CustomTaskComponent]s for every
/// [CustomParagraphNode] in a document.
class CustomParagraphComponentBuilder implements ComponentBuilder {
  CustomParagraphComponentBuilder();

  @override
  CustomTaskComponentViewModel? createViewModel(
      Document document, DocumentNode node) {
    if (node is! CustomParagraphNode) {
      return null;
    }

    return CustomTaskComponentViewModel(
      nodeId: node.id,
      padding: EdgeInsets.zero,
      text: node.text,
      textStyleBuilder: noStyleBuilder,
      selectionColor: const Color(0x00000000),
    );
  }

  @override
  Widget? createComponent(SingleColumnDocumentComponentContext componentContext,
      SingleColumnLayoutComponentViewModel componentViewModel) {
    if (componentViewModel is! CustomTaskComponentViewModel) {
      return null;
    }

    return CustomTaskComponent(
      key: componentContext.componentKey,
      viewModel: componentViewModel,
    );
  }
}

/// View model that configures the appearance of a [CustomTaskComponent].
///
/// View models move through various style phases, which fill out
/// various properties in the view model. For example, one phase applies
/// all [StyleRule]s, and another phase configures content selection
/// and caret appearance.
class CustomTaskComponentViewModel extends SingleColumnLayoutComponentViewModel
    with TextComponentViewModel {
  CustomTaskComponentViewModel({
    required String nodeId,
    double? maxWidth,
    required EdgeInsetsGeometry padding,
    required this.text,
    required this.textStyleBuilder,
    this.textDirection = TextDirection.ltr,
    this.textAlignment = TextAlign.left,
    this.selection,
    required this.selectionColor,
    this.highlightWhenEmpty = false,
  }) : super(nodeId: nodeId, maxWidth: maxWidth, padding: padding);

  AttributedText text;

  @override
  AttributionStyleBuilder textStyleBuilder;
  @override
  TextDirection textDirection;
  @override
  TextAlign textAlignment;
  @override
  TextSelection? selection;
  @override
  Color selectionColor;
  @override
  bool highlightWhenEmpty;

  @override
  CustomTaskComponentViewModel copy() {
    return CustomTaskComponentViewModel(
      nodeId: nodeId,
      maxWidth: maxWidth,
      padding: padding,
      text: text,
      textStyleBuilder: textStyleBuilder,
      textDirection: textDirection,
      selection: selection,
      selectionColor: selectionColor,
      highlightWhenEmpty: highlightWhenEmpty,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is CustomTaskComponentViewModel &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          textDirection == other.textDirection &&
          textAlignment == other.textAlignment &&
          selection == other.selection &&
          selectionColor == other.selectionColor &&
          highlightWhenEmpty == other.highlightWhenEmpty;

  @override
  int get hashCode =>
      super.hashCode ^
      text.hashCode ^
      textDirection.hashCode ^
      textAlignment.hashCode ^
      selection.hashCode ^
      selectionColor.hashCode ^
      highlightWhenEmpty.hashCode;
}

/// A document component that displays a complete-able task.
///
/// This is the widget that appears in the document layout for
/// an individual task. This widget includes a checkbox that the
/// user can tap to toggle the completeness of the task.
///
/// The appearance of a [CustomTaskComponent] is configured by the given
/// [viewModel].
class CustomTaskComponent extends StatefulWidget {
  const CustomTaskComponent({
    Key? key,
    required this.viewModel,
    this.showDebugPaint = false,
  }) : super(key: key);

  final CustomTaskComponentViewModel viewModel;
  final bool showDebugPaint;

  @override
  State<CustomTaskComponent> createState() => _CustomTaskComponentState();
}

class _CustomTaskComponentState extends State<CustomTaskComponent>
    with ProxyDocumentComponent<CustomTaskComponent>, ProxyTextComposable {
  final _textKey = GlobalKey(debugLabel: "Text");

  @override
  GlobalKey<State<StatefulWidget>> get childDocumentComponentKey => _textKey;

  @override
  TextComposable get childTextComposable =>
      childDocumentComponentKey.currentState as TextComposable;

  bool isValidNodeId = false;

  @override
  void initState() {
    super.initState();
    isValidNodeId = widget.viewModel.nodeId.length == 21;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TextComponent(
          key: _textKey,
          text: widget.viewModel.text,
          textStyleBuilder: (attributions) {
            return widget.viewModel.textStyleBuilder(attributions);
          },
          textSelection: widget.viewModel.selection,
          selectionColor: widget.viewModel.selectionColor,
          highlightWhenEmpty: widget.viewModel.highlightWhenEmpty,
          showDebugPaint: widget.showDebugPaint,
        ),
        if (isValidNodeId && widget.viewModel.text.text.isNotEmpty)
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: CupertinoContextMenu.builder(
                  actions: [
                    CupertinoContextMenuAction(
                        isDefaultAction: true,
                        onPressed: () async {
                          Navigator.pop(context);

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CommentSection(
                                blockId: widget.viewModel.nodeId,
                              ),
                            ),
                          );
                        },
                        child: const Text("Comment"))
                  ],
                  builder: (BuildContext context, Animation<double> animation) {
                    return Material(
                      color: Colors.transparent,
                      child: Hero(
                        tag: widget.viewModel.nodeId,
                        child: Container(
                          padding: animation.value <
                                  CupertinoContextMenu.animationOpensAt
                              ? const EdgeInsets.all(0)
                              : const EdgeInsets.all(16),
                          margin: animation.value <
                                  CupertinoContextMenu.animationOpensAt
                              ? const EdgeInsets.all(0)
                              : const EdgeInsets.all(8),
                          decoration: animation.value <
                                  CupertinoContextMenu.animationOpensAt
                              ? const BoxDecoration(
                                  color: Colors.transparent,
                                  boxShadow: <BoxShadow>[],
                                )
                              : BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.white,
                                  boxShadow: CupertinoContextMenu.kEndBoxShadow,
                                ),
                          child: AutoSizeText(
                            widget.viewModel.text.text,
                            style: TextStyle(
                              color: animation.value <
                                      CupertinoContextMenu.animationOpensAt
                                  ? Colors.transparent
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ),
      ],
    );
  }
}

ExecutionInstruction enterToInsertNewCustomParagraph({
  required EditContext editContext,
  required RawKeyEvent keyEvent,
}) {
  if (keyEvent is! RawKeyDownEvent) {
    return ExecutionInstruction.continueExecution;
  }

  // We only care about ENTER.
  if (keyEvent.logicalKey != LogicalKeyboardKey.enter &&
      keyEvent.logicalKey != LogicalKeyboardKey.numpadEnter) {
    return ExecutionInstruction.continueExecution;
  }

  // We only care when the selection is collapsed to a caret.
  final selection = editContext.composer.selection;
  if (selection == null || !selection.isCollapsed) {
    return ExecutionInstruction.continueExecution;
  }

  // We only care about TaskNodes.
  final node = editContext.editor.document.getNodeById(selection.extent.nodeId);
  if (node is! CustomParagraphNode) {
    return ExecutionInstruction.continueExecution;
  }

  // The document selection is a caret sitting at the end of a TaskNode.
  // Insert a new TaskNode below the current TaskNode, and move the caret down.
  editContext.editor.executeCommand(
    InsertNewTaskOrSplitExistingTaskCommand(editContext.composer),
  );

  return ExecutionInstruction.haltExecution;
}

class ConvertParagraphToCustomParagraphCommand implements EditorCommand {
  const ConvertParagraphToCustomParagraphCommand({
    required this.nodeId,
    this.isCompleted = false,
  });

  final String nodeId;
  final bool isCompleted;

  @override
  void execute(Document document, DocumentEditorTransaction transaction) {
    final existingNode = document.getNodeById(nodeId);
    if (existingNode is! ParagraphNode) {
      editorOpsLog.warning(
          "Tried to convert ParagraphNode with ID '$nodeId' to TaskNode, but that node has the wrong type: ${existingNode.runtimeType}");
      return;
    }

    final taskNode = CustomParagraphNode(
      id: existingNode.id,
      text: existingNode.text,
    );

    transaction.replaceNode(oldNode: existingNode, newNode: taskNode);
  }
}

class InsertNewTaskOrSplitExistingTaskCommand implements EditorCommand {
  const InsertNewTaskOrSplitExistingTaskCommand(this._composer);

  final DocumentComposer _composer;

  @override
  void execute(Document document, DocumentEditorTransaction transaction) {
    final selection = _composer.selection;

    // We only care when the caret sits at the end of a TaskNode.
    if (selection == null || !selection.isCollapsed) {
      return;
    }

    // We only care about TaskNodes.
    final node = document.getNodeById(selection.extent.nodeId);
    if (node is! CustomParagraphNode) {
      return;
    }

    // Split the task text at the caret, moving everything after the caret down to the
    // new TaskNode.
    //
    // If the caret sits at the end of the task text, then this behavior is equivalent
    // to inserting a new, empty TaskNode after the current TaskNode.
    final selectionTextOffset =
        (selection.extent.nodePosition as TextNodePosition).offset;
    final newTaskNode = CustomParagraphNode(
      id: DocumentEditor.createNodeId(),
      text: node.text.copyText(selectionTextOffset),
    );
    node.text = node.text.removeRegion(
        startOffset: selectionTextOffset, endOffset: node.text.text.length);

    transaction.insertNodeAfter(existingNode: node, newNode: newTaskNode);

    _composer.selectionNotifier.value = DocumentSelection.collapsed(
      position: DocumentPosition(
        nodeId: newTaskNode.id,
        nodePosition: const TextNodePosition(offset: 0),
      ),
    );
  }
}

final notedCustomKeyboardActions = <DocumentKeyboardAction>[
  enterToInsertNewCustomParagraph,
];
