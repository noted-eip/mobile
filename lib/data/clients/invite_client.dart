import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/models/invite/invite.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/data/providers/utils/api_provider.dart';
import 'package:noted_mobile/data/services/api_helper.dart';
import 'package:noted_mobile/data/services/dio_singleton.dart';
import 'package:noted_mobile/data/services/failure.dart';
import 'package:openapi/openapi.dart';

class InviteClient {
  ProviderRef<InviteClient> ref;

  InviteClient({required this.ref});

  Future<Invite?> sendInvite(
      {required String groupId, required String recipientId}) async {
    final GroupsAPISendInviteRequest body = GroupsAPISendInviteRequest(
      (body) => body..recipientAccountId = recipientId,
    );

    final userNotifier = ref.read(userProvider);

    try {
      final response = await ref.read(apiProvider).groupsAPISendInvite(
          groupId: groupId,
          body: body,
          headers: {"Authorization": "Bearer ${userNotifier.token}"});

      if (response.statusCode != 200 || response.data == null) {
        return null;
      }

      return Invite.fromApi(response.data!.invite);
    } on DioError catch (e) {
      if (kDebugMode) {
        print(e.response!.data['error'].toString());
      }
      throw Failure(message: e.toString());
    }

    // final api = singleton.get<APIHelper>();

    // try {
    //   final response = await api.post(
    //     '/invites',
    //     headers: {"Authorization": "Bearer $token"},
    //     body: {"group_id": groupId, "recipient_account_id": recipientId},
    //   );
    //   if (response.statusCode == 200) {
    //     return Invite.fromJson(response.data["invite"]);
    //   } else {
    //     throw Failure(message: response.data['error'].toString());
    //   }
    // } on DioError catch (e) {
    //   if (kDebugMode) {
    //     print(e.response!.data['error'].toString());
    //   }
    //   throw Failure(message: e.toString());
    // }
  }

  Future<Invite?> getInvite(String inviteId, String token) async {
    final api = singleton.get<APIHelper>();

    try {
      final response = await api.get(
        '/invites/$inviteId',
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        return Invite.fromJson(response.data["invite"]);
      } else {
        throw Failure(message: response.data['error'].toString());
      }
    } on DioError catch (e) {
      if (kDebugMode) {
        print(e.response!.data['error'].toString());
      }
      throw Failure(message: e.toString());
    }
  }

  Future<List<Invite>?> listInvites(
    String token, {
    String? senderId,
    String? recipientId,
    String? groupId,
    int? offset,
    int? limit,
  }) async {
    final userNotifier = ref.read(userProvider);

    try {
      final Response<V1ListInvitesResponse> response =
          await ref.read(apiProvider).groupsAPIListInvites(
        senderAccountId: senderId,
        recipientAccountId: recipientId,
        groupId: groupId,
        limit: limit,
        offset: offset,
        headers: {"Authorization": "Bearer ${userNotifier.token}"},
      );
      if (response.statusCode != 200 || response.data == null) {
        return null;
      }

      return response.data!.invites!.map((e) => Invite.fromApi(e)).toList();
    } on DioError catch (e) {
      throw Failure(message: e.toString());
    }
  }

  Future<void> acceptInvite({
    required String inviteId,
    required String groupId,
  }) async {
    final userNotifier = ref.read(userProvider);

    try {
      Response<V1AcceptInviteResponse> response =
          await ref.read(apiProvider).groupsAPIAcceptInvite(
        inviteId: inviteId,
        groupId: groupId,
        headers: {"Authorization": "Bearer ${userNotifier.token}"},
      );

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }
    } on DioError catch (e) {
      throw Failure(message: e.toString());
    }
  }

  Future<void> denyInvite({
    required String inviteId,
    required String groupId,
  }) async {
    final userNotifier = ref.read(userProvider);

    try {
      final response = await ref.read(apiProvider).groupsAPIDenyInvite(
        inviteId: inviteId,
        groupId: groupId,
        headers: {"Authorization": "Bearer ${userNotifier.token}"},
      );

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }
    } on DioError catch (e) {
      throw Failure(message: e.toString());
    }
  }

  Future<void> revokeInvite({
    required String inviteId,
    required String groupId,
  }) async {
    final userNotifier = ref.read(userProvider);

    try {
      final response = await ref.read(apiProvider).groupsAPIRevokeInvite(
        inviteId: inviteId,
        groupId: groupId,
        headers: {"Authorization": "Bearer ${userNotifier.token}"},
      );

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }
    } on DioError catch (e) {
      throw Failure(message: e.toString());
    }
  }
}
