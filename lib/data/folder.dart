import 'package:noted_mobile/data/note.dart';

class Folder {
  final String title;
  final int nbNotes;
  final List<Note> notes;
  final String id;
  final String author;
  final DateTime createdAt;
  final DateTime updatedAt;

  Folder({
    required this.title,
    required this.nbNotes,
    required this.notes,
    required this.id,
    required this.author,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      title: json['title'],
      nbNotes: json['nbNotes'],
      notes: json['notes'],
      id: json['id'],
      updatedAt: json['updatedAt'],
      createdAt: json['createdAt'],
      author: json['author'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'nbNotes': nbNotes,
      'notes': notes,
      'id': id,
      'author': author,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
