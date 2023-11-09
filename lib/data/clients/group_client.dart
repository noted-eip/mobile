import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/models/group/group.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/data/providers/utils/api_provider.dart';
import 'package:noted_mobile/data/services/api_execption.dart';
import 'package:noted_mobile/data/services/failure.dart';
import 'package:openapi/openapi.dart';
//TODO: revoir la gestion d'erreur

class GroupClient {
  ProviderRef<GroupClient> ref;
  GroupClient({required this.ref});

  Future<Group?> createGroup({
    required String groupName,
    required String groupDescription,
  }) async {
    final userNotifier = ref.read(userProvider);
    final apiP = ref.read(apiProvider);
    final body = V1CreateGroupRequest(
      (body) => body
        ..name = groupName
        ..description = groupDescription,
    );

    try {
      final Response<V1CreateGroupResponse> response =
          await apiP.groupsAPICreateGroup(
        body: body,
        headers: {"Authorization": "Bearer ${userNotifier.token}"},
      );

      if (response.statusCode != 200 || response.data == null) {
        if (kDebugMode) {
          print(
            "inside try : code = ${response.statusCode}, error = ${response.toString()}",
          );
        }
        throw Failure(message: response.toString());
      }

      final V1Group apiGroup = response.data!.group;

      return Group.fromApi(apiGroup);
    } on DioException catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
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
    final apiP = ref.read(apiProvider);
    final userNotifier = ref.read(userProvider);

    final body = GroupsAPIUpdateGroupRequest(
      (body) => body
        ..name = groupName
        ..description = groupDescription,
    );

    try {
      final Response<V1UpdateGroupResponse> response =
          await apiP.groupsAPIUpdateGroup(
        groupId: groupId,
        body: body,
        headers: {"Authorization": "Bearer ${userNotifier.token}"},
      );

      if (response.statusCode != 200 || response.data == null) {
        if (kDebugMode) {
          print(
            "inside try : code = ${response.statusCode}, error = ${response.toString()}",
          );
        }
        throw Failure(message: response.toString());
      }

      final V1Group apiGroup = response.data!.group;

      return Group.fromApi(apiGroup);
    } on DioException catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->updateGroup: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<void> deleteGroup({required String groupId}) async {
    final apiP = ref.read(apiProvider);
    final userNotifier = ref.read(userProvider);

    try {
      final response = await apiP.groupsAPIDeleteGroup(
        groupId: groupId,
        headers: {"Authorization": "Bearer ${userNotifier.token}"},
      );

      if (response.statusCode != 200) {
        if (kDebugMode) {
          print(
            "inside try : code = ${response.statusCode}, error = ${response.toString()}",
          );
        }
        throw Failure(message: response.toString());
      }

      return;
    } on DioException catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
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
    final apiP = ref.read(apiProvider);
    final userNotifier = ref.read(userProvider);

    // // TODO: implement optional parameters for offset and limit

    try {
      Response<V1ListGroupsResponse> response = await apiP.groupsAPIListGroups(
        accountId: accountId,
        headers: {"Authorization": "Bearer ${userNotifier.token}"},
      );

      if (response.statusCode != 200 || response.data == null) {
        if (kDebugMode) {
          print(
            "inside try : code = ${response.statusCode}, error = ${response.toString()}",
          );
        }
        throw Failure(message: response.toString());
      }

      final apiGroups = response.data!.groups;

      if (apiGroups == null) {
        return [];
      }

      return apiGroups.map((e) => Group.fromApi(e)).toList();
    } on DioException catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->listGroups: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<Group?> getGroup({required String groupId}) async {
    final apiP = ref.read(apiProvider);
    final userNotifier = ref.read(userProvider);

    try {
      final response = await apiP.groupsAPIGetGroup(
        groupId: groupId,
        headers: {"Authorization": "Bearer ${userNotifier.token}"},
      );

      if (response.statusCode != 200 || response.data == null) {
        if (kDebugMode) {
          print(
            "inside try : code = ${response.statusCode}, error = ${response.toString()}",
          );
        }
        throw Failure(message: response.toString());
      }

      return Group.fromApi(response.data!.group);
    } on DioException catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->getGroup: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<V1GroupMember?> getGroupMember(
      String groupId, String memberId, String token) async {
    final apiP = ref.read(apiProvider);
    final userNotifier = ref.read(userProvider);

    try {
      Response<V1GetMemberResponse> response = await apiP.groupsAPIGetMember(
        groupId: groupId,
        accountId: memberId,
        headers: {"Authorization": "Bearer ${userNotifier.token}"},
      );

      if (response.statusCode != 200 || response.data == null) {
        if (kDebugMode) {
          print(
            "inside try : code = ${response.statusCode}, error = ${response.toString()}",
          );
        }
        throw Failure(message: response.toString());
      }
      return response.data!.member;
    } on DioException catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->getGroupMember: $error\n");
      }
      // throw Failure(message: error);
    }
    return null;
  }

  Future<V1GroupMember?> updateGroupMember(
      String groupId, String memberId, bool isAdmin, String token) async {
    final apiP = ref.read(apiProvider);
    final userNotifier = ref.read(userProvider);

    V1GroupMember? member = await getGroupMember(groupId, memberId, token);

    if (member == null) {
      throw Failure(message: "Membre non trouvé");
    }

    V1GroupMember updatedMember = member.rebuild((p0) => p0..isAdmin = isAdmin);

    try {
      Response<V1UpdateMemberResponse> response =
          await apiP.groupsAPIUpdateMember(
        groupId: groupId,
        accountId: memberId,
        member: updatedMember,
        headers: {"Authorization": "Bearer ${userNotifier.token}"},
      );

      if (response.statusCode != 200 || response.data == null) {
        if (kDebugMode) {
          print(
            "inside try : code = ${response.statusCode}, error = ${response.toString()}",
          );
        }
        throw Failure(message: response.toString());
      }
      return response.data!.member;
    } on DioException catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->updateGroupMember: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<void> deleteGroupMember(
      String groupId, String memberId, String token) async {
    final userNotifier = ref.read(userProvider.notifier);
    try {
      final response = await ref.read(apiProvider).groupsAPIRemoveMember(
        groupId: groupId,
        accountId: memberId,
        headers: {"Authorization": "Bearer ${userNotifier.token}"},
      );

      if (response.statusCode != 200 || response.data == null) {
        if (kDebugMode) {
          print(
            "inside try : code = ${response.statusCode}, error = ${response.toString()}",
          );
        }
        throw Failure(message: response.toString());
      }
    } on DioException catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->deleteGroupMember: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<List<V1GroupActivity>?> getGroupsActivities({
    required String groupId,
  }) async {
    // ref.read(apiProvider).groupsAPIListActivities(groupId: groupId);
    final userNotifier = ref.read(userProvider.notifier);

    try {
      final response = await ref.read(apiProvider).groupsAPIListActivities(
        groupId: groupId,
        headers: {"Authorization": "Bearer ${userNotifier.token}"},
      );

      if (response.statusCode != 200 || response.data == null) {
        if (kDebugMode) {
          print(
            "inside try : code = ${response.statusCode}, error = ${response.toString()}",
          );
        }

        throw Failure(message: response.toString());
      }

      if (response.data == null) {
        return null;
      }

      return response.data!.activities.toList();
    } on DioException catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print(
            "Exception when calling DefaultApi->getGroupsActivities: $error\n");
      }
      throw Failure(message: error);
    }
  }
}
