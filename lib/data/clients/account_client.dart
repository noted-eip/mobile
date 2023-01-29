import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:noted_mobile/data/models/account/account.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/data/services/api_helper.dart';
import 'package:noted_mobile/data/services/dio_singleton.dart';
import 'package:noted_mobile/data/services/failure.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountClient {
  Future<bool> login(
    String email,
    String password,
    WidgetRef ref,
  ) async {
    final api = singleton.get<APIHelper>();
    final userNotifier = ref.read(userProvider);

    try {
      if (kDebugMode) {
        print('Logging in...');
      }
      final auth = await api.post(
        '/authenticate',
        body: {"email": email, "password": password},
      );

      if (auth.statusCode != 200) {
        if (kDebugMode) {
          print("api error auth catch : ${auth.error.toString()}");
        }
        throw Failure(message: auth.error.toString());
      }

      final token = auth.data['token'];

      Map<String, dynamic> decodedToken = Jwt.parseJwt(token);

      final user = await api.get('/accounts/${decodedToken['uid']}',
          headers: {"Authorization": "Bearer $token"});

      if (user.statusCode != 200) {
        if (kDebugMode) {
          print("api error user catch : ${user.error.toString()}");
        }
        throw Failure(message: user.error.toString());
      }

      final userInfos = user.data['account'];

      userNotifier.setEmail(userInfos['email']);
      userNotifier.setName(userInfos['name']);
      userNotifier.setToken(token);
      userNotifier.setID(userInfos['id']);

      await SharedPreferences.getInstance().then((prefs) {
        prefs.setString('email', userNotifier.email);
        prefs.setString('name', userNotifier.name);
        prefs.setString('token', userNotifier.token);
        prefs.setString('id', userNotifier.id);
      });

      return true;
    } on DioError catch (e) {
      if (kDebugMode) {
        print("Dio error catch : ${e.response!.data['error'].toString()}");
      }

      throw Failure(message: e.response!.data['error'].toString());
    }
  }

  Future<Account?> createAccount(
      String name, String email, String password) async {
    final api = singleton.get<APIHelper>();

    try {
      final response = await api.post('/accounts',
          body: {"name": name, "email": email, "password": password});

      if (response.statusCode != 200) {
        if (kDebugMode) {
          print(
            "inside try : code = ${response.statusCode}, error = ${response.error}",
          );
        }
        throw Failure(message: response.error.toString());
      }
      if (kDebugMode) {
        print("response data in account client : ${response.data}");
      }

      return Account.fromJson(response.data['account']);
    } on DioError catch (e) {
      if (kDebugMode) {
        print("Dio error catch : ${e.response!.data['error'].toString()}");
      }
      throw Failure(message: e.response!.data['error'].toString());
    }
  }

  Future<Account?> updateAccount(
      String name, String token, String accountId, WidgetRef ref) async {
    final api = singleton.get<APIHelper>();
    final userNotifier = ref.read(userProvider);

    try {
      final response = await api.patch(
        '/accounts/$accountId',
        body: {
          "account": {
            "name": name,
          },
          "update_mask": "name"
        },
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode != 200) {
        if (kDebugMode) {
          print(
            "inside try : code = ${response.statusCode}, error = ${response.error}",
          );
        }
        throw Failure(message: response.error.toString());
      }

      userNotifier.setName(name);

      await SharedPreferences.getInstance().then((prefs) {
        prefs.setString('name', userNotifier.name);
      });

      return Account.fromJson(response.data);
    } on DioError catch (e) {
      if (kDebugMode) {
        print("Dio error catch : ${e.response!.data['error'].toString()}");
      }
      throw Failure(message: e.response!.data['error'].toString());
    }
  }

  Future<bool> deleteAccount(String accountId, String token) async {
    final api = singleton.get<APIHelper>();

    try {
      final response = await api.delete(
        '/accounts/$accountId',
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode != 200) {
        if (kDebugMode) {
          print(
            "inside try : code = ${response.statusCode}, error = ${response.error}",
          );
        }
        throw Failure(message: response.error.toString());
      }
      await SharedPreferences.getInstance().then((prefs) {
        prefs.remove('email');
        prefs.remove('name');
        prefs.remove('token');
        prefs.remove('id');
      });

      return true;
    } on DioError catch (e) {
      if (kDebugMode) {
        print("Dio error catch : ${e.response!.data['error'].toString()}");
      }
      throw Failure(message: e.response!.data['error'].toString());
    }
  }

  Future<Account?> getAccountById(String accountId, String token) async {
    final api = singleton.get<APIHelper>();

    try {
      final response = await api.get(
        '/accounts/$accountId',
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode != 200) {
        if (kDebugMode) {
          print(
            "inside try : code = ${response.statusCode}, error = ${response.error}",
          );
        }

        return null;

        // throw Failure(message: response.error.toString());
      }

      return Account.fromJson(response.data["account"]);
    } on DioError catch (e) {
      if (kDebugMode) {
        print("Dio error catch : ${e.response!.data['error'].toString()}");
      }
      throw Failure(message: e.response!.data['error'].toString());
    }
  }

  Future<Account?> getAccountByEmail(String email, String token) async {
    final api = singleton.get<APIHelper>();

    try {
      final response = await api.get(
        '/accounts/by-email/$email',
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode != 200) {
        if (kDebugMode) {
          print(
            "inside try : code = ${response.statusCode}, error = ${response.error}",
          );
        }
        throw Failure(message: response.error.toString());
      }

      return Account.fromJson(response.data["account"]);
    } on DioError catch (e) {
      if (kDebugMode) {
        print("Dio error catch : ${e.response!.data['error'].toString()}");
      }
      throw Failure(message: e.response!.data['error'].toString());
    }
  }
}
