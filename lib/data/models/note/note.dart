import 'package:noted_mobile/data/models/note/note_block.dart';
import 'package:openapi/openapi.dart';

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

  factory Note.fromApi(V1Note note) {
    return Note(
      id: note.id,
      authorId: note.authorAccountId,
      title: note.title,
      groupId: note.groupId,
      createdAt: note.createdAt,
      modifiedAt: note.modifiedAt,
      analysedAt: note.analyzedAt,
      blocks: note.blocks == null
          ? null
          : note.blocks!.map((e) => Block.fromApi(e)).toList(),
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
