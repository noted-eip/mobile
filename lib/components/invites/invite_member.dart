import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';

import 'package:noted_mobile/components/common/custom_toast.dart';
import 'package:noted_mobile/components/common/loading_button.dart';
import 'package:noted_mobile/data/models/account/account.dart';
import 'package:noted_mobile/data/models/invite/invite.dart';
import 'package:noted_mobile/data/providers/account_provider.dart';
import 'package:noted_mobile/data/providers/invite_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/utils/string_extension.dart';
import 'package:noted_mobile/utils/theme_helper.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

typedef BoolCallback = void Function(bool isValidEmailAdress, String? userId);

class InviteField extends ConsumerStatefulWidget {
  const InviteField({
    required this.controller,
    required this.onEmailCheck,
    super.key,
  });

  final TextEditingController controller;
  final BoolCallback onEmailCheck;

  @override
  ConsumerState<InviteField> createState() => _InviteFieldState();
}

class _InviteFieldState extends ConsumerState<InviteField> {
  Widget suffixIcon = const SizedBox();
  Timer? debounceTimer;
  bool isLoading = false;
  bool isEmailValid = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(checkEmail);
  }

  @override
  void dispose() {
    widget.controller.removeListener(checkEmail);
    super.dispose();
  }

  void debouncing({required Function() fn, int waitForMs = 500}) {
    debounceTimer?.cancel();
    debounceTimer = Timer(Duration(milliseconds: waitForMs), fn);
  }

  void checkEmail() {
    bool isEmailValidReg = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(widget.controller.text);

    widget.onEmailCheck(false, null);
    setState(() {
      isEmailValid = false;
    });

    if (widget.controller.text.isEmpty || !isEmailValidReg) {
      setState(() {
        suffixIcon = const SizedBox();
      });
    } else {
      setState(() {
        suffixIcon = const CircularProgressIndicator.adaptive();
        isLoading = true;
        isEmailValid = false;
      });

      debouncing(
        fn: () async {
          final user = ref.read(userProvider);
          final email = widget.controller.text.toLowerCase();

          try {
            Account? account = await ref
                .read(accountClientProvider)
                .getAccountByEmail(email: email, token: user.token);

            if (account == null) {
              setState(() {
                suffixIcon = const Icon(Icons.close, color: Colors.red);
                widget.onEmailCheck(false, "");
                isLoading = false;
                isEmailValid = false;
              });
              return "This email is not registered";
            } else {
              setState(() {
                suffixIcon = const Icon(Icons.check, color: Colors.green);
                widget.onEmailCheck(true, account.data.id);
                isEmailValid = true;
                isLoading = false;
              });
              return null;
            }
          } catch (e) {
            setState(() {
              suffixIcon = const Icon(Icons.close, color: Colors.red);
              widget.onEmailCheck(false, null);
              isLoading = false;
              isEmailValid = false;
            });
            return "This email is not registered";
          }
        },
        waitForMs: 2000,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: true,
      controller: widget.controller,
      decoration: ThemeHelper()
          .textInputDecoration(
            'my-groups.create-group-modal.invite-label'.tr(),
            'my-groups.create-group-modal.invite-hint'.tr(),
          )
          .copyWith(
            suffixIcon: suffixIcon,
          ),
      validator: (v) {
        bool isEmailValidReg = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(widget.controller.text);

        if (widget.controller.text.isEmpty || !isEmailValidReg) {
          return "my-groups.create-group-modal.invite-valid".tr();
        }
        checkEmail();

        if (isLoading) {
          return "Verification de l'Email, veuiller patienter...";
        }
        return null;
      },
    );
  }
}

class InviteMemberWidget extends ConsumerStatefulWidget {
  const InviteMemberWidget({
    required this.formKey,
    required this.controller,
    required this.groupId,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final String groupId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InviteMemberState();
}

class _InviteMemberState extends ConsumerState<InviteMemberWidget> {
  bool isValidEmailAdress = false;
  String? recipientId;
  final RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();

  void sendInvite() async {
    if (recipientId == null || !isValidEmailAdress) {
      btnController.error();
      Timer(const Duration(seconds: 2), () {
        btnController.reset();
      });
      return;
    }

    try {
      Invite? invite = await ref.read(inviteClientProvider).sendInvite(
            groupId: widget.groupId,
            recipientId: recipientId!,
          );

      if (invite != null) {
        btnController.success();
        Timer(const Duration(seconds: 2), () {
          btnController.reset();
        });
        widget.controller.clear();
        ref.invalidate(groupInvitesProvider(widget.groupId));
      } else {
        btnController.error();
        Timer(const Duration(seconds: 2), () {
          btnController.reset();
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
      btnController.error();
      Timer(const Duration(seconds: 2), () {
        btnController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "my-groups.create-group-modal.invite-title".tr(),
          style: const TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 32,
        ),
        Expanded(
          child: Form(
            key: widget.formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InviteField(
                  controller: widget.controller,
                  onEmailCheck: (isValid, newRecipientId) {
                    setState(() {
                      isValidEmailAdress = isValid;
                      recipientId = newRecipientId;
                    });
                  },
                ),
                LoadingButton(
                  btnController: btnController,
                  color: isValidEmailAdress
                      ? Colors.grey.shade900
                      : Colors.grey.shade400,
                  animateOnTap: isValidEmailAdress ? true : false,
                  width: double.infinity,
                  onPressed: () async => isValidEmailAdress
                      ? sendInvite()
                      : widget.formKey.currentState!.validate(),
                  text: "Envoyer l'invitation",
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
