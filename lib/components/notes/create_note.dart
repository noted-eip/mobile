import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:noted_mobile/components/common/custom_modal.dart';
import 'package:noted_mobile/components/common/custom_toast.dart';
import 'package:noted_mobile/components/common/loading_button.dart';
import 'package:noted_mobile/components/notes/note_info_input.dart';
import 'package:noted_mobile/data/notifiers/user_notifier.dart';
import 'package:noted_mobile/data/providers/note_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/utils/string_extension.dart';
import 'package:openapi/openapi.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:tuple/tuple.dart';

class CreateNoteModal extends ConsumerStatefulWidget {
  const CreateNoteModal({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateNoteModalState();
}

class _CreateNoteModalState extends ConsumerState<CreateNoteModal> {
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
  String buttonText = "Suivant";
  String selectedLang = "fr";

  Future<void> createNote(UserNotifier user, String? lang) async {
    if (_formKey.currentState!.validate()) {
      try {
        V1Note? note = await ref.read(noteClientProvider).createNote(
              groupId: groupId,
              title: _titleController.text,
              lang: lang ?? "fr",
            );

        if (note != null) {
          btnController.success();
          Future.delayed(const Duration(seconds: 1), () {
            btnController.reset();
            Navigator.pop(context);
            Navigator.pushNamed(context, "/note-detail",
                arguments: Tuple2(note.id, note.groupId));

            _descriptionController.clear();
            _titleController.clear();

            // ref.invalidate(la);
            ref.invalidate(notesProvider);
          });
        } else {
          print("note is null");
        }
      } catch (e) {
        print("catch failed to create note");
        if (kDebugMode) {
          print("Failed to create Note, Api response :${e.toString()}");
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

  @override
  Widget build(BuildContext context) {
    if (pages.isEmpty) {
      setState(() {
        pages.add(
          NoteInfosInput(
            formKey: _formKey,
            descriptionController: _descriptionController,
            titleController: _titleController,
            onLanguageSelected: (lang) {
              setState(() {
                selectedLang = lang;
              });
            },
            title: "my-notes.create-note-modal.title".tr(),
            onGroupSelected: (data) {
              setState(() {
                groupId = data;
              });
            },
          ),
        );
      });
    }

    final user = ref.read(userProvider);

    return CustomModal(
      height: 0.9,
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
                  buttonText = "Finish";
                });
              },
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
            ),
          ),
          LoadingButton(
            btnController: btnController,
            onPressed: () async => createNote(user, selectedLang),
            text: "my-notes.create-note-modal.button".tr(),
          ),
        ],
      ),
    );
  }
}
