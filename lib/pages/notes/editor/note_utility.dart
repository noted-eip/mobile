import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';
import 'package:noted_mobile/pages/notes/editor/noted_editor.dart';
import 'package:openapi/openapi.dart';
import 'package:super_editor/super_editor.dart';

V1Note getNodeFromDoc(Document doc, V1Note note) {
  List<V1Block>? blocks = [];

  for (var node in doc.nodes) {
    blocks.add(getBlockFromNode(node));
  }

  return note.rebuild((rebuild) {
    rebuild.blocks = ListBuilder<V1Block>(blocks);
  });

  // return V1Note((p0) {
  //   p0.id = note.id;
  //   p0.groupId = note.groupId;
  //   p0.authorAccountId = note.authorAccountId;
  //   p0.title = note.title;
  //   p0.createdAt = note.createdAt;
  //   p0.modifiedAt = DateTime.now().toUtc();
  //   p0.analyzedAt = note.analyzedAt;
  //   p0.blocks = ListBuilder<V1Block>(blocks);
  // });

  // return {} as V1Note;
}

V1Block getBlockFromNode(DocumentNode node) {
  String? content;
  V1BlockType? type;

  if (node is ParagraphNode) {
    content = node.text.text;
    if (node.metadata['blockType'] == header1Attribution) {
      type = V1BlockType.hEADING1;
    } else if (node.metadata['blockType'] == header2Attribution) {
      type = V1BlockType.hEADING2;
    } else if (node.metadata['blockType'] == header3Attribution) {
      type = V1BlockType.hEADING3;
    } else {
      type = V1BlockType.PARAGRAPH;
    }
  } else if (node is ListItemNode) {
    content = node.text.text;
    node.type == ListItemType.unordered
        ? type = V1BlockType.BULLET_POINT
        : type = V1BlockType.NUMBER_POINT;
  }

  return V1Block((builder) {
    builder
      ..id = node.id
      ..type = type
      ..heading = type == V1BlockType.hEADING1 ||
              type == V1BlockType.hEADING2 ||
              type == V1BlockType.hEADING3
          ? content
          : null
      ..paragraph = type == V1BlockType.PARAGRAPH ? content : null
      ..bulletPoint = type == V1BlockType.BULLET_POINT ? content : null
      ..numberPoint = type == V1BlockType.NUMBER_POINT ? content : null;
  });

  // return V1Block().rebuild((p0) {
  //   p0.id = node.id;
  //   p0.type = type;

  //   if (type == V1BlockType.BULLET_POINT) {
  //     p0.bulletPoint = content;
  //   } else if (type == V1BlockType.NUMBER_POINT) {
  //     p0.numberPoint = content;
  //   } else if (type == V1BlockType.hEADING1 ||
  //       type == V1BlockType.hEADING2 ||
  //       type == V1BlockType.hEADING3) {
  //     p0.heading = content;
  //   } else {
  //     p0.paragraph = content;
  //   }
  // });
}

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

MutableDocument createInitialDocument(V1Note note) {
  List<DocumentNode>? nodes = [];

  if (note.blocks != null) {
    note.blocks!.asMap().forEach((key, block) {
      print(
          "key: $key, block: ${getBlockTextFromV1Block(block)}, ${block.id}, ${block.type}");
      nodes.add(getNodeFromBlock(block));
    });
  }
  return MutableDocument(nodes: nodes);
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
