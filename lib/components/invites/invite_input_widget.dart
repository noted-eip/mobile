import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/models/account/account.dart';
import 'package:noted_mobile/data/providers/account_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/utils/theme_helper.dart';

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
    widget.controller.addListener((() => checkEmail()));
  }

  @override
  void dispose() {
    widget.controller.dispose();
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
              return "invites.not-registered".tr();
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
            return "invites.not-registered".tr();
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
          return "";
        }
        return null;
      },
    );
  }
}
