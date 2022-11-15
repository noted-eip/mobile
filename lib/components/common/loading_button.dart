import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class CustomButton extends StatefulWidget {
  const CustomButton({
    Key? key,
    this.btnColor,
    this.btnErrorColor,
    this.btnSuccessColor,
    required this.onPressed,
    required this.btnController,
    required this.text,
  }) : super(key: key);

  final Color? btnColor;
  final Color? btnErrorColor;
  final Color? btnSuccessColor;
  final VoidCallback onPressed;
  final RoundedLoadingButtonController btnController;
  final String text;

  method() => createState();

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  void resetButton(RoundedLoadingButtonController controller) {
    Timer(const Duration(seconds: 2), () {
      controller.reset();
    });
  }

  // test() {
  //   print('methodInPage2');
  // }

  @override
  Widget build(BuildContext context) {
    return RoundedLoadingButton(
      color: widget.btnColor ?? Colors.grey.shade900,
      errorColor: widget.btnErrorColor ?? Colors.redAccent,
      successColor: widget.btnSuccessColor ?? Colors.green.shade900,
      onPressed: widget.onPressed,
      controller: widget.btnController,
      width: 200,
      child: Text(
        widget.text.toUpperCase(),
        style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
