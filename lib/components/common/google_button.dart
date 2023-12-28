import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:noted_mobile/components/common/custom_toast.dart';
import 'package:noted_mobile/components/common/loading_button.dart';
import 'package:noted_mobile/pages/account/helper/account.dart';
import 'package:noted_mobile/utils/string_extension.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class GoogleButton extends ConsumerStatefulWidget {
  const GoogleButton({super.key});

  @override
  ConsumerState<GoogleButton> createState() => _GoogleButtonState();
}

class _GoogleButtonState extends ConsumerState<GoogleButton> {
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    return LoadingButton(
      color: Colors.redAccent,
      btnController: _btnController,
      onPressed: () async {
        try {
          LoginAction? loginRes =
              await AccountHelper().loginWithGoogle(ref: ref);

          if (loginRes == null) {
            _btnController.error();
            resetButton(_btnController);
          }

          _btnController.success();
          await AccountHelper().disconnectGoogle();

          if (!mounted) return;

          AccountHelper().handleNavigation(
            action: loginRes,
            context: context,
            email: "",
            password: "",
          );
        } catch (e) {
          if (!mounted) return;
          CustomToast.show(
            message: e.toString().capitalize(),
            type: ToastType.error,
            context: context,
            gravity: ToastGravity.BOTTOM,
          );
          _btnController.error();
          resetButton(_btnController);
        }
      },
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.google,
            color: Colors.white,
          ),
          SizedBox(width: 16.0),
          Text(
            "Google",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
