// import 'package:flutter/rendering.dart';
import 'package:super_editor/super_editor.dart';

MutableDocument createInitialDocument() {
  return MutableDocument(
    nodes: [
      ParagraphNode(
        id: DocumentEditor.createNodeId(),
        text: AttributedText(text: 'Welcome to Noted Editor !'),
        metadata: {
          'blockType': header1Attribution,
        },
      ),
      ParagraphNode(
        id: DocumentEditor.createNodeId(),
        text: AttributedText(
          text: "Noted is an app for taking notes.",
        ),
        metadata: {
          'blockType': header2Attribution,
        },
      ),
      ParagraphNode(
        id: DocumentEditor.createNodeId(),
        text: AttributedText(text: 'Features 🎉'),
        metadata: {
          'blockType': header2Attribution,
        },
      ),
      ListItemNode.unordered(
        id: DocumentEditor.createNodeId(),
        text: AttributedText(
          text:
              'Text formatting, including bold, italic, underline, strikethrough, and code.',
        ),
      ),
      ListItemNode.unordered(
        id: DocumentEditor.createNodeId(),
        text: AttributedText(
          text: 'Recommendations based on your note content.',
        ),
      ),
      ListItemNode.unordered(
        id: DocumentEditor.createNodeId(),
        text: AttributedText(
          text: 'Quizzes automatically generated from your notes.',
        ),
      ),
      // ParagraphNode(
      //   id: DocumentEditor.createNodeId(),
      //   text: AttributedText(text: 'Quickstart 🚀'),
      //   metadata: {
      //     'blockType': header2Attribution,
      //   },
      // ),
      // ParagraphNode(
      //   id: DocumentEditor.createNodeId(),
      //   text: AttributedText(
      //       text:
      //           'To get started with your own editing experience, take the following steps:'),
      // ),
      // TaskNode(
      //   id: DocumentEditor.createNodeId(),
      //   isComplete: false,
      //   text: AttributedText(
      //     text:
      //         'Create and configure your document, for example, by creating a new MutableDocument.',
      //   ),
      // ),
      // TaskNode(
      //   id: DocumentEditor.createNodeId(),
      //   isComplete: false,
      //   text: AttributedText(
      //     text:
      //         "If you want programmatic control over the user's selection and styles, create a DocumentComposer.",
      //   ),
      // ),
      // TaskNode(
      //   id: DocumentEditor.createNodeId(),
      //   isComplete: false,
      //   text: AttributedText(
      //     text:
      //         "Build a SuperEditor widget in your widget tree, configured with your Document and (optionally) your DocumentComposer.",
      //   ),
      // ),
      // ParagraphNode(
      //   id: DocumentEditor.createNodeId(),
      //   text: AttributedText(
      //     text:
      //         "Now, you're off to the races! SuperEditor renders your document, and lets you select, insert, and delete content.",
      //   ),
      // ),
      // ParagraphNode(
      //   id: DocumentEditor.createNodeId(),
      //   text: AttributedText(text: 'Explore the toolkit 🔎'),
      //   metadata: {
      //     'blockType': header2Attribution,
      //   },
      // ),
      // ListItemNode.unordered(
      //   id: DocumentEditor.createNodeId(),
      //   text: AttributedText(
      //     text:
      //         "Use MutableDocument as an in-memory representation of a document.",
      //   ),
      // ),
      // ListItemNode.unordered(
      //   id: DocumentEditor.createNodeId(),
      //   text: AttributedText(
      //     text:
      //         "Implement your own document data store by implementing the Document api.",
      //   ),
      // ),
      // ListItemNode.unordered(
      //   id: DocumentEditor.createNodeId(),
      //   text: AttributedText(
      //     text:
      //         "Implement your down DocumentLayout to position and size document components however you'd like.",
      //   ),
      // ),
      // ListItemNode.unordered(
      //   id: DocumentEditor.createNodeId(),
      //   text: AttributedText(
      //     text:
      //         "Use SuperSelectableText to paint text with selection boxes and a caret.",
      //   ),
      // ),
      // ListItemNode.unordered(
      //   id: DocumentEditor.createNodeId(),
      //   text: AttributedText(
      //     text:
      //         'Use AttributedText to quickly and easily apply metadata spans to a string.',
      //   ),
      // ),
      // ParagraphNode(
      //   id: DocumentEditor.createNodeId(),
      //   text: AttributedText(
      //     text:
      //         "We hope you enjoy using Super Editor. Let us know what you're building, and please file issues for any bugs that you find.",
      //   ),
      // ),
    ],
  );
}
