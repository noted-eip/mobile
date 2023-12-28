import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef ContextCallBack = void Function(BuildContext context);

class CustomModal extends ConsumerStatefulWidget {
  const CustomModal(
      {super.key,
      required this.child,
      this.onClose,
      this.iconButton,
      this.height});
  final Widget child;
  final ContextCallBack? onClose;
  final Widget? iconButton;
  final double? height;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CustomModalState();
}

class _CustomModalState extends ConsumerState<CustomModal> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height != null
          ? MediaQuery.of(context).size.height * widget.height!
          : MediaQuery.of(context).size.height * 0.82,
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: (() {
                    if (widget.onClose != null) {
                      widget.onClose!(context);
                    } else {
                      Navigator.pop(context);
                    }
                  }),
                  child: Text(
                    "close".tr(),
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                if (widget.iconButton != null) widget.iconButton!
              ],
            ),
            const SizedBox(
              height: 32,
            ),
            Expanded(
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}
