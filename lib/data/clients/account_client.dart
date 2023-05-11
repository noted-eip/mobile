import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:noted_mobile/data/models/account/account.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/data/providers/utils/api_provider.dart';
import 'package:noted_mobile/data/services/api_execption.dart';
import 'package:noted_mobile/data/services/api_helper.dart';
import 'package:noted_mobile/data/services/dio_singleton.dart';
import 'package:noted_mobile/data/services/failure.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:openapi/openapi.dart';

class AccountClient {
  AccountClient({required this.ref});
  final ProviderRef<AccountClient> ref;

  Future<bool> loginWithGoogle(
    String googleToken,
    // WidgetRef ref,
  ) async {
    final api = singleton.get<APIHelper>();
    // final userNotifier = ref.read(userProvider);

    try {
      final response =
          await api.post('/accounts/google', body: {"token": googleToken});

      if (response.statusCode != 200) {
        if (kDebugMode) {
          print(
            "inside try : code = ${response.statusCode}, error = ${response.error}",
          );
        }
        throw Failure(message: response.error.toString());
      }

      // userNotifier.setEmail("Email");
      // userNotifier.setName("Name");
      // userNotifier.setToken("Token");
      // userNotifier.setID("ID");

      // await SharedPreferences.getInstance().then((prefs) {
      //   prefs.setString('email', userNotifier.email);
      //   prefs.setString('name', userNotifier.name);
      //   prefs.setString('token', userNotifier.token);
      //   prefs.setString('id', userNotifier.id);
      // });

      return true;
    } on DioError catch (e) {
      if (kDebugMode) {
        print("Dio error catch : ${e.response!.data['error'].toString()}");
      }
      throw Failure(message: e.response!.data['error'].toString());
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final apiP = ref.read(apiProvider);
    final userNotifier = ref.read(userProvider);

    final V1AuthenticateRequest body = V1AuthenticateRequest(
      (body) => body
        ..email = email
        ..password = password,
    );

    try {
      final Response<V1AuthenticateResponse> response =
          await apiP.accountsAPIAuthenticate(body: body);

      if (response.statusCode != 200 || response.data == null) {
        if (kDebugMode) {
          print(
            "inside try : code = ${response.statusCode}, error = ${response.toString()}",
          );
        }
        throw Failure(message: response.toString());
      }

      final token = response.data!.token;

      Map<String, dynamic> decodedToken = Jwt.parseJwt(token);

      final Response<V1GetAccountResponse> user2 =
          await apiP.accountsAPIGetAccount(
        accountId: decodedToken['aid'],
        headers: {"Authorization": "Bearer $token"},
      );

      // // TODO: check if this block is necessary
      // TODO: check DIO docs for response.data == null
      // if (user2.statusCode != 200 ||
      //     user2.data == null ||
      //     user2.data!.account == null) {
      //   if (kDebugMode) {
      //     print("api error user catch : ${user2.toString()}");
      //   }
      //   throw Failure(message: user2.toString());
      // }

      // //

      final V1Account userInfos = user2.data!.account;

      userNotifier.setEmail(userInfos.email);
      userNotifier.setName(userInfos.name);
      userNotifier.setToken(token);
      userNotifier.setID(userInfos.id);

      await SharedPreferences.getInstance().then((prefs) {
        prefs.setString('email', userNotifier.email);
        prefs.setString('name', userNotifier.name);
        prefs.setString('token', userNotifier.token);
        prefs.setString('id', userNotifier.id);
      });

      return true;
    } on DioError catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print(
            "Exception when calling DefaultApi->accountsAPIAuthenticate: $error\n");
      }
      throw Failure(message: error);
    }

    //OLD VERSION OF LOGIN

    // final api = singleton.get<APIHelper>();

    // try {
    //   if (kDebugMode) {
    //     print('Logging in...');
    //   }
    //   final auth = await api.post(
    //     '/authenticate',
    //     body: {"email": email, "password": password},
    //   );

    //   print("auth : ");
    //   print(auth.data);

    //   if (auth.statusCode != 200) {
    //     if (kDebugMode) {
    //       print("api error auth catch : ${auth.error.toString()}");
    //     }
    //     throw Failure(message: auth.error.toString());
    //   }

    //   final token = auth.data['token'];

    //   Map<String, dynamic> decodedToken = Jwt.parseJwt(token);

    //   print("decodedToken : ");
    //   print(decodedToken);

    //   final user = await api.get('/accounts/${decodedToken['aid']}',
    //       headers: {"Authorization": "Bearer $token"});
    //   print("user : ");
    //   print(user.data);

    //   if (user.statusCode != 200) {
    //     if (kDebugMode) {
    //       print("api error user catch : ${user.error.toString()}");
    //     }
    //     throw Failure(message: user.error.toString());
    //   }

    //   final userInfos = user.data['account'];

    //   userNotifier.setEmail(userInfos['email']);
    //   userNotifier.setName(userInfos['name']);
    //   userNotifier.setToken(token);
    //   userNotifier.setID(userInfos['id']);

    //   await SharedPreferences.getInstance().then((prefs) {
    //     prefs.setString('email', userNotifier.email);
    //     prefs.setString('name', userNotifier.name);
    //     prefs.setString('token', userNotifier.token);
    //     prefs.setString('id', userNotifier.id);
    //   });

    //   return true;
    // } on DioError catch (e) {
    //   if (kDebugMode) {
    //     print("Dio error catch : ${e.response!.data['error'].toString()}");
    //   }

    //   throw Failure(message: e.response!.data['error'].toString());
    // }
  }

  Future<Account?> createAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    final apiP = ref.read(apiProvider);

    final V1CreateAccountRequest body = V1CreateAccountRequest(
      (body) => body
        ..name = name
        ..email = email
        ..password = password,
    );

    print(body);

    try {
      final Response<V1CreateAccountResponse> response =
          await apiP.accountsAPICreateAccount(body: body);

      if (response.statusCode != 200 || response.data == null) {
        if (kDebugMode) {
          print(
            "inside try : code = ${response.statusCode}, error = ${response.toString()}",
          );
        }
        throw Failure(message: response.toString());
      }
      final V1Account apiAccount = response.data!.account;

      return Account.fromApi(apiAccount);
    } on DioError catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print(
            "Exception when calling DefaultApi->accountsAPICreateAccount: $error\n");
      }
      throw Failure(message: error);
    }

    //OLD VERSION OF CREATE ACCOUNT

    // final api = singleton.get<APIHelper>();

    // try {
    //   final response = await api.post('/accounts',
    //       body: {"name": name, "email": email, "password": password});

    //   if (response.statusCode != 200) {
    //     if (kDebugMode) {
    //       print(
    //         "inside try : code = ${response.statusCode}, error = ${response.error}",
    //       );
    //     }
    //     throw Failure(message: response.error.toString());
    //   }
    //   if (kDebugMode) {
    //     print("response data in account client : ${response.data}");
    //   }

    //   return Account.fromJson(response.data['account']);
    // } on DioError catch (e) {
    //   if (kDebugMode) {
    //     print("Dio error catch : ${e.response!.data['error'].toString()}");
    //   }
    //   throw Failure(message: e.response!.data['error'].toString());
    // }
  }

  Future<Account?> updateAccount({required String name}) async {
    final apiP = ref.read(apiProvider);
    final userNotifier = ref.read(userProvider);

    try {
      final Response<V1UpdateAccountResponse> response =
          await apiP.accountsAPIUpdateAccount(
        accountId: userNotifier.id,
        account: V1Account((account) {
          account
            ..name = name
            ..email = userNotifier.email
            ..id = userNotifier.id;
        }),
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
      final V1Account apiAccount = response.data!.account;

      userNotifier.setName(name);

      // TODO : save shared preferences in provider

      await SharedPreferences.getInstance().then((prefs) {
        prefs.setString('name', userNotifier.name);
      });

      return Account.fromApi(apiAccount);
    } on DioError catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print(
            "Exception when calling DefaultApi->accountsAPIUpdateAccount: $error\n");
      }
      throw Failure(message: error);
    }

    // OLD VERSION OF UPDATE ACCOUNT
    // final api = singleton.get<APIHelper>();
    // final userNotifier = ref.read(userProvider);

    // try {
    //   final response = await api.patch(
    //     '/accounts/${userNotifier.id}',
    //     body: {
    //       "account": {
    //         "name": name,
    //       },
    //       "update_mask": "name"
    //     },
    //     headers: {"Authorization": "Bearer ${userNotifier.token}"},
    //   );

    //   if (response.statusCode != 200) {
    //     if (kDebugMode) {
    //       print(
    //         "inside try : code = ${response.statusCode}, error = ${response.error}",
    //       );
    //     }
    //     throw Failure(message: response.error.toString());
    //   }

    //   userNotifier.setName(name);

    //   await SharedPreferences.getInstance().then((prefs) {
    //     prefs.setString('name', userNotifier.name);
    //   });

    //   return Account.fromJson(response.data);
    // } on DioError catch (e) {
    //   if (kDebugMode) {
    //     print("Dio error catch : ${e.response!.data['error'].toString()}");
    //   }
    //   throw Failure(message: e.response!.data['error'].toString());
    // }
  }

  Future<bool> deleteAccount() async {
    final userNotifier = ref.read(userProvider);

    final apiP = ref.read(apiProvider);

    try {
      final response = await apiP.accountsAPIDeleteAccount(
          accountId: userNotifier.id,
          headers: {"Authorization": "Bearer ${userNotifier.token}"});

      if (response.statusCode != 200) {
        if (kDebugMode) {
          print(
            "inside try : code = ${response.statusCode}, error = ${response.toString()}",
          );
        }
        throw Failure(message: response.toString());
      }

      print("account deleted successfully");

      await SharedPreferences.getInstance().then((prefs) {
        prefs.remove('email');
        prefs.remove('name');
        prefs.remove('token');
        prefs.remove('id');
      });
      return true;
    } on DioError catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print(
            "Exception when calling DefaultApi->accountsAPIDeleteAccount: $error\n");
      }
      throw Failure(message: error);
    }

    // final api = singleton.get<APIHelper>();

    // try {
    //   final response = await api.delete(
    //     '/accounts/$accountId',
    //     headers: {"Authorization": "Bearer $token"},
    //   );

    //   if (response.statusCode != 200) {
    //     if (kDebugMode) {
    //       print(
    //         "inside try : code = ${response.statusCode}, error = ${response.error}",
    //       );
    //     }
    //     throw Failure(message: response.error.toString());
    //   }
    //   await SharedPreferences.getInstance().then((prefs) {
    //     prefs.remove('email');
    //     prefs.remove('name');
    //     prefs.remove('token');
    //     prefs.remove('id');
    //   });

    //   return true;
    // } on DioError catch (e) {
    //   if (kDebugMode) {
    //     print("Dio error catch : ${e.response!.data['error'].toString()}");
    //   }
    //   throw Failure(message: e.response!.data['error'].toString());
    // }
  }

  Future<Account?> getAccountById(String accountId) async {
    // final apiP = ref.read(apiProvider);
    final userNotifier = ref.read(userProvider);

    // try {
    //   final Response<V1GetAccountResponse> response = await apiP
    //       .accountsAPIGetAccount(
    //           accountId: accountId,
    //           headers: {"Authorization": "Bearer ${userNotifier.token}"});

    //   if (response.statusCode != 200 || response.data == null) {
    //     if (kDebugMode) {
    //       print(
    //         "inside try : code = ${response.statusCode}, error = ${response.toString()}",
    //       );
    //     }
    //     return null;

    //     // throw Failure(message: response.toString());
    //   }
    //   final V1Account apiAccount = response.data!.account;

    //   return Account.fromApi(apiAccount);
    // } on DioError catch (e) {
    //   String error = DioExceptions.fromDioError(e).toString();
    //   if (kDebugMode) {
    //     print(
    //         "Exception when calling DefaultApi->accountsAPIGetAccount: $error\n");
    //   }
    //   throw Failure(message: error);
    // }

    final api = singleton.get<APIHelper>();
    print(accountId);

    try {
      final response = await api.get(
        '/accounts/$accountId',
        headers: {"Authorization": "Bearer ${userNotifier.token}"},
      );

      print("response : ${response.data}");
      print("response : ${response.statusCode}");

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
