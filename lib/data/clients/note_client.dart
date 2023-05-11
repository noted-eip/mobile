import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/models/note/note.dart';
import 'package:noted_mobile/data/services/api_helper.dart';
import 'package:noted_mobile/data/services/dio_singleton.dart';
import 'package:noted_mobile/data/services/failure.dart';

class NoteClient {
  ProviderRef<NoteClient> ref;
  NoteClient({required this.ref});

  Future<Note?> getNote(String noteId, String groupId, String token) async {
    final api = singleton.get<APIHelper>();
    try {
      final response = await api.get(
        "/groups/$groupId/notes/$noteId",
        headers: {"Authorization": "Bearer $token"},
      );

      if (kDebugMode) {
        print("get note");
        print("response: ${response.data}");
        print("status code: ${response.statusCode}");
        print("error: ${response.error}");
      }

      if (response.statusCode == 200) {
        return Note.fromJson(response.data["note"]);
      } else {
        return null;
        // throw Failure(message: response.error.toString());
      }
    } on DioError catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      throw Failure(message: e.toString());
    }
  }

  Future<List<Note>?> listGroupNotes(String groupId, String token) async {
    final api = singleton.get<APIHelper>();

    try {
      final response = await api.get('/groups/$groupId/notes',
          headers: {"Authorization": "Bearer $token"});

      if (kDebugMode) {
        print("list notes");
        print("response: ${response.data}");
        print("status code: ${response.statusCode}");
        print("error: ${response.error}");
      }

      if (response.statusCode == 200) {
        if (response.data["notes"] == null) {
          return [];
        }
        print("notes: ");
        print(response.data["notes"]);

        return (response.data["notes"] as List)
            .map((e) => Note.fromJson(e))
            .toList();
      } else {
        return null;
        // throw Failure(message: response.error.toString());
      }
    } on DioError catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }

      throw Failure(message: e.toString());
    }
  }

  Future<List<Note>?> listNotes(String authorId, String token) async {
    final api = singleton.get<APIHelper>();

    try {
      final response = await api.get('/notes',
          queryParams: {"author_account_id": authorId},
          headers: {"Authorization": "Bearer $token"});

      if (kDebugMode) {
        print("list notes");
        print("response: ${response.data}");
        print("status code: ${response.statusCode}");
        print("error: ${response.error}");
      }

      if (response.statusCode == 200) {
        if (response.data["notes"] == null) {
          return [];
        }
        print("notes: ");
        print(response.data["notes"]);

        return (response.data["notes"] as List)
            .map((e) => Note.fromJson(e))
            .toList();
      } else {
        return null;
        // throw Failure(message: response.error.toString());
      }
    } on DioError catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }

      throw Failure(message: e.toString());
    }
  }
}
