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

  // factory Block.fromJson(Map<String, dynamic> json) {
  //   BlockType type = BlockType.unknown;

  //   switch (V1BlockType) {
  //     case V1BlockType.hEADING1:
  //       type = BlockType.heading1;
  //       break;
  //     case 'TYPE_HEADING_2':
  //       type = BlockType.heading2;
  //       break;
  //     case 'TYPE_HEADING_3':
  //       type = BlockType.heading3;
  //       break;
  //     case 'TYPE_PARAGRAPH':
  //       type = BlockType.paragraph;
  //       break;
  //     case 'TYPE_BULLET_POINT':
  //       type = BlockType.bulletPoint;
  //       break;
  //     case 'TYPE_NUMBER_POINT':
  //       type = BlockType.numberPoint;
  //       break;
  //     default:
  //       type = BlockType.paragraph;
  //       break;
  //   }

  //   String text = '';

  //   if (json['type'] == 'TYPE_HEADING_1' ||
  //       json['type'] == 'TYPE_HEADING_2' ||
  //       json['type'] == 'TYPE_HEADING_3') {
  //     text = json['heading'] ?? '';
  //   } else if (json['type'] == 'TYPE_BULLET_POINT') {
  //     text = json['bulletPoint'] ?? '';
  //   } else if (json['type'] == 'TYPE_NUMBER_POINT') {
  //     text = json['numberPoint'] ?? '';
  //   } else {
  //     text = json['paragraph'] ?? '';
  //   }

  //   return Block(
  //     id: json['id'] ?? '',
  //     type: type,
  //     text: json['type'] == 'TYPE_HEADING_1' ||
  //             json['type'] == 'TYPE_HEADING_2' ||
  //             json['type'] == 'TYPE_HEADING_3'
  //         ? json['heading'] ?? ''
  //         : json['paragraph'] ?? '',
  //   );
  // }

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
