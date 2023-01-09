// ignore_for_file: non_constant_identifier_names

import 'package:noted_mobile/data/note.dart';

class NewGroup {
  final String id;
  final String name;
  final String description;
  final String created_at;
  final List<GroupMember>? members;

  NewGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.created_at,
    this.members,
  });

  factory NewGroup.fromJson(Map<String, dynamic> json) {
    return NewGroup(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      created_at: json['created_at'].toString(),
    );
  }
}

class GroupMember {
  final String account_id;
  final String role;
  final String created_at;
  String? username;
  String? email;

  GroupMember(
    this.username,
    this.email, {
    required this.account_id,
    required this.role,
    required this.created_at,
  });

  void setUserName(String username) {
    this.username = username;
  }

  void setEmail(String email) {
    this.email = email;
  }

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      "",
      "",
      account_id: json['account_id'],
      role: json['role'],
      created_at: json['created_at'].toString(),
    );
  }
}

class Group {
  final String title;
  final int nbNotes;
  final List<Note> notes;
  final String id;
  final String author;
  final DateTime createdAt;
  final DateTime updatedAt;

  Group({
    required this.title,
    required this.nbNotes,
    required this.notes,
    required this.id,
    required this.author,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
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
