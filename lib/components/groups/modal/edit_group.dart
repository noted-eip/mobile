import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:noted_mobile/components/common/custom_modal.dart';
import 'package:noted_mobile/components/common/custom_toast.dart';
import 'package:noted_mobile/components/common/loading_button.dart';
import 'package:noted_mobile/components/groups/group_info_input.dart';
import 'package:noted_mobile/data/models/group/group.dart';
import 'package:noted_mobile/data/providers/group_provider.dart';
import 'package:noted_mobile/utils/string_extension.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class EditGroupModal extends ConsumerStatefulWidget {
  const EditGroupModal(
      {super.key,
      required this.btnController,
      required this.userTkn,
      required this.groupId,
      required this.baseTitle,
      required this.baseDescription});
  final String groupId;
  final String userTkn;
  final String baseTitle;
  final String baseDescription;
  final RoundedLoadingButtonController btnController;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditGroupModalState();
}

class _EditGroupModalState extends ConsumerState<EditGroupModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    _titleController.text = widget.baseTitle;
    _descriptionController.text = widget.baseDescription;
    super.initState();
  }

  Future<void> editGroup() async {
    try {
      Group? group = await ref.read(groupClientProvider).updateGroup(
            groupName: _titleController.text,
            groupDescription: _descriptionController.text,
            groupId: widget.groupId,
          );

      if (group != null) {
        widget.btnController.success();
        Future.delayed(const Duration(seconds: 1), () {
          widget.btnController.reset();
        });
        _descriptionController.clear();
        _titleController.clear();
        if (!mounted) {
          return;
        }
        ref.invalidate(groupsProvider);
        ref.invalidate(latestGroupsProvider);
        ref.invalidate(groupProvider);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      CustomToast.show(
        message: e.toString().capitalize(),
        type: ToastType.error,
        context: context,
        gravity: ToastGravity.BOTTOM,
      );
      widget.btnController.error();
      Future.delayed(const Duration(seconds: 1), () {
        widget.btnController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomModal(
      onClose: (context) => Navigator.pop(context, false),
      child: Column(
        children: [
          Expanded(
            child: GroupInfosInput(
              titleController: _titleController,
              descriptionController: _descriptionController,
              title: "Edit Group",
              formKey: _formKey,
            ),
          ),
          LoadingButton(
            btnController: widget.btnController,
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await editGroup();
              }
            },
            text: "VALIDATE",
          ),
        ],
      ),
    );
  }
}
