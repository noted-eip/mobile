import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/models/account/account.dart';
import 'package:noted_mobile/data/models/group/group.dart';
import 'package:noted_mobile/data/models/group/group_data.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/data/providers/utils/api_provider.dart';
import 'package:noted_mobile/data/services/api_execption.dart';
import 'package:noted_mobile/data/services/api_helper.dart';
import 'package:noted_mobile/data/services/dio_singleton.dart';
import 'package:noted_mobile/data/services/failure.dart';
import 'package:openapi/openapi.dart';

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
    } on DioError catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print(
            "Exception when calling DefaultApi->groupsAPICreateGroup: $error\n");
      }
      throw Failure(message: error);
    }

    // final api = singleton.get<APIHelper>();

    // try {
    //   final response = await api.post('/groups', headers: {
    //     "Authorization": "Bearer ${userNotifier.token}"
    //   }, body: {
    //     "name": groupName,
    //     "description": groupDescription,
    //   });

    //   if (response.statusCode == 200) {
    //     if (kDebugMode) {
    //       print(response.data["group"]);
    //       print("Group created");
    //     }
    //     return Group.fromJson(response.data["group"]);
    //   } else {
    //     throw Failure(message: response.error.toString());
    //   }
    // } on DioError catch (e) {
    //   if (kDebugMode) {
    //     print(e.toString());
    //   }
    //   throw Failure(message: e.toString());
    // }
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
    } on DioError catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print(
            "Exception when calling DefaultApi->groupsAPIUpdateGroup: $error\n");
      }
      throw Failure(message: error);
    }

    // final api = singleton.get<APIHelper>();

    // try {
    //   final response = await api.patch('/groups/$groupId', body: {
    //     "group": {
    //       "name": groupName,
    //       "description": groupDescription,
    //     },
    //     "update_mask": "name,description"
    //   }, headers: {
    //     "Authorization": "Bearer ${userNotifier.token}"
    //   });

    //   if (response.statusCode == 200) {
    //     print(response.data["group"]);
    //     return Group.fromJson(response.data["group"]);
    //   } else {
    //     throw Failure(message: response.error.toString());
    //   }
    // } on DioError catch (e) {
    //   if (kDebugMode) {
    //     print(e.toString());
    //   }
    //   throw Failure(message: e.toString());
    // }
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
    } on DioError catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print(
            "Exception when calling DefaultApi->groupsAPIDeleteGroup: $error\n");
      }
      throw Failure(message: error);
    }

    // final api = singleton.get<APIHelper>();

    // try {
    //   final response = await api.delete('/groups/$groupId',
    //       headers: {"Authorization": "Bearer $token"});

    //   if (response.statusCode == 200) {
    //     return;
    //   } else {
    //     return;
    //   }
    // } on DioError catch (e) {
    //   if (kDebugMode) {
    //     print(e.response!.data['error'].toString());
    //   }
    //   return;
    // }
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
    } on DioError catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print(
            "Exception when calling DefaultApi->groupsAPIListGroups: $error\n");
      }
      throw Failure(message: error);
    }

    // final api = singleton.get<APIHelper>();

    // Map<String, dynamic> queryParams = {
    //   "account_id": accountId,
    // };

    // queryParams.addEntries([
    //   if (offset != null) MapEntry("offset", offset),
    //   if (limit != null) MapEntry("limit", limit),
    // ]);

    // try {
    //   final response = await api.get('/groups',
    //       queryParams: queryParams,
    //       headers: {"Authorization": "Bearer ${userNotifier.token}"});

    //   if (response.statusCode == 200) {
    //     if (response.data["groups"] == null) {
    //       return [];
    //     }
    //     return (response.data["groups"] as List)
    //         .map((e) => Group.fromJson(e))
    //         .toList();
    //   } else {
    //     throw Failure(message: response.error.toString());
    //   }
    // } on DioError catch (e) {
    //   if (kDebugMode) {
    //     print(e.toString());
    //   }
    //   throw Failure(message: e.toString());
    // }
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
      print("group detail infos :");
      print(response.data!.group);

      return Group.fromApi(response.data!.group);
    } on DioError catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->groupsAPIGetGroup: $error\n");
      }
      throw Failure(message: error);
    }

    // final api = singleton.get<APIHelper>();

    // try {
    //   final response = await api.get(
    //     "/groups/$groupId",
    //     headers: {"Authorization": "Bearer ${userNotifier.token}"},
    //   );

    //   if (response.statusCode == 200) {
    //     return Group.fromJson(response.data["group"]);
    //   } else {
    //     return null;
    //     // throw Failure(message: response.error.toString());
    //   }
    // } on DioError catch (e) {
    //   if (kDebugMode) {
    //     print(e.toString());
    //   }
    //   throw Failure(message: e.toString());
    // }
  }

  Future<GroupMember?> getGroupMember(
      String groupId, String memberId, String token) async {
    final api = singleton.get<APIHelper>();

    try {
      final response = await api.get('/groups/$groupId/members/$memberId',
          headers: {"Authorization": "Bearer $token"});
      if (response.statusCode == 200) {
        // TODO: return group member
        return null;

        // return GroupMember.fromJson(response.data["members"]);
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

  Future<GroupMember?> updateGroupMember(
      String groupId, String memberId, String role, String token) async {
    final api = singleton.get<APIHelper>();

    try {
      final response =
          await api.patch('/groups/$groupId/members/$memberId', headers: {
        "Authorization": "Bearer $token"
      }, body: {
        "member": {
          "role": role,
        },
        "update_mask": "role"
      });
      if (response.statusCode == 200) {
        //TODO: return group member
        return null;
        // return GroupMember.fromJson(response.data["member"]);
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

  Future<void> deleteGroupMember(
      String groupId, String memberId, String token) async {
    final api = singleton.get<APIHelper>();

    try {
      final response = await api.delete('/groups/$groupId/members/$memberId',
          headers: {"Authorization": "Bearer $token"});

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

  Future<List<GroupMember>?> listGroupMembers(String groupId, String token,
      {int? offset, int? limit}) async {
    final api = singleton.get<APIHelper>();

    Map<String, dynamic> queryParams = {};

    queryParams.addEntries([
      if (offset != null) MapEntry("offset", offset),
      if (limit != null) MapEntry("limit", limit),
    ]);

    try {
      final response = await api.get(
        "/groups/$groupId/members",
        queryParams: queryParams,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        if (response.data["members"] == null) {
          return [];
        }
        // TODO: fix this
        return [];

        // return (response.data["members"] as List)
        //     .map((e) => GroupMember.fromJson(e))
        //     .toList();
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

  Future<Account?> addGroupNote(String email, String token) async {
    final api = singleton.get<APIHelper>();

    try {
      final response = await api.get('/accounts/email/$email',
          headers: {"Authorization": "Bearer $token"});
      if (response.statusCode == 200) {
        return Account.fromJson(response.data);
      } else {
        return null;
      }
    } on DioError catch (e) {
      if (kDebugMode) {
        print(e.response!.data['error'].toString());
      }
      return null;
    }
  }

  Future<Account?> updateGroupNote(String email, String token) async {
    final api = singleton.get<APIHelper>();

    try {
      final response = await api.get('/accounts/email/$email',
          headers: {"Authorization": "Bearer $token"});
      if (response.statusCode == 200) {
        return Account.fromJson(response.data);
      } else {
        return null;
      }
    } on DioError catch (e) {
      if (kDebugMode) {
        print(e.response!.data['error'].toString());
      }
      return null;
    }
  }

  Future<Account?> deleteGroupNote(String email, String token) async {
    final api = singleton.get<APIHelper>();

    try {
      final response = await api.get('/accounts/email/$email',
          headers: {"Authorization": "Bearer $token"});
      if (response.statusCode == 200) {
        return Account.fromJson(response.data);
      } else {
        return null;
      }
    } on DioError catch (e) {
      if (kDebugMode) {
        print(e.response!.data['error'].toString());
      }
      return null;
    }
  }

  Future<Account?> getGroupNote(String email, String token) async {
    final api = singleton.get<APIHelper>();

    try {
      final response = await api.get('/accounts/email/$email',
          headers: {"Authorization": "Bearer $token"});
      if (response.statusCode == 200) {
        return Account.fromJson(response.data);
      } else {
        return null;
      }
    } on DioError catch (e) {
      if (kDebugMode) {
        print(e.response!.data['error'].toString());
      }
      return null;
    }
  }
}
