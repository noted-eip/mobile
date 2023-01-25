import 'package:noted_mobile/data/note_block.dart';

class Note {
  String id;
  String authorId;
  String title;
  List<Block>? blocks;

  Note({
    required this.id,
    required this.authorId,
    required this.title,
    required this.blocks,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] ?? '',
      authorId: json['author_id'] ?? '',
      title: json['title'] ?? '',
      blocks: json['blocks'] == null
          ? null
          : List<Block>.from(
              json['blocks'].map(
                (block) => Block.fromJson(block),
              ),
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author_id': authorId,
      'title': title,
      'blocks': blocks == null
          ? null
          : blocks!.map((block) => block.toJson()).toList(),
    };
  }
}
