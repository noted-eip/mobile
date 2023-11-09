// ignore_for_file: avoid_print

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/data/providers/utils/api_provider.dart';
import 'package:noted_mobile/data/services/api_execption.dart';
import 'package:noted_mobile/data/services/failure.dart';
import 'package:openapi/openapi.dart';

//TODO: revoir la gestion d'erreur

class NoteClient {
  ProviderRef<NoteClient> ref;
  NoteClient({required this.ref});

  Future<V1Note?> createNote({
    required String groupId,
    required String title,
  }) async {
    final userNotifier = ref.read(userProvider);

    try {
      final response = await ref.read(apiProvider).notesAPICreateNote(
          groupId: groupId,
          body: NotesAPICreateNoteRequest(
            ((body) => body..title = title),
          ),

          // V1CreateNoteRequest(
          //   title: title,
          //   content: content,
          // ),
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

      return response.data!.note;
    } on DioException catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->createNote: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<V1Note?> updateNote({
    required String groupId,
    required String noteId,
    required V1Note note,
  }) async {
    final userNotifier = ref.read(userProvider);

    try {
      final response = await ref.read(apiProvider).notesAPIUpdateNote(
        groupId: groupId,
        noteId: noteId,
        note: note,
        headers: {
          "Authorization": "Bearer ${userNotifier.token}",
        },
      );

      if (response.statusCode != 200 || response.data == null) {
        if (kDebugMode) {
          print(
            "inside try : code = ${response.statusCode}, error = ${response.toString()}",
          );
        }
        return null;

        // throw Failure(message: response.toString());
      }

      return response.data!.note;
    } on DioException catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print(
            "Exception when calling DefaultApi->accountsAPIGetAccount: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<V1Note?> getNote(String noteId, String groupId, String token) async {
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

      return response.data!.note;
    } on DioException catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->getNote: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<List<V1Note>?> listGroupNotes(String groupId, String token) async {
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
      return response.data!.notes!.toList();
    } on DioException catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->listGroupNotes: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<List<V1Note>?> listNotes(String authorId, String token) async {
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
      return response.data!.notes!.toList();
    } on DioException catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->listNotes: $error\n");
      }
      // throw Failure(message: error);
    }
    return null;
  }

  Future<String?> summaryGenerator({
    required String noteId,
    required String groupId,
  }) async {
    final userNotifier = ref.read(userProvider);
    try {
      final response = await ref.read(apiProvider).notesAPIGenerateSummary(
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

      print("summary : ${response.data!.summary}");

      return response.data!.summary;
    } on DioException catch (e) {
      print("summary $e");

      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->summaryGenerator: $error\n");
      }
      // throw Failure(message: error);
    }
    return null;
  }

  Future<List<V1Widget>?> recommendationGenerator({
    required String groupId,
    required String noteId,
  }) async {
    final userNotifier = ref.read(userProvider);
    try {
      final response = await ref
          .read(apiProvider)
          .recommendationsAPIGenerateWidgets(
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

      return response.data!.widgets.toList();
    } on DioException catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print(
            "Exception when calling DefaultApi->recommendationGenerator : $error\n");
      }
      // throw Failure(message: error);
    }
    return null;
  }

  Future<V1Quiz?> quizzGenerator({
    required String groupId,
    required String noteId,
  }) async {
    final userNotifier = ref.read(userProvider);
    try {
      final response = await ref.read(apiProvider).notesAPIGenerateQuiz(
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
      V1Quiz quizz = response.data!.quiz!;

      print("quizz : $quizz");

      print("Taille du quizz : ${quizz.questions!.length}");

      for (var question in quizz.questions!) {
        print("question : ${question.question}");
        for (var element in question.answers!) {
          print("possible reponse : $element");
        }
        for (var element in question.solutions!) {
          print("solution : $element");
        }
      }

      return quizz;
    } on DioException catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print("error $error\n");
      }
      // throw Failure(message: error);
    }
    return null;
  }
}
