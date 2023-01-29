import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:noted_mobile/components/common/custom_alerte.dart';
import 'package:noted_mobile/components/common/custom_toast.dart';
import 'package:noted_mobile/components/common/loading_button.dart';
import 'package:noted_mobile/data/models/account/account.dart';
import 'package:noted_mobile/data/providers/account_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/utils/string_extension.dart';
import 'package:noted_mobile/utils/theme_helper.dart';
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
  final RoundedLoadingButtonController _btnControllerDeleteAccount =
      RoundedLoadingButtonController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  bool isEditing = false;
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
            .updateAccount(nameController.text, ref.read(userProvider).token,
                ref.read(userProvider).id, ref);

        if (updatedAccount != null) {
          _btnControllerSave.success();
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              isEditing = false;
            });
            CustomToast.show(
              message: "Account updated successfully",
              type: ToastType.success,
              context: context,
              gravity: ToastGravity.BOTTOM,
            );
          });
        } else {
          CustomToast.show(
            message: "An error occured while updating your account",
            type: ToastType.error,
            context: context,
            gravity: ToastGravity.BOTTOM,
          );
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
    var res = await showDialog(
      context: context,
      builder: ((context) {
        return CustomAlertDialog(
          title: "Delete Account",
          content: "Are you sure you want to delete your account ?",
          onConfirm: () async {
            try {
              bool res = await ref.read(accountClientProvider).deleteAccount(
                    ref.read(userProvider).id,
                    ref.read(userProvider).token,
                  );

              if (res == true) {
                CustomToast.show(
                  message: "Account deleted successfully",
                  type: ToastType.success,
                  context: context,
                  gravity: ToastGravity.BOTTOM,
                );
                _btnControllerDeleteAccount.success();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (r) => false);
                }
              }
            } catch (e) {
              CustomToast.show(
                message: e.toString().capitalize(),
                type: ToastType.error,
                context: context,
                gravity: ToastGravity.BOTTOM,
              );
              _btnControllerDeleteAccount.error();
            }
          },
          onCancel: () async {
            _btnControllerDeleteAccount.reset();
          },
        );
      }),
    );

    if (res == false || res == null) {
      _btnControllerDeleteAccount.reset();
    }
  }

  @override
  void initState() {
    super.initState();
    nameController.text = ref.read(userProvider).name;
    emailController.text = ref.read(userProvider).email;
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);

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
            icon: Icon(isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              if (isEditing) {
                nameController.text = ref.read(userProvider).name;
                passwordController.clear();
                confirmPasswordController.clear();
              }
              setState(() {
                isEditing = !isEditing;
                isNameChanged = false;
                isPasswordChanged = false;
              });
            },
          )
        ],
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            ZoomDrawer.of(context)!.toggle();
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
                const SizedBox(
                  height: 32,
                ),
                TextField(
                  decoration: ThemeHelper().textInputProfile(
                    labelText: "Name",
                    hintText: "Enter your name",
                    prefixIcon: const Icon(Icons.person),
                  ),
                  enabled: isEditing,
                  controller: nameController,
                  onChanged: (value) {
                    if (nameController.text != ref.read(userProvider).name &&
                        nameController.text.length >= 4) {
                      setState(() {
                        isNameChanged = true;
                      });
                    } else {
                      setState(() {
                        isNameChanged = false;
                      });
                    }
                  },
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
                  enabled: false, //isEditing,
                  controller: emailController,
                ),
                const SizedBox(
                  height: 16,
                ),
                if (isEditing)
                  Column(
                    children: [
                      TextField(
                        decoration: ThemeHelper().textInputProfile(
                          labelText: "Password",
                          hintText: "••••",
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: isPasswordVisible,
                        controller: passwordController,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextField(
                        decoration: ThemeHelper().textInputProfile(
                          labelText: "Confirm Password",
                          hintText: "••••",
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            icon: Icon(
                              isConfirmPasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
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
                          if (passwordController.text ==
                                  confirmPasswordController.text &&
                              passwordController.text.length >= 6) {
                            setState(() {
                              isPasswordChanged = true;
                            });
                          } else {
                            setState(() {
                              isPasswordChanged = false;
                            });
                          }
                        },
                        obscureText: isConfirmPasswordVisible,
                        controller: confirmPasswordController,
                      ),
                    ],
                  ),
                const Spacer(),
                if (isEditing && !isNameChanged && !isPasswordChanged)
                  LoadingButton(
                    onPressed: () async => deleteAccount(),
                    btnController: _btnControllerDeleteAccount,
                    text: 'Delete',
                    color: Colors.redAccent,
                  ),
                if (isEditing && (isNameChanged || isPasswordChanged))
                  LoadingButton(
                    onPressed: () async => updateAccount(),
                    btnController: _btnControllerSave,
                    text: 'Save',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
