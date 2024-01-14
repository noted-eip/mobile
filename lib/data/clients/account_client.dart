import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:noted_mobile/data/models/account/account.dart';
import 'package:noted_mobile/data/notifiers/user_notifier.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/data/providers/utils/api_provider.dart';
import 'package:noted_mobile/data/services/api_execption.dart';
import 'package:noted_mobile/data/services/failure.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:openapi/openapi.dart';
import 'package:tuple/tuple.dart';

class AccountClient {
  AccountClient({required this.ref});
  final ProviderRef<AccountClient> ref;

  // Password

  Future<String?> getAccesTokenGoogle({required String code}) async {
    try {
      final V1AuthenticateGoogleRequest body = V1AuthenticateGoogleRequest(
        (body) => body..clientAccessToken = code,
      );

      final Response<V1AuthenticateGoogleResponse> response =
          await ref.read(apiProvider).accountsAPIAuthenticateGoogle(body: body);

      // var res = await ref.read(apiProvider).accountsAPIGetAccessTokenGoogle

      if (response.statusCode != 200) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }

      return response.data?.token;
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      debugPrint(
          "Exception when calling DefaultApi->getAccesTokenGoogle: $error\n");
      throw Failure(message: error);
    }
  }

  Future<bool> resetPassword({
    required String password,
    required String accountId,
    required String authToken,
    String? resetToken,
    String? oldPaswword,
  }) async {
    final AccountsAPIUpdateAccountPasswordRequest body =
        AccountsAPIUpdateAccountPasswordRequest(
      (body) => body
        ..password = password
        ..token = resetToken
        ..oldPassword = oldPaswword,
    );

    try {
      Response<V1UpdateAccountPasswordResponse> response =
          await ref.read(apiProvider).accountsAPIUpdateAccountPassword(
        body: body,
        accountId: accountId,
        headers: {
          "Authorization": "Bearer $authToken",
        },
      );
      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }

      return true;
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      debugPrint("Exception when calling DefaultApi->resetPassword: $error\n");
      throw Failure(message: error);
    }
  }

  Future<String?> forgetAccountPassword({required String email}) async {
    V1ForgetAccountPasswordRequest body = V1ForgetAccountPasswordRequest(
      (body) => body..email = email,
    );

    try {
      final Response<V1ForgetAccountPasswordResponse> response = await ref
          .read(apiProvider)
          .accountsAPIForgetAccountPassword(body: body);

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }

      return response.data!.accountId;
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      debugPrint(
          "Exception when calling DefaultApi->forgetAccountPassword: $error\n");
      throw Failure(message: error);
    }
  }

  // Validation Token

  Future<Tuple3?> verifyToken({
    required String token,
    required String accountId,
  }) async {
    final V1ForgetAccountPasswordValidateTokenRequest body =
        V1ForgetAccountPasswordValidateTokenRequest(
      (body) => body
        ..token = token
        ..accountId = accountId,
    );

    try {
      final Response<V1ForgetAccountPasswordValidateTokenResponse> response =
          await ref
              .read(apiProvider)
              .accountsAPIForgetAccountPasswordValidateToken(body: body);

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }

      return Tuple3(
        response.data!.resetToken,
        response.data!.authToken,
        response.data!.account.id,
      );
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      debugPrint("Exception when calling DefaultApi->verifyToken: $error\n");
      throw Failure(message: error);
    }
  }

  Future<void> resendValidateToken({
    required String email,
    required String password,
  }) async {
    try {
      final V1SendValidationTokenRequest body = V1SendValidationTokenRequest(
        (body) => body
          ..email = email
          ..password = password,
      );

      final Response<Object> response = await ref
          .read(apiProvider)
          .accountsAPISendValidationToken(body: body);

      if (response.statusCode != 200) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      debugPrint(
          "Exception when calling DefaultApi->resendValidateToken: $error\n");
      throw Failure(message: error);
    }
  }

  // Login

  Future<bool> loginWithGoogle({required String googleToken}) async {
    final DefaultApi apiP = ref.read(apiProvider);
    final UserNotifier userNotifier = ref.read(userProvider);

    final V1AuthenticateGoogleRequest body = V1AuthenticateGoogleRequest(
      (body) => body..clientAccessToken = googleToken,
    );

    try {
      final Response<V1AuthenticateGoogleResponse> response =
          await apiP.accountsAPIAuthenticateGoogle(body: body);

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }

      final String token = response.data!.token;

      Map<String, dynamic> decodedToken = Jwt.parseJwt(token);

      final Response<V1GetAccountResponse> user2 =
          await apiP.accountsAPIGetAccount(
        accountId: decodedToken['aid'],
        headers: {"Authorization": "Bearer $token"},
      );

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
      String error = NotedException.fromDioException(e).toString();
      debugPrint(
          "Exception when calling DefaultApi->loginWithGoogle: $error\n");
      throw Failure(message: error);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final DefaultApi apiP = ref.read(apiProvider);
    final UserNotifier userNotifier = ref.read(userProvider);

    final V1AuthenticateRequest body = V1AuthenticateRequest(
      (body) => body
        ..email = email
        ..password = password,
    );

    try {
      final Response<V1AuthenticateResponse> response =
          await apiP.accountsAPIAuthenticate(body: body);

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }

      final String token = response.data!.token;

      Map<String, dynamic> decodedToken = Jwt.parseJwt(token);

      final Response<V1GetAccountResponse> user2 =
          await apiP.accountsAPIGetAccount(
        accountId: decodedToken['aid'],
        headers: {"Authorization": "Bearer $token"},
      );

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
      String error = NotedException.fromDioException(e).toString();
      debugPrint("Exception when calling DefaultApi->login: $error\n");
      throw Failure(message: error);
    }
  }

  // Account Validation

  Future<bool?> isAccountValidated({
    required String email,
    required String password,
  }) async {
    try {
      final Response<V1IsAccountValidateResponse> response = await ref
          .read(apiProvider)
          .accountsAPIIsAccountValidate(email: email, password: password);

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }
      return response.data!.isAccountValidate;
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      debugPrint(
          "Exception when calling DefaultApi->isAccountValidated: $error\n");
      throw Failure(message: error);
    }
  }

  Future<Account?> validateAccount({
    required String token,
    required String email,
    required String password,
  }) async {
    try {
      V1ValidateAccountRequest body = V1ValidateAccountRequest(
        (body) => body
          ..validationToken = token
          ..email = email
          ..password = password,
      );

      Response<V1ValidateAccountResponse> response =
          await ref.read(apiProvider).accountsAPIValidateAccount(body: body);

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }
      return Account.fromApi(response.data!.account);
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      debugPrint(
          "Exception when calling DefaultApi->validateAccount: $error\n");
      throw Failure(message: error);
    }
  }

  // Register

  Future<Account?> createAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    final V1CreateAccountRequest body = V1CreateAccountRequest(
      (body) => body
        ..name = name
        ..email = email
        ..password = password,
    );

    try {
      final Response<V1CreateAccountResponse> response =
          await ref.read(apiProvider).accountsAPICreateAccount(body: body);

      if (response.statusCode != 200 || response.data == null) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }
      final V1Account apiAccount = response.data!.account;

      return Account.fromApi(apiAccount);
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      debugPrint("Exception when calling DefaultApi->createAccount: $error\n");
      throw Failure(message: error);
    }
  }

  // Account CRUD

  Future<Account?> updateAccount({required String name}) async {
    final UserNotifier userNotifier = ref.read(userProvider);

    try {
      final Response<V1UpdateAccountResponse> response =
          await ref.read(apiProvider).accountsAPIUpdateAccount(
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
        throw Failure(message: response.statusMessage ?? 'Error');
      }
      final V1Account apiAccount = response.data!.account;

      userNotifier.setName(name);

      await SharedPreferences.getInstance().then((prefs) {
        prefs.setString('name', userNotifier.name);
      });

      return Account.fromApi(apiAccount);
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      debugPrint("Exception when calling DefaultApi->updateAccount: $error\n");
      throw Failure(message: error);
    }
  }

  Future<bool> deleteAccount() async {
    final UserNotifier userNotifier = ref.read(userProvider);

    try {
      final Response<Object> response = await ref
          .read(apiProvider)
          .accountsAPIDeleteAccount(
              accountId: userNotifier.id,
              headers: {"Authorization": "Bearer ${userNotifier.token}"});

      if (response.statusCode != 200) {
        throw Failure(message: response.statusMessage ?? 'Error');
      }

      await SharedPreferences.getInstance().then((prefs) {
        prefs.remove('email');
        prefs.remove('name');
        prefs.remove('token');
        prefs.remove('id');
      });
      return true;
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      debugPrint("Exception when calling DefaultApi->deleteAccount: $error\n");
      throw Failure(message: error);
    }
  }

  Future<Account?> getAccountById({required String accountId}) async {
    try {
      final Response<V1GetAccountResponse> response = await ref
          .read(apiProvider)
          .accountsAPIGetAccount(accountId: accountId, headers: {
        "Authorization": "Bearer ${ref.read(userProvider).token}"
      });

      if (response.statusCode != 200 || response.data == null) {
        return null;
      }
      final V1Account apiAccount = response.data!.account;

      return Account.fromApi(apiAccount);
    } on DioException catch (e) {
      debugPrint("Exception when calling DefaultApi->getAccountById: $e\n");
      //TODO: check if this is the right way to handle this
      return null;
      // String error = NotedException.fromDioException(e).toString();
      // if (kDebugMode) {
      //   print("Exception when calling DefaultApi->getAccountById: $error\n");
      // }
      // throw Failure(message: error);
    }
  }

  Future<Account?> getAccountByEmail({
    required String email,
    required String token,
  }) async {
    final V1GetAccountRequest body = V1GetAccountRequest(
      (body) => body..email = email,
    );

    try {
      Response<V1GetAccountResponse> response = await ref
          .read(apiProvider)
          .accountsAPIGetAccount2(body: body, headers: {
        "Authorization": "Bearer ${ref.read(userProvider).token}"
      });

      if (response.statusCode != 200 || response.data == null) {
        return null;
      }

      final V1Account apiAccount = response.data!.account;

      return Account.fromApi(apiAccount);
    } on DioException catch (e) {
      String error = NotedException.fromDioException(e).toString();
      debugPrint(
          "Exception when calling DefaultApi->getAccountByEmail: $error\n");
      throw Failure(message: error);
    }
  }

  // Test

  Map<String, dynamic> testAll() {
    return {
      "CreateAccount": () async => await createAccount(
          name: "name", email: "email", password: "password"),
      "DeleteAccount": () async => await deleteAccount(),
      "ForgetAccountPassword": () async =>
          await forgetAccountPassword(email: "email"),
      "GetAccountByEmail": () async =>
          await getAccountByEmail(email: "email", token: "token"),
      "GetAccountById": () async =>
          await getAccountById(accountId: "accountId"),
      "IsAccountValidated": () async =>
          await isAccountValidated(email: "email", password: "password"),
      "Login": () async => await login(email: "email", password: "password"),
      "LoginWithGoogle": () async =>
          await loginWithGoogle(googleToken: "googleToken"),
      "ResendValidateToken": () async =>
          await resendValidateToken(email: "email", password: "password"),
      "ResetPassword": () async => await resetPassword(
          password: "password", accountId: "accountId", authToken: "authToken"),
      "UpdateAccount": () async => await updateAccount(name: "name"),
      "ValidateAccount": () async => await validateAccount(
          token: "token", email: "email", password: "password"),
      "VerifyToken": () async =>
          await verifyToken(token: "token", accountId: "accountId"),
    };
  }
}
