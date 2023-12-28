import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/models/group/group.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/data/providers/utils/api_provider.dart';
import 'package:noted_mobile/data/services/api_execption.dart';
import 'package:noted_mobile/data/services/failure.dart';
import 'package:openapi/openapi.dart';

class GroupClient {
  ProviderRef<GroupClient> ref;
  GroupClient({required this.ref});

  // Group CRUD

  Future<Group?> createGroup({
    required String groupName,
    required String groupDescription,
  }) async {
    final V1CreateGroupRequest body = V1CreateGroupRequest(
      (body) => body
        ..name = groupName
        ..description = groupDescription,
    );

    try {
      final Response<V1CreateGroupResponse> response =
          await ref.read(apiProvider).groupsAPICreateGroup(
        body: body,
        headers: {"Authorization": "Bearer ${ref.read(userProvider).token}"},
      );

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }

      return Group.fromApi(response.data!.group);
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->createGroup: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<Group?> updateGroup({
    required String groupName,
    required String groupDescription,
    required String groupId,
  }) async {
    final GroupsAPIUpdateGroupRequest body = GroupsAPIUpdateGroupRequest(
      (body) => body
        ..name = groupName
        ..description = groupDescription,
    );

    try {
      final Response<V1UpdateGroupResponse> response =
          await ref.read(apiProvider).groupsAPIUpdateGroup(
        groupId: groupId,
        body: body,
        headers: {"Authorization": "Bearer ${ref.read(userProvider).token}"},
      );

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }

      return Group.fromApi(response.data!.group);
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->updateGroup: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<void> deleteGroup({required String groupId}) async {
    try {
      final Response<Object> response =
          await ref.read(apiProvider).groupsAPIDeleteGroup(
        groupId: groupId,
        headers: {"Authorization": "Bearer ${ref.read(userProvider).token}"},
      );

      if (response.statusCode != 200) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->deleteGroup: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<List<Group>?> listGroups({
    required String accountId,
    int? offset,
    int? limit,
  }) async {
    try {
      //TODO: check if its functional
      Response<V1ListGroupsResponse> response =
          await ref.read(apiProvider).groupsAPIListGroups(
        accountId: accountId,
        offset: offset,
        limit: limit,
        headers: {"Authorization": "Bearer ${ref.read(userProvider).token}"},
      );

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }

      final BuiltList<V1Group>? apiGroups = response.data!.groups;

      if (apiGroups == null) {
        return [];
      }

      return apiGroups.map((e) => Group.fromApi(e)).toList();
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->listGroups: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<V1Group?> getGroup({required String groupId}) async {
    try {
      final Response<V1GetGroupResponse> response =
          await ref.read(apiProvider).groupsAPIGetGroup(
        groupId: groupId,
        headers: {"Authorization": "Bearer ${ref.read(userProvider).token}"},
      );

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }

      return response.data!.group;

      // return Group.fromApi(response.data!.group);
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->getGroup: $error\n");
      }
      throw Failure(message: error);
    }
  }

  // Group Members

  Future<V1GroupMember?> getGroupMember({
    required String groupId,
    required String memberId,
    required String token,
  }) async {
    try {
      Response<V1GetMemberResponse> response =
          await ref.read(apiProvider).groupsAPIGetMember(
        groupId: groupId,
        accountId: memberId,
        headers: {"Authorization": "Bearer ${ref.read(userProvider).token}"},
      );

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }
      return response.data!.member;
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->getGroupMember: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<V1GroupMember?> updateGroupMember({
    required String groupId,
    required String memberId,
    required bool isAdmin,
    required String token,
  }) async {
    V1GroupMember? member = await getGroupMember(
        groupId: groupId, memberId: memberId, token: token);

    if (member == null) {
      throw Failure(message: "Membre non trouvé"); // TODO: add traduction
    }

    V1GroupMember updatedMember = member.rebuild((p0) => p0..isAdmin = isAdmin);

    try {
      Response<V1UpdateMemberResponse> response =
          await ref.read(apiProvider).groupsAPIUpdateMember(
        groupId: groupId,
        accountId: memberId,
        member: updatedMember,
        headers: {"Authorization": "Bearer ${ref.read(userProvider).token}"},
      );

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }
      return response.data!.member;
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->updateGroupMember: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<void> deleteGroupMember({
    required String groupId,
    required String memberId,
    required String token,
  }) async {
    try {
      final Response<Object> response =
          await ref.read(apiProvider).groupsAPIRemoveMember(
        groupId: groupId,
        accountId: memberId,
        headers: {
          "Authorization": "Bearer ${ref.read(userProvider.notifier).token}"
        },
      );

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->deleteGroupMember: $error\n");
      }
      throw Failure(message: error);
    }
  }

  // Group Activities

  Future<List<V1GroupActivity>?> getGroupsActivities({
    required String groupId,
  }) async {
    try {
      final Response<V1ListActivitiesResponse> response =
          await ref.read(apiProvider).groupsAPIListActivities(
        groupId: groupId,
        headers: {
          "Authorization": "Bearer ${ref.read(userProvider.notifier).token}"
        },
      );

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }

      return response.data!.activities.toList();
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      if (kDebugMode) {
        print(
            "Exception when calling DefaultApi->getGroupsActivities: $error\n");
      }
      throw Failure(message: error);
    }
  }
}
