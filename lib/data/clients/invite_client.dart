import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/models/invite/invite.dart';
import 'package:noted_mobile/data/services/api_helper.dart';
import 'package:noted_mobile/data/services/dio_singleton.dart';
import 'package:noted_mobile/data/services/failure.dart';

class InviteClient {
  ProviderRef<InviteClient> ref;

  InviteClient({required this.ref});

  Future<Invite?> sendInvite(
      String groupId, String recipientId, String token) async {
    final api = singleton.get<APIHelper>();

    try {
      final response = await api.post(
        '/invites',
        headers: {"Authorization": "Bearer $token"},
        body: {"group_id": groupId, "recipient_account_id": recipientId},
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
    final api = singleton.get<APIHelper>();

    Map<String, dynamic> queryParams = {};

    queryParams.addEntries([
      if (offset != null) MapEntry("offset", offset),
      if (limit != null) MapEntry("limit", limit),
      if (senderId != null) MapEntry("sender_account_id", senderId),
      if (recipientId != null) MapEntry("recipient_account_id", recipientId),
      if (groupId != null) MapEntry("group_id", groupId),
    ]);

    try {
      final response = await api.get(
        "/invites",
        queryParams: queryParams,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        if (response.data["invites"] == null) {
          return [];
        }

        return (response.data["invites"] as List)
            .map((e) => Invite.fromJson(e))
            .toList();
      } else {
        return [];
      }
    } on DioError catch (e) {
      if (kDebugMode) {
        print(e.response!.data['error'].toString());
      }
      throw Failure(message: e.toString());
    }
  }

  Future<void> acceptInvite(String inviteId, String token) async {
    final api = singleton.get<APIHelper>();

    try {
      final response = await api.post(
        '/invites/$inviteId/accept',
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        return;
      } else {
        throw Failure(message: response.error.toString());
      }
    } on DioError catch (e) {
      if (kDebugMode) {
        print(e.response!.data['error'].toString());
      }
      throw Failure(message: e.toString());
    }
  }

  Future<void> denyInvite(String inviteId, String token) async {
    final api = singleton.get<APIHelper>();

    try {
      final response = await api.post(
        '/invites/$inviteId/deny',
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        return;
      } else {
        throw Failure(message: response.error.toString());
      }
    } on DioError catch (e) {
      if (kDebugMode) {
        print(e.response!.data['error'].toString());
      }
      throw Failure(message: e.toString());
    }
  }

  Future<void> revokeInvite(String inviteId, String token) async {
    final api = singleton.get<APIHelper>();

    try {
      final response = await api.post(
        '/invites/$inviteId/deny',
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        return;
      } else {
        throw Failure(message: response.error.toString());
      }
    } on DioError catch (e) {
      if (kDebugMode) {
        print(e.response!.data['error'].toString());
      }
      throw Failure(message: e.toString());
    }
  }
}
