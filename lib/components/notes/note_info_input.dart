import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/models/group/group.dart';
import 'package:noted_mobile/data/providers/group_provider.dart';
import 'package:noted_mobile/utils/theme_helper.dart';

typedef StringCallBack = void Function(String);

class NoteInfosInput extends ConsumerStatefulWidget {
  const NoteInfosInput(
      {required this.formKey,
      required this.descriptionController,
      required this.titleController,
      required this.title,
      required this.onGroupSelected,
      required this.onLanguageSelected,
      super.key});

  final String title;

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final StringCallBack onGroupSelected;
  final StringCallBack onLanguageSelected;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NoteInfosInputState();
}

class _NoteInfosInputState extends ConsumerState<NoteInfosInput> {
  int selectedGroupIndex = 0;
  int selectedLangIndex = 0;
  final TextEditingController _langController = TextEditingController();

  final List<String> langList = ["fr", "en"];

  final List<String> langListLabel = ["Français", "Anglais"];

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Group>?> groups = ref.watch(groupsProvider);

    return Column(
      children: [
        Text(
          widget.title,
          style: const TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 32,
        ),
        Form(
          key: widget.formKey,
          child: Column(
            children: [
              TextFormField(
                controller: widget.titleController,
                decoration: ThemeHelper().textInputDecoration(
                    'my-notes.create-note-modal.name-label'.tr(),
                    'my-notes.create-note-modal.name-hint'.tr()),
                validator: (val) {
                  if (val!.isEmpty) {
                    return "my-notes.create-note-modal.name-empty".tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30.0),
              TextFormField(
                enabled: groups.hasValue &&
                    groups.value != null &&
                    groups.value!.isNotEmpty,
                minLines: 1,
                maxLines: 1,
                controller: widget.descriptionController,
                decoration: ThemeHelper().textInputDecoration(
                    'my-notes.create-note-modal.group-label'.tr(),
                    'Choose a group for your note'),
                validator: (val) {
                  if (val!.isEmpty) {
                    return 'my-notes.create-note-modal.group-empty'.tr();
                  }
                  return null;
                },
                onTap: () {
                  if (groups.hasValue &&
                      groups.value != null &&
                      groups.value!.isNotEmpty) {
                    if (widget.descriptionController.text.isEmpty) {
                      //TODO: check si les groupes sont vides

                      widget.descriptionController.text =
                          groups.value!.elementAt(0).data.name;
                      widget
                          .onGroupSelected(groups.value!.elementAt(0).data.id);
                    }

                    showCupertinoModalPopup(
                      context: context,
                      builder: (context) {
                        return Container(
                          height: 216,
                          padding: const EdgeInsets.only(top: 6.0),
                          // The Bottom margin is provided to align the popup above the system navigation bar.
                          margin: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          // Provide a background color for the popup.
                          color: CupertinoColors.systemBackground
                              .resolveFrom(context),
                          // Use a SafeArea widget to avoid system overlaps.
                          child: SafeArea(
                            top: false,
                            child: CupertinoPicker(
                              magnification: 1.22,
                              squeeze: 1.2,
                              useMagnifier: true,
                              itemExtent: 32.0,
                              // This sets the initial item.
                              scrollController: FixedExtentScrollController(
                                initialItem: selectedGroupIndex,
                              ),
                              // This is called when selected item is changed.
                              onSelectedItemChanged: (int selectedItem) {
                                setState(() {
                                  selectedGroupIndex = selectedItem;
                                });
                                var selectedGroupId = groups.value!
                                    .elementAt(selectedItem)
                                    .data
                                    .id;
                                widget.onGroupSelected(selectedGroupId);
                                widget.descriptionController.text = groups
                                    .value!
                                    .elementAt(selectedItem)
                                    .data
                                    .name;
                              },
                              children: List<Widget>.from(
                                groups.value!.map(
                                  (Group group) {
                                    return Center(
                                      child: Text(group.data.name),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
              const SizedBox(height: 30.0),
              TextFormField(
                enabled: true,
                minLines: 1,
                maxLines: 1,
                controller: _langController,
                decoration: ThemeHelper().textInputDecoration(
                    'Langue', 'Choisissez une langue pour votre note'),
                validator: (val) {
                  if (val!.isEmpty) {
                    return 'Vous devez choisir une langue';
                  }
                  return null;
                },
                onTap: () {
                  widget.onLanguageSelected(langList[selectedLangIndex]);
                  _langController.text = langListLabel[selectedLangIndex];
                  showCupertinoModalPopup(
                    context: context,
                    builder: (context) {
                      return Container(
                        height: 216,
                        padding: const EdgeInsets.only(top: 6.0),
                        // The Bottom margin is provided to align the popup above the system navigation bar.
                        margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        // Provide a background color for the popup.
                        color: CupertinoColors.systemBackground
                            .resolveFrom(context),
                        // Use a SafeArea widget to avoid system overlaps.
                        child: SafeArea(
                          top: false,
                          child: CupertinoPicker(
                            magnification: 1.22,
                            squeeze: 1.2,
                            useMagnifier: true,
                            itemExtent: 32.0,
                            // This sets the initial item.
                            scrollController: FixedExtentScrollController(
                              initialItem: selectedLangIndex,
                            ),
                            // This is called when selected item is changed.
                            onSelectedItemChanged: (int selectedItem) {
                              setState(() {
                                selectedLangIndex = selectedItem;
                              });

                              widget.onLanguageSelected(
                                  langList[selectedLangIndex]);

                              _langController.text =
                                  langListLabel[selectedLangIndex];
                            },
                            children: List<Widget>.from(
                              langList.map(
                                (lang) {
                                  return Center(
                                    child: Text(lang),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
