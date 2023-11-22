import 'dart:async';

import 'package:flutter/material.dart';
import 'package:noted_mobile/utils/color.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

typedef AsyncCallBack = Future<void> Function();

void resetButton(RoundedLoadingButtonController controller) async {
  Timer(const Duration(seconds: 3), () {
    controller.reset();
  });
}

class LoadingButton extends StatefulWidget {
  const LoadingButton({
    super.key,
    required this.onPressed,
    this.text,
    required this.btnController,
    this.color,
    this.secondaryColor,
    this.width,
    this.child,
    this.elevation,
    this.resetDuration,
    this.animateOnTap,
  });

  final AsyncCallBack? onPressed;
  final RoundedLoadingButtonController btnController;
  final String? text;
  final bool? animateOnTap;
  final Color? color;
  final Color? secondaryColor;
  final double? width;
  final double? elevation;
  final int? resetDuration;

  final Widget? child;

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  @override
  Widget build(BuildContext context) {
    return RoundedLoadingButton(
      elevation: widget.elevation ?? 2,
      animateOnTap: widget.animateOnTap ?? true,
      color: widget.color ?? NotedColors.primary,
      valueColor: widget.secondaryColor ?? Colors.white,
      errorColor: Colors.redAccent,
      successColor: Colors.green.shade900,
      onPressed: widget.onPressed != null
          ? () async => await widget.onPressed!()
          : null,
      controller: widget.btnController,
      width: widget.width ?? MediaQuery.of(context).size.width,
      height: 48,
      borderRadius: 16,
      resetAfterDuration: true,
      resetDuration: Duration(seconds: widget.resetDuration ?? 3),
      disabledColor: widget.color != null
          ? widget.color!.withOpacity(0.5)
          : Colors.grey.shade400,
      child: widget.child != null
          ? widget.child!
          : widget.text != null
              ? Text(
                  widget.text!.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              : const SizedBox.shrink(),
    );
  }
}
