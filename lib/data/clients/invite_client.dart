import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/models/invite/invite.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/data/providers/utils/api_provider.dart';
import 'package:noted_mobile/data/services/api_execption.dart';
import 'package:noted_mobile/data/services/api_helper.dart';
import 'package:noted_mobile/data/services/dio_singleton.dart';
import 'package:noted_mobile/data/services/failure.dart';
import 'package:openapi/openapi.dart';

class InviteClient {
  ProviderRef<InviteClient> ref;

  InviteClient({required this.ref});

  // Invite CRUD

  Future<Invite?> sendInvite({
    required String groupId,
    required String recipientId,
  }) async {
    final GroupsAPISendInviteRequest body = GroupsAPISendInviteRequest(
      (body) => body..recipientAccountId = recipientId,
    );

    try {
      final Response<V1SendInviteResponse> response = await ref
          .read(apiProvider)
          .groupsAPISendInvite(groupId: groupId, body: body, headers: {
        "Authorization": "Bearer ${ref.read(userProvider).token}"
      });

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }

      return Invite.fromApi(response.data!.invite);
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->sendInvite: $error\n");
      }
      throw Failure(message: error);
    }
  }

// TODO: add required params
  Future<Invite?> getInvite(String inviteId, String token) async {
    // TODO: implement getInvite
    final api = singleton.get<APIHelper>();

    try {
      final response = await api.get(
        '/invites/$inviteId',
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode != 200) {
        throw Failure(message: response.error ?? 'Error');
      }
      return Invite.fromJson(response.data["invite"]);
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->getInvite: $error\n");
      }
      throw Failure(message: error);
    }
  }

// TODO: add required params
  Future<List<Invite>?> listInvites(
    String token, {
    String? senderId,
    String? recipientId,
    String? groupId,
    int? offset,
    int? limit,
  }) async {
    try {
      final Response<V1ListInvitesResponse> response =
          await ref.read(apiProvider).groupsAPIListInvites(
        senderAccountId: senderId,
        recipientAccountId: recipientId,
        groupId: groupId,
        limit: limit,
        offset: offset,
        headers: {"Authorization": "Bearer ${ref.read(userProvider).token}"},
      );
      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }

      return response.data!.invites!.map((e) => Invite.fromApi(e)).toList();
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->listInvites: $error\n");
      }
      throw Failure(message: error);
    }
  }

  // Invite Actions

  Future<void> acceptInvite({
    required String inviteId,
    required String groupId,
  }) async {
    try {
      Response<V1AcceptInviteResponse> response =
          await ref.read(apiProvider).groupsAPIAcceptInvite(
        inviteId: inviteId,
        groupId: groupId,
        headers: {"Authorization": "Bearer ${ref.read(userProvider).token}"},
      );

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->acceptInvite: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<void> denyInvite({
    required String inviteId,
    required String groupId,
  }) async {
    try {
      final response = await ref.read(apiProvider).groupsAPIDenyInvite(
        inviteId: inviteId,
        groupId: groupId,
        headers: {"Authorization": "Bearer ${ref.read(userProvider).token}"},
      );

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->denyInvite: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<void> revokeInvite({
    required String inviteId,
    required String groupId,
  }) async {
    try {
      final response = await ref.read(apiProvider).groupsAPIRevokeInvite(
        inviteId: inviteId,
        groupId: groupId,
        headers: {"Authorization": "Bearer ${ref.read(userProvider).token}"},
      );

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->revokeInvite: $error\n");
      }
      throw Failure(message: error);
    }
  }
}
