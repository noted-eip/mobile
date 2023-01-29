import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:noted_mobile/data/models/account/account.dart';
import 'package:noted_mobile/data/models/group/group.dart';
import 'package:noted_mobile/data/models/group/group_data.dart';
import 'package:noted_mobile/data/services/api_helper.dart';
import 'package:noted_mobile/data/services/dio_singleton.dart';
import 'package:noted_mobile/data/services/failure.dart';

class GroupClient {
  Future<Group?> createGroup(
      String groupName, String groupDescription, String token) async {
    final api = singleton.get<APIHelper>();

    try {
      final response = await api.post('/groups', headers: {
        "Authorization": "Bearer $token"
      }, body: {
        "name": groupName,
        "description": groupDescription,
      });

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print(response.data["group"]);
          print("Group created");
        }
        return Group.fromJson(response.data["group"]);
      } else {
        throw Failure(message: response.error.toString());
      }
    } on DioError catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      throw Failure(message: e.toString());
    }
  }

  Future<Group?> updateGroup(String groupName, String groupDescription,
      String token, String groupId) async {
    final api = singleton.get<APIHelper>();

    try {
      final response = await api.patch('/groups/$groupId', body: {
        "group": {
          "name": groupName,
          "description": groupDescription,
        },
        "update_mask": "name,description"
      }, headers: {
        "Authorization": "Bearer $token"
      });

      if (response.statusCode == 200) {
        return Group.fromJson(response.data["group"]);
      } else {
        throw Failure(message: response.error.toString());
      }
    } on DioError catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      throw Failure(message: e.toString());
    }
  }

  Future<void> deleteGroup(String groupId, String token) async {
    final api = singleton.get<APIHelper>();

    try {
      final response = await api.delete('/groups/$groupId',
          headers: {"Authorization": "Bearer $token"});

      if (response.statusCode == 200) {
        return;
      } else {
        return;
      }
    } on DioError catch (e) {
      if (kDebugMode) {
        print(e.response!.data['error'].toString());
      }
      return;
    }
  }

  Future<List<Group>?> listGroups(String accountId, String token,
      {int? offset, int? limit}) async {
    final api = singleton.get<APIHelper>();

    Map<String, dynamic> queryParams = {
      "account_id": accountId,
    };

    queryParams.addEntries([
      if (offset != null) MapEntry("offset", offset),
      if (limit != null) MapEntry("limit", limit),
    ]);

    try {
      final response = await api.get('/groups',
          queryParams: queryParams,
          headers: {"Authorization": "Bearer $token"});

      if (response.statusCode == 200) {
        if (response.data["groups"] == null) {
          return [];
        }
        return (response.data["groups"] as List)
            .map((e) => Group.fromJson(e))
            .toList();
      } else {
        throw Failure(message: response.error.toString());
      }
    } on DioError catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      throw Failure(message: e.toString());
    }
  }

  Future<Group?> getGroup(String groupId, String token) async {
    final api = singleton.get<APIHelper>();

    try {
      final response = await api.get(
        "/groups/$groupId",
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        return Group.fromJson(response.data["group"]);
      } else {
        return null;
        // throw Failure(message: response.error.toString());
      }
    } on DioError catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      throw Failure(message: e.toString());
    }
  }

  Future<GroupMember?> getGroupMember(
      String groupId, String memberId, String token) async {
    final api = singleton.get<APIHelper>();

    try {
      final response = await api.get('/groups/$groupId/members/$memberId',
          headers: {"Authorization": "Bearer $token"});
      if (response.statusCode == 200) {
        return GroupMember.fromJson(response.data["member"]);
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
        return GroupMember.fromJson(response.data["member"]);
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

        return (response.data["members"] as List)
            .map((e) => GroupMember.fromJson(e))
            .toList();
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
