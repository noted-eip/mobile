import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:noted_mobile/data/note.dart';
import 'package:noted_mobile/data/services/api_helper.dart';
import 'package:noted_mobile/data/services/dio_singleton.dart';

class NoteClient {
  Future<Note?> getNote(String noteId, String token) async {
    final api = singleton.get<APIHelper>();
    try {
      final response = await api.get(
        "/notes/$noteId",
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

  Future<List<Note>?> listNotes(String authorId, String token) async {
    final api = singleton.get<APIHelper>();

    try {
      final response = await api.get('/notes',
          queryParams: {"author_id": authorId},
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
