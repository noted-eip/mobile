import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:noted_mobile/components/common/custom_alerte.dart';
import 'package:noted_mobile/components/common/custom_modal.dart';
import 'package:noted_mobile/components/common/custom_toast.dart';
import 'package:noted_mobile/components/common/loading_button.dart';
import 'package:noted_mobile/data/clients/tracker_client.dart';
import 'package:noted_mobile/data/models/account/account.dart';
import 'package:noted_mobile/data/providers/account_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/utils/string_extension.dart';
import 'package:noted_mobile/utils/theme_helper.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

// TODO : ajouter un bouton pour supprimer le compte et revoir la logique de suppression

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
  final RoundedLoadingButtonController _btnControllerDeleteAccount =
      RoundedLoadingButtonController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  bool isPasswordChanged = false;
  bool isNameChanged = false;

  void updateAccount() async {
    if (nameController.text != ref.read(userProvider).name &&
        nameController.text.length >= 4) {
      if (kDebugMode) {
        print("name changed");
      }

      try {
        final Account? updatedAccount = await ref
            .read(accountClientProvider)
            .updateAccount(name: nameController.text);

        if (updatedAccount != null) {
          _btnControllerSave.success();
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.of(context).pop();
          });

          Future.delayed(const Duration(seconds: 2), () {
            CustomToast.show(
              message: "Account updated successfully",
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
              message: "An error occured while updating your account",
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
        CustomToast.show(
          message: e.toString().capitalize(),
          type: ToastType.error,
          context: context,
          gravity: ToastGravity.BOTTOM,
        );
        _btnControllerSave.error();

        Future.delayed(const Duration(seconds: 1), () {
          _btnControllerSave.reset();
        });
        if (kDebugMode) {
          print(e);
        }
      }
    }

    if (passwordController.text == confirmPasswordController.text &&
        passwordController.text.isNotEmpty) {
      if (kDebugMode) {
        print("password changed");
      }
      _btnControllerSave.reset();
    }
    if (kDebugMode) {
      print("noting changed");
    }
    Future.delayed(const Duration(seconds: 1), () {
      _btnControllerSave.reset();
    });
  }

  void deleteAccount() async {
    var resDiag = await showDialog(
      context: context,
      builder: ((context) {
        return CustomAlertDialog(
          title: "Delete Account",
          content: "Are you sure you want to delete your account ?",
          onConfirm: () async {
            try {
              bool res = await ref.read(accountClientProvider).deleteAccount();

              if (res == true) {
                _btnControllerDeleteAccount.success();
              }
            } catch (e) {
              _btnControllerDeleteAccount.error();
            }
          },
          onCancel: () async {
            _btnControllerDeleteAccount.reset();
          },
        );
      }),
    );

    if (resDiag == false || resDiag == null) {
      _btnControllerDeleteAccount.reset();
    } else {
      _btnControllerDeleteAccount.success();

      if (mounted) {
        Future.delayed(const Duration(seconds: 2), () {
          ref.read(trackerProvider).trackPage(TrackPage.login);
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

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile Page",
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
                                  const Text(
                                    "Edit Account",
                                    style: TextStyle(
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
                                              ThemeHelper().textInputProfile(
                                            labelText: "Name",
                                            hintText: "Enter your name",
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
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return "Name cannot be empty";
                                            } else if (value.length < 4) {
                                              return "Name must be at least 4 characters";
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        TextFormField(
                                          decoration:
                                              ThemeHelper().textInputProfile(
                                            labelText: "Email",
                                            hintText: "Enter your email",
                                            prefixIcon: const Icon(Icons.email),
                                          ),
                                          enabled: false, //isEditing,
                                          controller: emailController,
                                          // validator: (value) {
                                          //   if (value!.isEmpty) {
                                          //     return "Email cannot be empty";
                                          //   } else if (!value.isEmail()) {
                                          //     return "Email is not valid";
                                          //   }
                                          //   return null;
                                          // },
                                        ),
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        TextFormField(
                                          decoration:
                                              ThemeHelper().textInputProfile(
                                            labelText: "Password",
                                            hintText: "••••",
                                            prefixIcon: const Icon(Icons.lock),
                                            suffixIcon: IconButton(
                                              splashColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              icon: Icon(
                                                isPasswordVisible
                                                    ? Icons.visibility_outlined
                                                    : Icons
                                                        .visibility_off_outlined,
                                                color: Colors.grey,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  isPasswordVisible =
                                                      !isPasswordVisible;
                                                });
                                              },
                                            ),
                                          ),
                                          obscureText: isPasswordVisible,
                                          controller: passwordController,
                                          onChanged: (value) {
                                            setState(() {
                                              isValid = value.length >= 4 &&
                                                  value ==
                                                      confirmPasswordController
                                                          .text;
                                            });
                                          },
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return null;
                                              // return "Password cannot be empty";
                                            } else if (value.length < 4) {
                                              return "Password must be at least 4 characters";
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        TextFormField(
                                          decoration:
                                              ThemeHelper().textInputProfile(
                                            labelText: "Confirm Password",
                                            hintText: "••••",
                                            prefixIcon: const Icon(Icons.lock),
                                            suffixIcon: IconButton(
                                              splashColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              icon: Icon(
                                                isConfirmPasswordVisible
                                                    ? Icons.visibility_outlined
                                                    : Icons
                                                        .visibility_off_outlined,
                                                color: Colors.grey,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  isConfirmPasswordVisible =
                                                      !isConfirmPasswordVisible;
                                                });
                                              },
                                            ),
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              isValid = value ==
                                                      passwordController.text &&
                                                  value.length >= 4;
                                            });
                                          },
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return null;
                                              // return "Confirm Password cannot be empty";
                                            } else if (value.length < 4) {
                                              return "Confirm Password must be at least 4 characters";
                                            } else if (value !=
                                                passwordController.text) {
                                              return "Confirm Password must be same as Password";
                                            }
                                            return null;
                                          },
                                          obscureText: isConfirmPasswordVisible,
                                          controller: confirmPasswordController,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                                  if (kDebugMode) {
                                    print("name changed");
                                  }

                                  _btnControllerSave.start();
                                  updateAccount();
                                }
                              } else {
                                if (kDebugMode) {
                                  print("form is invalid");
                                }
                              }
                            },
                            btnController: _btnControllerSave,
                            text: 'Save',
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
            // ZoomDrawer.of(context)!.toggle();
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
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(width: 5, color: Colors.white),
                        color: Colors.grey.shade900,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(5, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 32,
                ),
                TextField(
                  decoration: ThemeHelper().textInputProfile(
                    labelText: "Name",
                    hintText: "Enter your name",
                    prefixIcon: const Icon(Icons.person),
                  ),
                  controller: nameController,
                  enabled: false,
                ),
                const SizedBox(
                  height: 16,
                ),
                TextField(
                  decoration: ThemeHelper().textInputProfile(
                    labelText: "Email",
                    hintText: "Enter your email",
                    prefixIcon: const Icon(Icons.email),
                  ),
                  controller: emailController,
                  enabled: false,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    throw Exception("Crash Test");
                  },
                  child: const Text(
                    'Crash App',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    ref.read(trackerProvider).trackPage(TrackPage.test);
                  },
                  child: const Text(
                    'SEND EVENT',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                TextButton(
                  onPressed: () async => deleteAccount(),
                  child: const Text(
                    'Delete Account',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
