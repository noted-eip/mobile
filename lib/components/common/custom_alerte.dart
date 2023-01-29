import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomAlertDialog extends StatefulWidget {
  const CustomAlertDialog({
    required this.title,
    required this.content,
    required this.onConfirm,
    this.onCancel,
    super.key,
  });

  final String title;
  final String content;
  final AsyncCallback onConfirm;
  final AsyncCallback? onCancel;

  @override
  State<CustomAlertDialog> createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(16.0),
        ),
      ),
      title: Text(widget.title),
      content: Text(widget.content),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
            if (widget.onCancel != null) {
              widget.onCancel!();
            }
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, true);
            widget.onConfirm();
          },
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.red),
          ),
          child: const Text("Delete"),
        ),
      ],
    );
  }
}
