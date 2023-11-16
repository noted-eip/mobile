import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum ToastType { success, error, warning, info }

class CustomToast {
  static void show({
    required String message,
    required ToastType type,
    required BuildContext context,
    ToastGravity? gravity,
    int? duration,
  }) {
    FToast fToast = FToast().init(context);

    fToast.showToast(
      child: buildToast(type, message),
      gravity: gravity ?? ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: duration ?? 2),
    );
  }

  static Widget buildToast(ToastType type, String message) {
    switch (type) {
      case ToastType.success:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: Colors.greenAccent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check),
              const SizedBox(
                width: 12.0,
              ),
              Expanded(
                child: Text(
                  message,
                  softWrap: true,
                ),
              ),
            ],
          ),
        );
      case ToastType.error:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: Colors.redAccent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error),
              const SizedBox(
                width: 12.0,
              ),
              Expanded(
                child: Text(
                  message,
                  softWrap: true,
                ),
              ),
            ],
          ),
        );
      case ToastType.warning:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: Colors.orangeAccent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning),
              const SizedBox(
                width: 12.0,
              ),
              Expanded(
                child: Text(
                  message,
                  softWrap: true,
                ),
              ),
            ],
          ),
        );
      case ToastType.info:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: Colors.blueAccent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info),
              const SizedBox(
                width: 12.0,
              ),
              Expanded(
                child: Text(
                  message,
                  softWrap: true,
                ),
              ),
            ],
          ),
        );
    }
  }
}
