import 'package:noted_mobile/data/models/note/note_block.dart';

class Note {
  String id;
  String authorId;
  String groupId;
  String title;
  List<Block>? blocks;
  DateTime? createdAt;
  DateTime? modifiedAt;
  DateTime? analysedAt;

  Note({
    required this.id,
    required this.authorId,
    required this.title,
    required this.blocks,
    this.analysedAt,
    this.createdAt,
    required this.groupId,
    this.modifiedAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] ?? '',
      authorId: json['authorAccountId'] ?? '',
      title: json['title'] ?? '',
      groupId: json['groupId'] ?? '',
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      modifiedAt: json['modifiedAt'] != null
          ? DateTime.parse(json['modifiedAt'])
          : null,
      analysedAt: json['analysedAt'] != null
          ? DateTime.parse(json['analysedAt'])
          : null,
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
