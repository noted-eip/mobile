// ignore_for_file: avoid_print

import 'dart:async';

import 'package:built_collection/built_collection.dart';
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
      final response = await Dio(
        BaseOptions(
          baseUrl: kBaseUrl,
          receiveTimeout: const Duration(seconds: 20),
        ),
      ).post(
        "https://noted-rojasdiego.koyeb.app/groups/$groupId/notes",
        data: {"group_id": groupId, "title": title},
        options: Options(
          headers: {"Authorization": "Bearer ${userNotifier.token}"},
        ),
      );

      if (response.statusCode != 200 || response.data == null) {
        if (kDebugMode) {
          print(
            "inside try : code = ${response.statusCode}, error = ${response.toString()}",
          );
        }
        return null;
      }

      String jsonNoteId = response.data!["note"]["id"];
      String jsonGroupId = response.data!["note"]["group_id"];
      String jsonAuthorAccountId = response.data!["note"]["author_account_id"];
      String jsonTitle = response.data!["note"]["title"];
      List<Map<String, dynamic>> jsonBlocks =
          List.from(response.data!["note"]["blocks"]);
      int jsonCreatedAtSeconds =
          response.data!["note"]["created_at"]["seconds"];
      int jsonCreatedAtNanos = response.data!["note"]["created_at"]["nanos"];
      String jsonLang = response.data!["note"]["lang"];

      BuiltList<V1Block>? blocksList = BuiltList<V1Block>(
        jsonBlocks.map((jsonBlock) {
          // Conversion de chaque élément JSON en V1Block
          V1BlockBuilder blockBuilder = V1BlockBuilder();

          V1BlockType? blockType =
              V1BlockType.values.elementAt(jsonBlock["type"]);

          blockBuilder.id = jsonBlock["id"];
          blockBuilder.type = blockType;
          return blockBuilder.build();
        }),
      );

      // Conversion de la réponse JSON en V1Note
      // TODO: vérifier si le bloc est bien converti

      V1Note note = V1Note(((body) => body
        ..lang = jsonLang
        ..groupId = jsonGroupId
        ..title = jsonTitle
        ..blocks = blocksList.toBuilder()
        ..createdAt = DateTime.fromMillisecondsSinceEpoch(
          jsonCreatedAtSeconds * 1000 + jsonCreatedAtNanos ~/ 1000000,
          isUtc: true,
        )
        ..id = jsonNoteId
        ..authorAccountId = jsonAuthorAccountId));

      return note;
    } on DioException catch (e) {
      // String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->createNote: $e\n");
      }
      throw Failure(message: e.toString());
    }
  }

  // Future<V1Note?> createNote({
  //   required String groupId,
  //   required String title,
  // }) async {
  //   final userNotifier = ref.read(userProvider);

  //   try {
  //     final Response<V1CreateNoteResponse> response =
  //         await ref.read(apiProvider).notesAPICreateNote(
  //             groupId: groupId,
  //             body: NotesAPICreateNoteRequest(
  //               ((body) => body
  //                 ..title = title
  //                 ..lang = "fr"),
  //             ),
  //             headers: {"Authorization": "Bearer ${userNotifier.token}"});

  //     if (response.statusCode != 200 || response.data == null) {
  //       if (kDebugMode) {
  //         print(
  //           "inside try : code = ${response.statusCode}, error = ${response.toString()}",
  //         );
  //       }
  //       return null;

  //       // throw Failure(message: response.toString());
  //     }

  //     return response.data!.note;
  //   } on DioException catch (e) {
  //     // String error = DioExceptions.fromDioError(e).toString();
  //     if (kDebugMode) {
  //       print("Exception when calling DefaultApi->createNote: $e\n");
  //     }
  //     throw Failure(message: e.toString());
  //   }
  // }

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
        print(e);
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
      print("notes : ${response.data!.notes!.toList()}");
      return response.data!.notes!.toList();
    } on DioException catch (e) {
      print("error: $e\n");
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
