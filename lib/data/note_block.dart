enum BlockType {
  unknown,
  heading1,
  heading2,
  heading3,
  paragraph,
}

class Block {
  final String id;
  final BlockType type;
  final String text;

  Block({
    required this.id,
    required this.type,
    required this.text,
  });

  factory Block.fromJson(Map<String, dynamic> json) {
    return Block(
      id: json['id'],
      type: json['type'] == 'TYPE_HEADING_1'
          ? BlockType.heading1
          : json['type'] == 'TYPE_HEADING_2'
              ? BlockType.heading2
              : json['type'] == 'TYPE_HEADING_3'
                  ? BlockType.heading3
                  : json['type'] == 'TYPE_PARAGRAPH'
                      ? BlockType.paragraph
                      : BlockType.unknown,
      text: json['type'] == 'TYPE_HEADING_1' ||
              json['type'] == 'TYPE_HEADING_2' ||
              json['type'] == 'TYPE_HEADING_3'
          ? json['heading']
          : json['paragraph'],
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
