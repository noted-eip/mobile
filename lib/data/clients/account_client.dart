import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:noted_mobile/data/models/account/account.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/data/providers/utils/api_provider.dart';
import 'package:noted_mobile/data/services/api_execption.dart';
import 'package:noted_mobile/data/services/failure.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:openapi/openapi.dart';
import 'package:tuple/tuple.dart';
//TODO: revoir la gestion d'erreur

class AccountClient {
  AccountClient({required this.ref});
  final ProviderRef<AccountClient> ref;

  Future<bool> resetPassword({
    required String password,
    required String accountId,
    required String authToken,
    String? resetToken,
    String? oldPaswword,
  }) async {
    final apiP = ref.read(apiProvider);

    final AccountsAPIUpdateAccountPasswordRequest body =
        AccountsAPIUpdateAccountPasswordRequest(
      (body) => body
        ..password = password
        ..token = resetToken
        ..oldPassword = oldPaswword,
    );

    try {
      final Response<V1UpdateAccountPasswordResponse> response = await apiP
          .accountsAPIUpdateAccountPassword(
              body: body,
              accountId: accountId,
              headers: {"Authorization": "Bearer $authToken"});

      if (response.statusCode != 200 || response.data == null) {
        if (kDebugMode) {
          print(
            "inside try : code = ${response.statusCode}, error = ${response.toString()}",
          );
        }
        throw Failure(message: response.toString());
      }
      return true;
    } on DioException catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->resetPassword: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<Tuple3?> verifyToken(
      {required String token, required String accountId}) async {
    final apiP = ref.read(apiProvider);

    final V1ForgetAccountPasswordValidateTokenRequest body =
        V1ForgetAccountPasswordValidateTokenRequest(
      (body) => body
        ..token = token
        ..accountId = accountId,
    );

    try {
      final Response<V1ForgetAccountPasswordValidateTokenResponse> response =
          await apiP.accountsAPIForgetAccountPasswordValidateToken(body: body);

      if (response.statusCode != 200 || response.data == null) {
        if (kDebugMode) {
          print(
            "inside try : code = ${response.statusCode}, error = ${response.toString()}",
          );
        }
        throw Failure(message: response.toString());
      }

      return Tuple3(response.data!.resetToken, response.data!.authToken,
          response.data!.account.id);
    } on DioException catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print("error : $error");
        print("error : ${e.response!.data}");
        print("error : ${e.response!.statusCode}");
        print("Exception when calling DefaultApi->verifyToken: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<String?> forgetAccountPassword({required String email}) async {
    final apiP = ref.read(apiProvider);

    V1ForgetAccountPasswordRequest body = V1ForgetAccountPasswordRequest(
      (body) => body..email = email,
    );

    try {
      final Response<V1ForgetAccountPasswordResponse> response =
          await apiP.accountsAPIForgetAccountPassword(body: body);

      if (response.statusCode != 200 || response.data == null) {
        if (kDebugMode) {
          print(
            "inside try : code = ${response.statusCode}, error = ${response.toString()}",
          );
        }
        throw Failure(message: response.toString());
      }
      if (response.data == null) {
        throw Failure(message: "No data");
      }

      return response.data!.accountId;
    } on DioException catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print(
            "Exception when calling DefaultApi->forgetAccountPassword: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<bool> loginWithGoogle(
    String googleToken,
  ) async {
    final apiP = ref.read(apiProvider);

    final userNotifier = ref.read(userProvider);

    final V1AuthenticateGoogleRequest body = V1AuthenticateGoogleRequest(
      (body) => body..clientAccessToken = googleToken,
    );

    try {
      final Response<V1AuthenticateGoogleResponse> response =
          await apiP.accountsAPIAuthenticateGoogle(body: body);

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
    } on DioException catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->loginWithGoogle: $error\n");
      }
      throw Failure(message: error);
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
    } on DioException catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->login: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<bool?> isAccountValidated({
    required String email,
    required String password,
  }) async {
    final apiP = ref.read(apiProvider);
    try {
      Response<V1IsAccountValidateResponse> response = await apiP
          .accountsAPIIsAccountValidate(email: email, password: password);

      if (response.statusCode != 200 || response.data == null) {
        if (kDebugMode) {
          print("inside try : code = ${response.statusCode}");
        }
        throw Failure(message: response.toString());
      }
      return response.data!.isAccountValidate;
    } on DioException catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print(e);
        print(
            "Exception when calling DefaultApi->isAccountValidated: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<void> resendValidateToken({
    required String email,
    required String password,
  }) async {
    final apiP = ref.read(apiProvider);

    try {
      final V1SendValidationTokenRequest body = V1SendValidationTokenRequest(
        (body) => body
          ..email = email
          ..password = password,
      );

      final response = await apiP.accountsAPISendValidationToken(body: body);

      if (response.statusCode != 200) {
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
        print(
            "Exception when calling DefaultApi->resendValidateToken: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<Account?> validateAccount({
    required String token,
    required String email,
    required String password,
  }) async {
    final apiP = ref.read(apiProvider);
    print("token : $token");
    print("email : $email");
    print("password : $password");

    try {
      V1ValidateAccountRequest body = V1ValidateAccountRequest(
        (body) => body
          ..validationToken = token
          ..email = email
          ..password = password,
      );

      Response<V1ValidateAccountResponse> response =
          await apiP.accountsAPIValidateAccount(body: body);

      if (response.statusCode != 200 || response.data == null) {
        if (kDebugMode) {
          print("inside try : code = ${response.statusCode}");
        }
        throw Failure(message: response.toString());
      }
      return Account.fromApi(response.data!.account);
    } on DioException catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->validateAccount: $error\n");
      }
      throw Failure(message: error);
    }
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
    } on DioException catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->createAccount: $error\n");
      }
      throw Failure(message: error);
    }
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
    } on DioException catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->updateAccount: $error\n");
      }
      throw Failure(message: error);
    }
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

      await SharedPreferences.getInstance().then((prefs) {
        prefs.remove('email');
        prefs.remove('name');
        prefs.remove('token');
        prefs.remove('id');
      });
      return true;
    } on DioException catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->deleteAccount: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<Account?> getAccountById(String accountId) async {
    final apiP = ref.read(apiProvider);
    final userNotifier = ref.read(userProvider);

    try {
      final Response<V1GetAccountResponse> response = await apiP
          .accountsAPIGetAccount(
              accountId: accountId,
              headers: {"Authorization": "Bearer ${userNotifier.token}"});

      if (response.statusCode != 200 || response.data == null) {
        if (kDebugMode) {
          print(
            "inside try : code = ${response.statusCode}, error = ${response.toString()}",
          );
        }
        return null;
      }
      final V1Account apiAccount = response.data!.account;

      return Account.fromApi(apiAccount);
    } on DioException catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->getAccountById: $error\n");
      }
      throw Failure(message: error);
    }
  }

  Future<Account?> getAccountByEmail(String email, String token) async {
    final apiP = ref.read(apiProvider);

    final userNotifier = ref.read(userProvider);

    final V1GetAccountRequest body = V1GetAccountRequest(
      (body) => body..email = email,
    );

    try {
      Response<V1GetAccountResponse> response = await apiP
          .accountsAPIGetAccount2(
              body: body,
              headers: {"Authorization": "Bearer ${userNotifier.token}"});

      if (response.statusCode != 200 || response.data == null) {
        return null;
      }

      final V1Account apiAccount = response.data!.account;

      return Account.fromApi(apiAccount);
    } on DioException catch (e) {
      String error = DioExceptions.fromDioError(e).toString();
      if (kDebugMode) {
        print("Exception when calling DefaultApi->getAccountByEmail: $error\n");
      }
      throw Failure(message: error);
    }
  }
}
