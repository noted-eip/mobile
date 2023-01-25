import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/common/custom_modal.dart';
import 'package:noted_mobile/components/group_info_input.dart';
import 'package:noted_mobile/components/invite_member.dart';
import 'package:noted_mobile/data/models/group/group.dart';
import 'package:noted_mobile/data/providers/group_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class CreateGroupModal extends ConsumerStatefulWidget {
  const CreateGroupModal({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateGroupModalState();
}

class _CreateGroupModalState extends ConsumerState<CreateGroupModal> {
  final TextEditingController controller = TextEditingController();
  final roleformKey = GlobalKey<FormState>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();
  List<Widget> pages = [];
  String groupId = "";
  PageController pageController = PageController(initialPage: 0);
  int pageIndex = 0;
  String buttonText = "Next";

  @override
  Widget build(BuildContext context) {
    if (pages.isEmpty) {
      setState(() {
        pages.add(
          GroupInfosInput(
              formKey: _formKey,
              descriptionController: _descriptionController,
              titleController: _titleController),
        );
      });
    }

    final user = ref.read(userProvider);

    return CustomModal(
      onClose: (context) => Navigator.pop(context, false),
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemBuilder: (context, index) {
                if (index < pages.length) {
                  return pages[index];
                }
                return Container();
              },
              onPageChanged: (value) {
                setState(() {
                  pageIndex = value;
                  if (pageIndex == 1) {
                    buttonText = "Finish";
                  } else {
                    buttonText = "Next";
                  }
                });
              },
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
            ),
          ),
          RoundedLoadingButton(
            color: Colors.grey.shade900,
            errorColor: Colors.redAccent,
            successColor: Colors.green.shade900,
            onPressed: () async {
              if (pageIndex == 0) {
                if (_formKey.currentState!.validate()) {
                  try {
                    Group? group = await ref
                        .read(groupClientProvider)
                        .createGroup(_titleController.text,
                            _descriptionController.text, user.token);
                    if (group != null) {
                      setState(() {
                        groupId = group.data.id;
                        pages.add(
                          InviteMemberWidget(
                            controller: controller,
                            formKey: roleformKey,
                            groupId: groupId,
                          ),
                        );
                      });
                      btnController.success();
                      Future.delayed(const Duration(seconds: 1), () {
                        btnController.reset();
                        pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn);
                        _descriptionController.clear();
                        _titleController.clear();

                        ref.invalidate(groupsProvider);
                        ref.invalidate(latestGroupsProvider);
                      });
                    }
                  } catch (e) {
                    if (kDebugMode) {
                      print(
                          "Failed to create Group, Api response :${e.toString()}");
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
              } else if (pageIndex == 1) {
                Navigator.pop(context);
              }
            },
            controller: btnController,
            width: MediaQuery.of(context).size.width,
            borderRadius: 16,
            child: Text(
              buttonText.toUpperCase(),
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
