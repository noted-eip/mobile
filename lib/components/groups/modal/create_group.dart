import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:noted_mobile/components/common/custom_modal.dart';
import 'package:noted_mobile/components/common/custom_toast.dart';
import 'package:noted_mobile/components/common/loading_button.dart';
import 'package:noted_mobile/components/groups/group_info_input.dart';
import 'package:noted_mobile/data/models/group/group.dart';
import 'package:noted_mobile/data/notifiers/user_notifier.dart';
import 'package:noted_mobile/data/providers/group_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/utils/string_extension.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:tuple/tuple.dart';

class CreateGroupModal extends ConsumerStatefulWidget {
  const CreateGroupModal({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateGroupModalState();
}

class _CreateGroupModalState extends ConsumerState<CreateGroupModal> {
  final TextEditingController controller = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final roleformKey = GlobalKey<FormState>();
  final _formKey = GlobalKey<FormState>();
  final RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();
  String groupId = "";
  String buttonText = "my-groups.create-group-modal.button1".tr();

  List<Tuple2<String, String>> members = [];

  Future<void> createGroup(UserNotifier user) async {
    if (_formKey.currentState!.validate()) {
      try {
        Group? group = await ref.read(groupClientProvider).createGroup(
            groupName: _titleController.text,
            groupDescription: _descriptionController.text);
        if (group != null) {
          btnController.reset();
          _descriptionController.clear();
          _titleController.clear();
          ref.invalidate(groupsProvider);
          ref.invalidate(latestGroupsProvider);

          if (mounted) {
            Navigator.pop(context, true);
            Navigator.pushNamed(context, "/group-detail",
                arguments: group.data.id);
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("Failed to create Group, Api response :${e.toString()}");
        }
        if (mounted) {
          CustomToast.show(
            message: e.toString().capitalize(),
            type: ToastType.error,
            context: context,
            gravity: ToastGravity.BOTTOM,
          );
        }
        btnController.error();
        Future.delayed(const Duration(seconds: 1), () {
          btnController.reset();
        });
      }
    } else {
      btnController.error();
      Future.delayed(const Duration(seconds: 1), () {
        btnController.reset();
      });
    }
  }

  bool isEmailValid = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider);

    return CustomModal(
      height: 1,
      onClose: (context) => Navigator.pop(context, false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: GroupInfosInput(
              formKey: _formKey,
              descriptionController: _descriptionController,
              titleController: _titleController,
              title: "my-groups.create-group-modal.title".tr(),
            ),
          ),
          LoadingButton(
            btnController: btnController,
            onPressed: () async => createGroup(user),
            text: "my-groups.create-group-modal.button2".tr(),
            resetDuration: 1,
          ),
        ],
      ),
    );
  }
}
