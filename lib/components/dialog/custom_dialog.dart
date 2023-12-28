import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:noted_mobile/components/invites/invite_member.dart';
import 'package:tuple/tuple.dart';

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
          title: const Text("Add Members"),
          content: InviteField(
            controller: controller,
            onEmailCheck: (isValid, newRecipientId) {
              print(
                  "onEmailCheck, isValid : $isValid, newRecipientId : $newRecipientId");

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
              child: const Text("Cancel"),
            ),
            CupertinoDialogAction(
              onPressed: isEmailValid
                  ? () {
                      widget.onSubmited(newRecipientId!);
                      controller.clear();
                      Navigator.pop(context);
                    }
                  : null,
              child: const Text("Add"),
            ),
          ],
        ),
      );
    } else {
      return AlertDialog(
        title: const Text("Add Members"),
        content: InviteField(
          controller: controller,
          onEmailCheck: (isValid, newRecipientId) {
            print(
                "onEmailCheck, isValid : $isValid, newRecipientId : $newRecipientId");

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
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: isEmailValid
                ? () {
                    widget.onSubmited(newRecipientId!);
                    controller.clear();
                    Navigator.pop(context);
                  }
                : null,
            child: const Text("Add"),
          ),
        ],
      );
    }
  }
}
