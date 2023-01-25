import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/common/custom_modal.dart';
import 'package:noted_mobile/data/models/group/group.dart';
import 'package:noted_mobile/data/providers/group_provider.dart';
import 'package:noted_mobile/utils/theme_helper.dart';
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
            _titleController.text,
            _descriptionController.text,
            widget.userTkn,
            widget.groupId,
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
      widget.btnController.error();
      Future.delayed(const Duration(seconds: 1), () {
        widget.btnController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget page1 = Column(
      children: [
        const Text(
          "Edit Group",
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 32,
        ),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: ThemeHelper()
                    .textInputDecoration('Group Title', 'Enter a Title'),
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Please enter a Title";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30.0),
              TextFormField(
                minLines: 3,
                maxLines: 3,
                controller: _descriptionController,
                decoration: ThemeHelper().textInputDecoration(
                    'Group Description', 'Enter a Description'),
                validator: (val) {
                  if (val!.isEmpty) {
                    return 'Please enter a Description';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ],
    );

    return CustomModal(
      onClose: (context) => Navigator.pop(context, false),
      child: Column(
        children: [
          Expanded(
            child: page1,
          ),
          RoundedLoadingButton(
            color: Colors.grey.shade900,
            errorColor: Colors.redAccent,
            successColor: Colors.green.shade900,
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await editGroup();
              }
            },
            controller: widget.btnController,
            width: MediaQuery.of(context).size.width,
            borderRadius: 16,
            child: const Text(
              "VALIDATE",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
