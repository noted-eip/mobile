import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

typedef AsyncCallBack = Future<void> Function();

class LoadingButton extends StatefulWidget {
  const LoadingButton({super.key, required this.onPressed, required this.text});

  final AsyncCallBack onPressed;
  final String text;

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  final RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();
  @override
  Widget build(BuildContext context) {
    return RoundedLoadingButton(
      color: Colors.grey.shade900,
      errorColor: Colors.redAccent,
      successColor: Colors.green.shade900,
      onPressed: () async {
        await widget.onPressed();
      },
      controller: btnController,
      width: MediaQuery.of(context).size.width,
      height: 48,
      borderRadius: 16,
      child: Text(
        widget.text.toUpperCase(),
        style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
