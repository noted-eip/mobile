import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:noted_mobile/components/common/custom_toast.dart';
import 'package:noted_mobile/components/common/loading_button.dart';
import 'package:noted_mobile/data/providers/account_provider.dart';
import 'package:noted_mobile/utils/theme_helper.dart';
import 'package:noted_mobile/utils/validator.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:tuple/tuple.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      ForgotPasswordPageState();
}

class ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();
  final TextEditingController email = TextEditingController();

  Future<void> resetPassword(String email,
      RoundedLoadingButtonController btnController, bool isResetPass) async {
    var saveContext = context;
    if (_formKey.currentState!.validate()) {
      try {
        btnController.start();
        final accountId = await ref
            .read(accountClientProvider)
            .forgetAccountPassword(email: email);

        if (accountId != null && mounted) {
          btnController.success();
          Navigator.pushNamed(
            context,
            '/forgot-password-verification',
            arguments: Tuple2<String, bool>(accountId, isResetPass),
          );
        } else {
          btnController.error();
        }
      } catch (e) {
        btnController.error();

        if (saveContext.mounted) {
          CustomToast.show(
            message: e.toString(),
            type: ToastType.error,
            context: saveContext,
            gravity: ToastGravity.TOP,
          );
        }
      }
    } else {
      btnController.error();
    }
  }

  @override
  Widget build(BuildContext context) {
    var isResetPassword =
        ModalRoute.of(context)!.settings.arguments as bool? ?? false;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        forceMaterialTransparency: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.fromLTRB(32, 0, 32, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                      child:
                          const Icon(Icons.key, size: 80, color: Colors.black),
                    ),
                    const SizedBox(height: 32),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isResetPassword
                              ? 'forgot.step1.title2'.tr()
                              : 'forgot.step1.title'.tr(),
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'forgot.step1.description'.tr(),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'forgot.step1.description2'.tr(),
                          style: const TextStyle(
                            color: Colors.black38,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40.0),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          Container(
                            decoration: ThemeHelper.inputBoxDecorationShaddow(),
                            child: TextFormField(
                              controller: email,
                              autofocus: true,
                              decoration: ThemeHelper.textInputDecoration(
                                'forgot.step1.email.label'.tr(),
                                'forgot.step1.email.hint'.tr(),
                              ).copyWith(
                                prefixIcon: const Icon(
                                  Icons.mail_outline,
                                  color: Colors.grey,
                                ),
                              ),
                              validator: (val) => NotedValidator.validateEmail(
                                val?.trim(),
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.emailAddress,
                              onEditingComplete: () {
                                FocusScope.of(context).unfocus();
                              },
                            ),
                          ),
                          const SizedBox(height: 40.0),
                          LoadingButton(
                            animateOnTap: false,
                            btnController: btnController,
                            onPressedNoAsync: () async {
                              await resetPassword(email.text.trim(),
                                  btnController, isResetPassword);
                            },
                            text: 'forgot.step1.button'.tr(),
                          ),
                          const SizedBox(height: 32.0),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
