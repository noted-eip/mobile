import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/data/providers/utils/api_provider.dart';
import 'package:noted_mobile/data/services/api_execption.dart';
import 'package:noted_mobile/data/services/failure.dart';
import 'package:openapi/openapi.dart';

class NoteClient {
  ProviderRef<NoteClient> ref;
  NoteClient({required this.ref});

  // Note CRUD

  Future<V1Note?> createNote({
    required String groupId,
    required String title,
    required String lang,
  }) async {
    try {
      final Response<V1CreateNoteResponse> response = await ref
          .read(apiProvider)
          .notesAPICreateNote(
              groupId: groupId,
              body: NotesAPICreateNoteRequest(
                ((body) => body
                  ..title = title
                  ..lang = lang),
              ),
              headers: {
            "Authorization": "Bearer ${ref.read(userProvider).token}"
          });

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }

      return response.data!.note;
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->createNote: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<void> deleteNote({
    required String groupId,
    required String noteId,
  }) async {
    try {
      final Response<Object> response = await ref
          .read(apiProvider)
          .notesAPIDeleteNote(groupId: groupId, noteId: noteId, headers: {
        "Authorization": "Bearer ${ref.read(userProvider).token}"
      });

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->deleteNote: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<V1Note?> updateNote({
    required String groupId,
    required String noteId,
    required V1Note note,
  }) async {
    try {
      final Response<V1UpdateNoteResponse> response =
          await ref.read(apiProvider).notesAPIUpdateNote(
        groupId: groupId,
        noteId: noteId,
        note: note,
        headers: {
          "Authorization": "Bearer ${ref.read(userProvider).token}",
        },
      );

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }

      return response.data!.note;
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->updateNote: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<V1Note?> getNote({
    required String noteId,
    required String groupId,
    required String token,
  }) async {
    try {
      final Response<V1GetNoteResponse> response = await ref
          .read(apiProvider)
          .notesAPIGetNote(groupId: groupId, noteId: noteId, headers: {
        "Authorization": "Bearer ${ref.read(userProvider).token}"
      });

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }

      return response.data!.note;
    } on DioException catch (e) {
      // TODO: check if this is the right way to handle this
      return null;
      // String error = NotedException.fromDioException(e).toString();
      // if (kDebugMode) {
      //   print("Exception when calling DefaultApi->getNote: $error\n");
      // }
      // throw Failure(message: error);
    }
  }

  Future<List<V1Note>?> listGroupNotes({
    required String groupId,
    required String token,
  }) async {
    try {
      final Response<V1ListNotesResponse> response = await ref
          .read(apiProvider)
          .notesAPIListNotes2(groupId: groupId, headers: {
        "Authorization": "Bearer ${ref.read(userProvider).token}"
      });

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }

      return response.data!.notes!.toList();
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->listGroupNotes: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<List<V1Note>?> listNotes({
    required String authorId,
    required String token,
  }) async {
    try {
      final Response<V1ListNotesResponse> response = await ref
          .read(apiProvider)
          .notesAPIListNotes(authorAccountId: authorId, headers: {
        "Authorization": "Bearer ${ref.read(userProvider).token}"
      });

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }

      return response.data!.notes!.toList();
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->listNotes: $error\n");
      }
      throw Failure(message: error);
    }
  }

  // Summary

  Future<String?> summaryGenerator({
    required String noteId,
    required String groupId,
  }) async {
    try {
      final Response<V1GenerateSummaryResponse> response = await ref
          .read(apiProvider)
          .notesAPIGenerateSummary(groupId: groupId, noteId: noteId, headers: {
        "Authorization": "Bearer ${ref.read(userProvider).token}"
      });

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }

      return response.data!.summary;
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->summaryGenerator: $error\n");
      }
      throw Failure(message: error);
    }
  }

  // Recommendation

  Future<List<V1Widget>?> recommendationGenerator({
    required String groupId,
    required String noteId,
  }) async {
    try {
      final Response<V1GenerateWidgetsResponse> response = await ref
          .read(apiProvider)
          .recommendationsAPIGenerateWidgets(
              groupId: groupId,
              noteId: noteId,
              headers: {
            "Authorization": "Bearer ${ref.read(userProvider).token}"
          });

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }

      return response.data!.widgets.toList();
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      if (kDebugMode) {
        print(
            "Exception when calling DefaultApi->recommendationGenerator: $error\n");
      }
      throw Failure(message: error);
    }
  }

  // Quizz

  Future<List<V1Quiz>?> listNoteQuizzes({
    required String groupId,
    required String noteId,
  }) async {
    try {
      final Response<V1ListQuizsResponse> response = await ref
          .read(apiProvider)
          .notesAPIListQuizs(groupId: groupId, noteId: noteId, headers: {
        "Authorization": "Bearer ${ref.read(userProvider).token}"
      });

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }

      return response.data!.quizs!.toList();
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->listNoteQuizzes: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<V1Quiz?> quizzGenerator({
    required String groupId,
    required String noteId,
  }) async {
    try {
      final Response<V1GenerateQuizResponse> response = await ref
          .read(apiProvider)
          .notesAPIGenerateQuiz(groupId: groupId, noteId: noteId, headers: {
        "Authorization": "Bearer ${ref.read(userProvider).token}"
      });

      if (response.statusCode != 200 ||
          response.data == null ||
          response.data!.quiz == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }

      return response.data!.quiz!;
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->quizzGenerator: $error\n");
      }
      throw Failure(message: error);
    }
  }

  // Block Comments

  Future<void> removeComment({
    required String groupId,
    required String noteId,
    required String blockId,
    required String commentId,
  }) async {
    try {
      final Response<Object> response = await ref
          .read(apiProvider)
          .notesAPIDeleteBlockComment(
              groupId: groupId,
              noteId: noteId,
              blockId: blockId,
              commentId: commentId,
              headers: {
            "Authorization": "Bearer ${ref.read(userProvider).token}"
          });

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->removeComment: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<BlockComment?> addComment({
    required String groupId,
    required String noteId,
    required String blockId,
    required String comment,
    required String authorId,
  }) async {
    var builder = BlockCommentBuilder();

    builder.authorId = authorId;
    builder.content = comment;

    NotesAPICreateBlockCommentRequest body =
        NotesAPICreateBlockCommentRequest((b) => b..comment = builder);

    try {
      final Response<V1CreateBlockCommentResponse> response = await ref
          .read(apiProvider)
          .notesAPICreateBlockComment(
              groupId: groupId,
              noteId: noteId,
              blockId: blockId,
              body: body,
              headers: {
            "Authorization": "Bearer ${ref.read(userProvider).token}"
          });

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }

      return response.data?.comment;
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->addComment: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<List<BlockComment>?> listComments({
    required String groupId,
    required String noteId,
    required String blockId,
  }) async {
    try {
      final Response<V1ListBlockCommentsResponse> response = await ref
          .read(apiProvider)
          .notesAPIListBlockComments(
              groupId: groupId,
              noteId: noteId,
              blockId: blockId,
              headers: {
            "Authorization": "Bearer ${ref.read(userProvider).token}"
          });

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }

      return response.data!.comments!.toList();
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->listComments: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<List<V1Block>?> listBlockWithComments({
    required String groupId,
    required String noteId,
  }) async {
    try {
      List<V1Block> block = [];

      try {
        final note = await getNote(
          noteId: noteId,
          groupId: groupId,
          token: ref.read(userProvider).token,
        );

        if (note == null) {
          throw Failure(message: 'Note not found');
        }

        block = note.blocks!.toList();
      } catch (e) {
        throw Failure(message: e.toString());
      }

      final List<V1Block> blockWithComments = [];

      for (var i = 0; i < block.length; i++) {
        final comments = await listComments(
          groupId: groupId,
          noteId: noteId,
          blockId: block[i].id,
        );

        if (comments != null && comments.isNotEmpty) {
          blockWithComments.add(block[i]);
        }
      }

      return blockWithComments;
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      if (kDebugMode) {
        print(
            "Exception when calling DefaultApi->listBlockWithComments: $error\n");
      }
      throw Failure(message: error);
    }
  }
}
