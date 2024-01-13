import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:noted_mobile/components/common/custom_modal.dart';
import 'package:noted_mobile/components/common/custom_toast.dart';
import 'package:noted_mobile/components/common/loading_button.dart';
import 'package:noted_mobile/components/notes/note_info_input.dart';
import 'package:noted_mobile/data/models/group/group.dart';
import 'package:noted_mobile/data/notifiers/user_notifier.dart';
import 'package:noted_mobile/data/providers/note_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/utils/string_extension.dart';
import 'package:openapi/openapi.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:tuple/tuple.dart';

class CreateNoteModal extends ConsumerStatefulWidget {
  const CreateNoteModal({
    Key? key,
    required this.initialLang,
    this.group,
    this.groupsList,
  }) : super(key: key);

  final V1Group? group;
  final String initialLang;
  final List<Group>? groupsList;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateNoteModalState();
}

class _CreateNoteModalState extends ConsumerState<CreateNoteModal> {
  final TextEditingController controller = TextEditingController();
  final roleformKey = GlobalKey<FormState>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();
  String groupId = "";
  late String selectedLang;

  @override
  void initState() {
    super.initState();
    if (widget.group != null) {
      groupId = widget.group!.id;
    } else {
      groupId = widget.groupsList!.first.data.id;
    }
    selectedLang = widget.initialLang;
  }

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

            _titleController.clear();

            ref.invalidate(notesProvider);
            ref.invalidate(groupNotesProvider(groupId));
          });
        }
      } catch (e) {
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
    final user = ref.read(userProvider);

    return CustomModal(
      height: 0.9,
      onClose: (context) => Navigator.pop(context, false),
      child: Column(
        children: [
          Expanded(
            child: NoteInfosInput(
              formKey: _formKey,
              titleController: _titleController,
              initialLang: selectedLang,
              initialGroup: widget.group,
              groupsList: widget.groupsList,
              onLanguageSelected: (lang) {
                setState(() {
                  selectedLang = lang;
                });
              },
              title: "my-notes.create-note-modal.title".tr(),
              onGroupSelected: (data) {
                if (widget.group != null) {
                  return;
                }
                setState(() {
                  groupId = data;
                });
              },
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
