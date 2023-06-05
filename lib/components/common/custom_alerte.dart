import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomAlertDialog extends StatefulWidget {
  const CustomAlertDialog({
    required this.title,
    required this.content,
    required this.onConfirm,
    this.onCancel,
    this.contentWidget,
    this.cancelText,
    this.confirmText,
    super.key,
  });

  final String title;
  final String content;
  final AsyncCallback onConfirm;
  final AsyncCallback? onCancel;
  final Widget? contentWidget;
  final String? cancelText;
  final String? confirmText;

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
      content: widget.contentWidget != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.content),
                const SizedBox(height: 16.0),
                widget.contentWidget!,
              ],
            )
          : Text(widget.content),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
            if (widget.onCancel != null) {
              widget.onCancel!();
            }
          },
          child: Text(widget.cancelText ?? "Cancel"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, true);
            widget.onConfirm();
          },
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.red),
          ),
          child: Text(widget.confirmText ?? "Delete"),
        ),
      ],
    );
  }
}
