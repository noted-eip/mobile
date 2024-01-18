import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:noted_mobile/components/common/custom_toast.dart';
import 'package:noted_mobile/components/common/loading_button.dart';
import 'package:noted_mobile/data/clients/tracker_client.dart';
import 'package:noted_mobile/data/providers/account_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/utils/color.dart';
import 'package:noted_mobile/utils/theme_helper.dart';
import 'package:noted_mobile/utils/validator.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:tuple/tuple.dart';

class ForgotPasswordVerificationPage extends ConsumerStatefulWidget {
  const ForgotPasswordVerificationPage({Key? key}) : super(key: key);

  @override
  ForgotPasswordVerificationPageState createState() =>
      ForgotPasswordVerificationPageState();
}

class ForgotPasswordVerificationPageState
    extends ConsumerState<ForgotPasswordVerificationPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController textEditingController = TextEditingController();
  final RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();

  @override
  void initState() {
    textEditingController.addListener(formatCode);
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.removeListener(formatCode);
    super.dispose();
  }

  void formatCode() => ThemeHelper.formatCode(textEditingController);

  @override
  Widget build(BuildContext context) {
    Tuple2<String, bool> args =
        ModalRoute.of(context)!.settings.arguments as Tuple2<String, bool>;

    String accountId = args.item1;
    bool isResetPass = args.item2;

    return Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          forceMaterialTransparency: true,
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Center(
            child: SingleChildScrollView(
              child: SafeArea(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(32, 0, 32, 0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(width: 5, color: Colors.white),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 20,
                              offset: Offset(5, 5),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.key,
                            size: 80, color: Colors.black),
                      ),
                      const SizedBox(height: 50),
                      Container(
                        alignment: Alignment.topLeft,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'forgot.step2.title'.tr(),
                              style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              'forgot.step2.description'.tr(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              controller: textEditingController,
                              autofocus: true,
                              decoration: ThemeHelper.codeInputDecoration(
                                hintText: "_ _ _ _",
                                labelText: 'forgot.step2.code.label'.tr(),
                              ),
                              cursorHeight: 40,
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: NotedColors.primary,
                              ),
                              validator: (val) =>
                                  NotedValidator.validateToken(val),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                if (value.length == 4) {
                                  FocusScope.of(context).unfocus();
                                }
                              },
                              onEditingComplete: () {
                                FocusScope.of(context).unfocus();
                              },
                            ),
                            const SizedBox(height: 30.0),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "forgot.step2.not-received".tr(),
                                    style: const TextStyle(
                                      color: Colors.black38,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ' ',
                                  ),
                                  TextSpan(
                                    text: 'forgot.step2.resend'.tr(),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return ThemeHelper.alartDialog(
                                                "forgot.step2.resend-pop-up.title"
                                                    .tr(),
                                                "forgot.step2.resend-pop-up.description"
                                                    .tr(),
                                                context);
                                          },
                                        );
                                      },
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40.0),
                            LoadingButton(
                              animateOnTap: true,
                              btnController: btnController,
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  await tokenVerification(
                                      textEditingController.text,
                                      accountId,
                                      btnController,
                                      isResetPass);
                                } else {
                                  btnController.error();
                                  resetButton(btnController);
                                }
                              },
                              text: 'forgot.step2.button'.tr(),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  Future<void> tokenVerification(String token, String accountId,
      RoundedLoadingButtonController controller, bool isResetPass) async {
    try {
      final Tuple3? resetToken = await ref
          .read(accountClientProvider)
          .verifyToken(token: token, accountId: accountId);

      if (resetToken != null && mounted) {
        Tuple2<Tuple3<dynamic, dynamic, dynamic>, bool> args =
            Tuple2(resetToken, isResetPass);
        ref.read(trackerProvider).trackPage(TrackPage.changePassword);
        Navigator.pushNamed(context, '/change-password', arguments: args);
      }
    } catch (e) {
      if (mounted) {
        controller.error();
        resetButton(controller);
        CustomToast.show(
          message: e.toString(),
          type: ToastType.error,
          context: context,
          gravity: ToastGravity.TOP,
        );
      }
    }
  }
}
