import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:noted_mobile/components/invites/invite_member.dart';

class CustomDialogWidget extends StatefulWidget {
  const CustomDialogWidget({
    required this.onSubmited,
    Key? key,
  }) : super(key: key);

  final Function(String) onSubmited;

  @override
  State<CustomDialogWidget> createState() => _CustomDialogWidgetState();
}

class _CustomDialogWidgetState extends State<CustomDialogWidget> {
  final TextEditingController controller = TextEditingController();
  bool isEmailValid = false;
  String? newRecipientId;

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return Material(
        color: Colors.black38,
        child: CupertinoAlertDialog(
          title: Text("dialog.add_members".tr()),
          content: InviteField(
            controller: controller,
            onEmailCheck: (isValid, newRecipientId) {
              setState(() {
                isEmailValid = isValid;
                this.newRecipientId = newRecipientId;
              });
            },
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("dialog.cancel".tr()),
            ),
            CupertinoDialogAction(
              onPressed: isEmailValid
                  ? () {
                      widget.onSubmited(newRecipientId!);
                      controller.clear();
                      Navigator.pop(context);
                    }
                  : null,
              child: Text("dialog.add".tr()),
            ),
          ],
        ),
      );
    } else {
      return AlertDialog(
        title: Text("dialog.add_members".tr()),
        content: InviteField(
          controller: controller,
          onEmailCheck: (isValid, newRecipientId) {
            setState(() {
              isEmailValid = isValid;
              this.newRecipientId = newRecipientId;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("dialog.cancel".tr()),
          ),
          TextButton(
            onPressed: isEmailValid
                ? () {
                    widget.onSubmited(newRecipientId!);
                    controller.clear();
                    Navigator.pop(context);
                  }
                : null,
            child: Text("dialog.add".tr()),
          ),
        ],
      );
    }
  }
}
