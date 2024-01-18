import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:noted_mobile/components/common/custom_alerte.dart';
import 'package:noted_mobile/components/common/custom_modal.dart';
import 'package:noted_mobile/components/common/custom_toast.dart';
import 'package:noted_mobile/components/common/loading_button.dart';
import 'package:noted_mobile/components/common/new_custom_drawer.dart';
import 'package:noted_mobile/data/clients/tracker_client.dart';
import 'package:noted_mobile/data/models/account/account.dart';
import 'package:noted_mobile/data/providers/account_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/utils/color.dart';
import 'package:noted_mobile/utils/language.dart';
import 'package:noted_mobile/utils/string_extension.dart';
import 'package:noted_mobile/utils/theme_helper.dart';
import 'package:noted_mobile/utils/validator.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  final RoundedLoadingButtonController _btnControllerSave =
      RoundedLoadingButtonController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  bool isPasswordChanged = false;
  bool isNameChanged = false;

  bool isLoading = false;

  void updateAccount() async {
    if (nameController.text != ref.read(userProvider).name &&
        nameController.text.length >= 4) {
      try {
        final Account? updatedAccount = await ref
            .read(accountClientProvider)
            .updateAccount(name: nameController.text);

        if (updatedAccount != null) {
          ref.invalidate(accountProvider(ref.read(userProvider).id));
          _btnControllerSave.success();
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.of(context).pop();
          });

          Future.delayed(const Duration(seconds: 2), () {
            CustomToast.show(
              message: "profil.success".tr(),
              type: ToastType.success,
              context: context,
              gravity: ToastGravity.BOTTOM,
            );
            setState(() {
              isValid = false;
            });
          });
        } else {
          if (mounted) {
            CustomToast.show(
              message: "profil.error".tr(),
              type: ToastType.error,
              context: context,
              gravity: ToastGravity.BOTTOM,
            );
          }

          _btnControllerSave.error();
          Future.delayed(const Duration(seconds: 1), () {
            _btnControllerSave.reset();
          });
        }
      } catch (e) {
        if (mounted) {
          CustomToast.show(
            message: e.toString().capitalize(),
            type: ToastType.error,
            context: context,
            gravity: ToastGravity.BOTTOM,
          );
        }
        _btnControllerSave.error();

        Future.delayed(const Duration(seconds: 1), () {
          _btnControllerSave.reset();
        });
        if (kDebugMode) {
          print(e);
        }
      }
    }

    Future.delayed(const Duration(seconds: 1), () {
      _btnControllerSave.reset();
    });
  }

  void deleteAccount() async {
    var resDiag = await showDialog<bool>(
      context: context,
      builder: ((context) {
        return CustomAlertDialog(
          title: "profil.delete-account".tr(),
          content: "profil.delete-account-description".tr(),
          onConfirm: () async {
            try {
              bool res = await ref.read(accountClientProvider).deleteAccount();

              if (!mounted) return;

              Navigator.pop(context, res);
            } catch (e) {
              if (mounted) {
                CustomToast.show(
                  message: e.toString().capitalize(),
                  type: ToastType.error,
                  context: context,
                  gravity: ToastGravity.BOTTOM,
                );
              }
              Navigator.pop(context, false);
            }
          },
        );
      }),
    );

    if (resDiag != null && resDiag) {
      if (mounted) {
        CustomToast.show(
          message: "profil.delete-account-success".tr(),
          type: ToastType.success,
          context: context,
          gravity: ToastGravity.BOTTOM,
        );
        Future.microtask(() {
          ref.read(mainScreenProvider).setItem(MyMenuItems.home);
          Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    nameController.text = ref.read(userProvider).name;
    emailController.text = ref.read(userProvider).email;
  }

  bool isValid = false;

  String saveLanguage = "";

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    if (saveLanguage.isEmpty) {
      saveLanguage = context.locale.languageCode;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "profil.title".tr(),
          style: TextStyle(
              color: Colors.grey.shade900, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.grey.shade900),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await showModalBottomSheet(
                backgroundColor: Colors.transparent,
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                    return CustomModal(
                      height: 1,
                      onClose: (context) {
                        Navigator.pop(context, false);
                        setState(() {
                          isValid = false;
                        });
                        passwordController.clear();
                        confirmPasswordController.clear();
                        nameController.text = ref.read(userProvider).name;
                      },
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Text(
                                    "profil.edit-profile".tr(),
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Form(
                                    key: formKey,
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          decoration:
                                              ThemeHelper.textInputProfile(
                                            labelText: "profil.name".tr(),
                                            hintText: "profil.name-hint".tr(),
                                            prefixIcon:
                                                const Icon(Icons.person),
                                          ),
                                          controller: nameController,
                                          onChanged: (value) {
                                            setState(() {
                                              isValid = value !=
                                                      ref
                                                          .read(userProvider)
                                                          .name &&
                                                  value.length >= 4;
                                            });
                                          },
                                          validator: (value) =>
                                              NotedValidator.validateName(
                                                  value),
                                        ),
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        TextFormField(
                                          decoration:
                                              ThemeHelper.textInputProfile(
                                            labelText: "profil.email".tr(),
                                            hintText: "profil.email-hint".tr(),
                                            prefixIcon: const Icon(Icons.email),
                                          ),
                                          enabled: false,
                                          controller: emailController,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(
                                context, '/forgot-password',
                                arguments: true),
                            child: Text(
                              'profil.edit-password'.tr(),
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          LoadingButton(
                            color: isValid
                                ? Colors.grey.shade900
                                : Colors.grey.shade400,
                            animateOnTap: false,
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                if (passwordController.text ==
                                        confirmPasswordController.text &&
                                    passwordController.text.isNotEmpty) {
                                  _btnControllerSave.start();

                                  Future.delayed(
                                      const Duration(milliseconds: 2000), () {
                                    _btnControllerSave.reset();
                                  });
                                }

                                if (nameController.text !=
                                    ref.read(userProvider).name) {
                                  _btnControllerSave.start();
                                  updateAccount();
                                }
                              } else {}
                            },
                            btnController: _btnControllerSave,
                            text: 'profil.button'.tr(),
                          ),
                        ],
                      ),
                    );
                  });
                },
              );
            },
          )
        ],
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      body: SizedBox(
        height: mediaQuery.size.height - kToolbarHeight,
        child: SingleChildScrollView(
          child: Container(
            width: mediaQuery.size.width,
            height: mediaQuery.size.height -
                kToolbarHeight -
                mediaQuery.padding.top -
                mediaQuery.viewPadding.top,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 30),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border:
                            Border.all(width: 1, color: NotedColors.primary),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: NotedColors.primary,
                            blurRadius: 5,
                            offset: Offset(5, 5),
                          ),
                        ],
                      ),
                      child: Text(
                        ref
                            .read(userProvider)
                            .name
                            .substring(0, 1)
                            .toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 80.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 32,
                ),
                TextField(
                  decoration: ThemeHelper.textInputProfile(
                    labelText: "profil.name".tr(),
                    hintText: "profil.name-hint".tr(),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  controller: nameController,
                  enabled: false,
                ),
                const SizedBox(
                  height: 16,
                ),
                TextField(
                  decoration: ThemeHelper.textInputProfile(
                    labelText: "profil.email".tr(),
                    hintText: "profil.email-hint".tr(),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  controller: emailController,
                  enabled: false,
                ),
                const Spacer(),
                Row(
                  children: [
                    TextButton(
                      onPressed: () async => deleteAccount(),
                      child: Text(
                        'profil.delete-account'.tr(),
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                    const Spacer(),
                    DropdownButton<String>(
                        borderRadius: BorderRadius.circular(16),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        underline: const SizedBox(),
                        selectedItemBuilder: (context) =>
                            LanguagePreferences.languageNameMap.entries
                                .map((e) => Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(e.value),
                                        const SizedBox(width: 10),
                                        Text(LanguagePreferences
                                            .languageFlagMap[e.key]!),
                                      ],
                                    ))
                                .toList(),
                        iconSize: 16,
                        value: context.locale.languageCode,
                        items: LanguagePreferences.languageNameMap.entries
                            .map((e) => DropdownMenuItem(
                                value: e.key,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    saveLanguage == e.key
                                        ? const Icon(Icons.check, size: 16)
                                        : const SizedBox(width: 16),
                                    const SizedBox(width: 10),
                                    Text(e.value),
                                    const SizedBox(width: 10),
                                    Text(LanguagePreferences
                                        .languageFlagMap[e.key]!),
                                  ],
                                )))
                            .toList(),
                        onChanged: <String>(code) async {
                          setState(() {
                            saveLanguage = code;
                          });
                          await LanguagePreferences.setLangue(context, code);
                        })
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
