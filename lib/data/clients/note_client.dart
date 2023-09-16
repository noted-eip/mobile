import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/models/note/note.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/data/providers/utils/api_provider.dart';
import 'package:noted_mobile/data/services/api_execption.dart';
import 'package:noted_mobile/data/services/failure.dart';
import 'package:openapi/openapi.dart';

class NoteClient {
  ProviderRef<NoteClient> ref;
  NoteClient({required this.ref});

  Future<Note?> getNote(String noteId, String groupId, String token) async {
    final userNotifier = ref.read(userProvider);

    try {
      final response = await ref.read(apiProvider).notesAPIGetNote(
          groupId: groupId,
          noteId: noteId,
          headers: {"Authorization": "Bearer ${userNotifier.token}"});

      if (response.statusCode != 200 || response.data == null) {
        if (kDebugMode) {
          print(
            "inside try : code = ${response.statusCode}, error = ${response.toString()}",
          );
        }
        return null;

        // throw Failure(message: response.toString());
      }

      return Note.fromApi(response.data!.note);
    } on DioException catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print(
            "Exception when calling DefaultApi->accountsAPIGetAccount: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<List<Note>?> listGroupNotes(String groupId, String token) async {
    final apiP = ref.read(apiProvider);
    final userNotifier = ref.read(userProvider);

    try {
      final Response<V1ListNotesResponse> response = await apiP
          .notesAPIListNotes2(
              groupId: groupId,
              headers: {"Authorization": "Bearer ${userNotifier.token}"});

      if (response.statusCode != 200 || response.data == null) {
        if (kDebugMode) {
          print(
            "inside try : code = ${response.statusCode}, error = ${response.toString()}",
          );
        }
        return null;

        // throw Failure(message: response.toString());
      }
      return response.data!.notes!.map((e) => Note.fromApi(e)).toList();
    } on DioException catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print(
            "Exception when calling DefaultApi->accountsAPIGetAccount: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<List<Note>?> listNotes(String authorId, String token) async {
    final userNotifier = ref.read(userProvider);

    try {
      final response = await ref.read(apiProvider).notesAPIListNotes(
          authorAccountId: authorId,
          headers: {"Authorization": "Bearer ${userNotifier.token}"});

      if (response.statusCode != 200 || response.data == null) {
        if (kDebugMode) {
          print(
            "inside try : code = ${response.statusCode}, error = ${response.toString()}",
          );
        }
        return null;

        // throw Failure(message: response.toString());
      }
      return response.data!.notes!.map((e) => Note.fromApi(e)).toList();
    } on DioException catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print(
            "Exception when calling DefaultApi->accountsAPIGetAccount: $error\n");
      }
      // throw Failure(message: error);
    }
    return null;
  }
}
