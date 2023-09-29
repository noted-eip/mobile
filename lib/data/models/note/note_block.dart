import 'package:openapi/openapi.dart';

enum BlockType {
  unknown,
  heading1,
  heading2,
  heading3,
  paragraph,
  bulletPoint,
  numberPoint,
}

// TODO: Add new type of block like code, image, link, etc.

class Block {
  final String id;
  final BlockType type;
  final String text;

  Block({
    required this.id,
    required this.type,
    required this.text,
  });

  factory Block.fromApi(V1Block block) {
    BlockType type = BlockType.unknown;
    String text = '';

    switch (block.type) {
      case V1BlockType.hEADING1:
        type = BlockType.heading1;
        text = block.heading ?? '';
        break;
      case V1BlockType.hEADING2:
        type = BlockType.heading2;
        text = block.heading ?? '';
        break;
      case V1BlockType.hEADING3:
        type = BlockType.heading3;
        text = block.heading ?? '';
        break;
      case V1BlockType.PARAGRAPH:
        type = BlockType.paragraph;
        text = block.paragraph ?? '';
        break;
      case V1BlockType.BULLET_POINT:
        type = BlockType.bulletPoint;
        text = block.bulletPoint ?? '';
        break;
      case V1BlockType.NUMBER_POINT:
        type = BlockType.numberPoint;
        text = block.numberPoint ?? '';
        break;
      default:
        type = BlockType.unknown;
        text = '';
        break;
    }

    return Block(
      id: block.id,
      type: type,
      text: text,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'text': text,
    };
  }
}
