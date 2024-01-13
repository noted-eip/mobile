// ignore_for_file: avoid_print

import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:noted_mobile/pages/notes/editor/_custom_component.dart';
import 'package:noted_mobile/pages/notes/editor/noted_editor.dart';
import 'package:openapi/openapi.dart';
import 'package:super_editor/super_editor.dart';

V1Note getV1NoteFromDoc(Document doc, V1Note note) {
  List<V1Block>? blocks = [];

  for (var node in doc.nodes) {
    blocks.add(getBlockFromNode(node));
  }

  for (var p0 in blocks) {
    print("style for block Id: ${p0.id}, ${p0.styles}");
  }

  return note.rebuild((rebuild) {
    rebuild.blocks = ListBuilder<V1Block>(blocks);
  });
}

V1Block getBlockFromNode(DocumentNode node) {
  String? content;
  V1BlockType? type;

  if (node is CustomParagraphNode) {
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
  } else if (node is ParagraphNode) {
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
  } else {
    type = V1BlockType.PARAGRAPH;
  }

  return V1Block((builder) {
    builder
      ..styles = getStylesFromNode(node)
      ..id = node.id.length == 21 ? node.id : ""
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
}

ListBuilder<BlockTextStyle>? getStylesFromNode(DocumentNode node) {
  ListBuilder<BlockTextStyle>? styles = ListBuilder<BlockTextStyle>();

  if (node is CustomParagraphNode) {
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

      var style = BlockTextStyle((builder) {
        builder
          ..style = getStyleFromAttribution(startMarker.attribution)
          ..pos = getPosFromStartAndEnd(
              startMarker.offset, correspondingEndMarker.offset);
      });

      styles.add(style);
    }
  }

  if (styles.isEmpty) {
    return null;
  }
  print("getStylesFromNode: ${styles.first.style?.name}");

  return styles;
}

TextStylePositionBuilder? getPosFromStartAndEnd(int start, int end) {
  var position = TextStylePositionBuilder();

  position.start = (start).toString();
  position.length = (end - start).toString();

  return position;
}

TextStyleStyle? getStyleFromAttribution(Attribution attribution) {
  switch (attribution.id) {
    case "bold":
      return TextStyleStyle.BOLD;
    case "italics":
      return TextStyleStyle.ITALIC;
    case "underline":
      return TextStyleStyle.UNDERLINE;
    // case "strikethrough":
    //   return TextStyleStyle.;
    default:
      return null;
  }
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

Attribution getAttributionFromStyle(BlockTextStyle style) {
  switch (style.style) {
    case TextStyleStyle.BOLD:
      return boldAttribution;
    case TextStyleStyle.ITALIC:
      return italicsAttribution;
    case TextStyleStyle.UNDERLINE:
      return underlineAttribution;
    // case TextStyleStyle.STRIKETHROUGH:
    //   return underlineAttribution;
    default:
      return boldAttribution;
  }
}

AttributedSpans? getAttributedSpanFromBlock(V1Block block) {
  AttributedSpans? spans;

  if (block.styles != null) {
    spans = AttributedSpans();

    for (var style in block.styles!) {
      spans.addAttribution(
        start: int.parse(style.pos!.start!),
        end: int.parse(style.pos!.length!) + int.parse(style.pos!.start!),
        newAttribution: getAttributionFromStyle(style),
      );
    }
  }

  return spans;
}

DocumentNode getNodeFromBlock(V1Block block) {
  String text = getBlockTextFromV1Block(block);

  AttributedSpans? spans = getAttributedSpanFromBlock(block);

  print("Block = $block");
  print("getNodeFromBlock: ${block.id}");
  print("getNodeFromBlock: ${block.styles}");

  switch (block.type) {
    case V1BlockType.hEADING1:
      return ParagraphNode(
        id: block.id != '' ? block.id : UniqueKey().toString(),
        text: AttributedText(text: text, spans: spans),
        metadata: {
          'blockType': header1Attribution,
        },
      );
    case V1BlockType.hEADING2:
      return ParagraphNode(
        id: block.id != '' ? block.id : UniqueKey().toString(),
        text: AttributedText(text: text, spans: spans),
        metadata: {
          'blockType': header2Attribution,
        },
      );
    case V1BlockType.hEADING3:
      return ParagraphNode(
        id: block.id != '' ? block.id : UniqueKey().toString(),
        text: AttributedText(text: text, spans: spans),
        metadata: {
          'blockType': header3Attribution,
        },
      );
    case V1BlockType.BULLET_POINT:
      return ListItemNode.unordered(
        id: block.id != '' ? block.id : UniqueKey().toString(),
        text: AttributedText(text: text, spans: spans),
      );

    case V1BlockType.NUMBER_POINT:
      return ListItemNode.ordered(
        id: block.id != '' ? block.id : UniqueKey().toString(),
        text: AttributedText(text: text, spans: spans),
      );

    default:
      return ParagraphNode(
        id: block.id != '' ? block.id : UniqueKey().toString(),
        text: AttributedText(text: text, spans: spans),
      );
  }
}

DocumentNode getNodeFromBlockReadOnly(V1Block block) {
  String text = getBlockTextFromV1Block(block);

  AttributedSpans? spans = getAttributedSpanFromBlock(block);

  print("Block = $block");
  print("getNodeFromBlock: ${block.id}");
  print("getNodeFromBlock: ${block.styles}");

  switch (block.type) {
    case V1BlockType.hEADING1:
      return CustomParagraphNode(
        id: block.id != '' ? block.id : UniqueKey().toString(),
        text: AttributedText(text: text, spans: spans),
        metadata: {
          'blockType': header1Attribution,
        },
      );
    case V1BlockType.hEADING2:
      return CustomParagraphNode(
        id: block.id != '' ? block.id : UniqueKey().toString(),
        text: AttributedText(text: text, spans: spans),
        metadata: {
          'blockType': header2Attribution,
        },
      );
    case V1BlockType.hEADING3:
      return CustomParagraphNode(
        id: block.id != '' ? block.id : UniqueKey().toString(),
        text: AttributedText(text: text, spans: spans),
        metadata: {
          'blockType': header3Attribution,
        },
      );
    case V1BlockType.BULLET_POINT:
      return ListItemNode.unordered(
        id: block.id != '' ? block.id : UniqueKey().toString(),
        text: AttributedText(text: text, spans: spans),
      );

    case V1BlockType.NUMBER_POINT:
      return ListItemNode.ordered(
        id: block.id != '' ? block.id : UniqueKey().toString(),
        text: AttributedText(text: text, spans: spans),
      );

    default:
      return CustomParagraphNode(
        id: block.id != '' ? block.id : UniqueKey().toString(),
        text: AttributedText(text: text, spans: spans),
      );
  }
}

MutableDocument createInitialDocument(
    {required V1Note note, bool readOnly = false}) {
  List<DocumentNode>? nodes = [];

  if (note.blocks != null) {
    note.blocks!.asMap().forEach((key, block) {
      if (readOnly) {
        nodes.add(getNodeFromBlockReadOnly(block));
      } else {
        nodes.add(getNodeFromBlock(block));
      }
    });
  }

  return MutableDocument(nodes: nodes);
}

Map<String, List<NotedEditorTextStyle>> getAttributionFromDoc(
    MutableDocument doc) {
  // List<NotedEditorTextStyle> textStyles = [];

  Map<String, List<NotedEditorTextStyle>> styleMap = {};

  for (var node in doc.nodes) {
    if (node is CustomParagraphNode) {
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

        if (styleMap.containsKey(node.id)) {
          styleMap[node.id] = styleMap[node.id]!
            ..add(NotedEditorTextStyle(
              node: node,
              start: startMarker.offset,
              end: correspondingEndMarker.offset,
              attribution: startMarker.attribution,
            ));

          correspondingEndMarker.offset;
        } else {
          styleMap[node.id] = [
            NotedEditorTextStyle(
              node: node,
              start: startMarker.offset,
              end: correspondingEndMarker.offset,
              attribution: startMarker.attribution,
            )
          ];
        }

        // textStyles.add(NotedEditorTextStyle(
        //   node: node,
        //   start: startMarker.offset,
        //   end: correspondingEndMarker.offset,
        //   attribution: startMarker.attribution,
        // ));
      }
    }
  }

  return styleMap;
}

// void printDocument(MutableDocument doc) {
//   print("printDocument");

//   Map<String, List<NotedEditorTextStyle>> textStyles =
//       getAttributionFromDoc(doc);

//   print("---------------------------------");
//   print("TEXT STYLES");

//   textStyles.forEach((key, value) {
//     print("  $key: $value");
//   });

//   print("---------------------------------");

//   for (var node in doc.nodes) {
//     // print(node);
//     // print(node.)
//     node.metadata.forEach((key, value) {
//       print("  $key: $value");
//     });

//     if (node is ParagraphNode) {
//       print(node.text.text);
//       print("--------------------");
//       // print(node.text.spans);

//       // for (var marker in spans.markers) {
//       //   print(marker);
//       // }

//       //

//       print("--------------------");
//     }
//     if (node is ImageNode) {
//       print(node.metadata);
//     }
//     if (node is ListItemNode) {
//       print(node.text.text);
//     }
//     if (node is HorizontalRuleNode) {
//       print(node.metadata);
//     }
//     if (node is TaskNode) {
//       print(node.text.text);
//     }
//   }
// }
