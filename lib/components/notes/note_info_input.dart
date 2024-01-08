import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/models/group/group.dart';
import 'package:noted_mobile/utils/color.dart';
import 'package:noted_mobile/utils/language.dart';
import 'package:noted_mobile/utils/theme_helper.dart';
import 'package:openapi/openapi.dart';

typedef StringCallBack = void Function(String);

class NoteInfosInput extends ConsumerStatefulWidget {
  const NoteInfosInput({
    required this.formKey,
    required this.titleController,
    required this.title,
    required this.onGroupSelected,
    required this.onLanguageSelected,
    required this.initialLang,
    this.initialGroup,
    this.groupsList,
    super.key,
  });

  final String title;

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final StringCallBack onGroupSelected;
  final StringCallBack onLanguageSelected;
  final String initialLang;
  final V1Group? initialGroup;
  final List<Group>? groupsList;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NoteInfosInputState();
}

class _NoteInfosInputState extends ConsumerState<NoteInfosInput> {
  int selectedGroupIndex = 0;
  late int selectedLangIndex;

  @override
  void initState() {
    selectedLangIndex = LanguagePreferences.languages
        .indexWhere((element) => element.languageCode == widget.initialLang);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
              if ((widget.groupsList != null &&
                      widget.groupsList!.isNotEmpty) &&
                  widget.initialGroup == null) ...[
                GestureDetector(
                  onTap: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (context) {
                        return Container(
                          height: 216,
                          padding: const EdgeInsets.only(top: 6.0),
                          margin: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          color: CupertinoColors.systemBackground
                              .resolveFrom(context),
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
                                var selectedGroupId = widget.groupsList!
                                    .elementAt(selectedItem)
                                    .data
                                    .id;
                                widget.onGroupSelected(selectedGroupId);
                              },
                              children: List<Widget>.from(
                                widget.groupsList!.map(
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
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.groupsList!
                                  .elementAt(selectedGroupIndex)
                                  .data
                                  .name,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: -10,
                        left: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          color: Colors.white,
                          child: Text(
                            'my-notes.create-note-modal.group-label'.tr(),
                            style: const TextStyle(
                              color: NotedColors.primary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 30.0),
              GestureDetector(
                onTap: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (context) {
                      return Container(
                        height: 216,
                        padding: const EdgeInsets.only(top: 6.0),
                        margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        color: CupertinoColors.systemBackground
                            .resolveFrom(context),
                        child: SafeArea(
                          top: false,
                          child: CupertinoPicker(
                            magnification: 1.22,
                            squeeze: 1.2,
                            useMagnifier: true,
                            itemExtent: 32.0,
                            scrollController: FixedExtentScrollController(
                              initialItem: selectedLangIndex,
                            ),
                            onSelectedItemChanged: (int selectedItem) {
                              setState(() {
                                selectedLangIndex = selectedItem;
                              });

                              widget.onLanguageSelected(LanguagePreferences
                                  .languageNameMap.keys
                                  .elementAt(selectedLangIndex));
                            },
                            children: List<Widget>.from(
                              LanguagePreferences.languageNameMap.keys
                                  .map((key) {
                                return SizedBox(
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        LanguagePreferences
                                            .languageNameMap[key]!,
                                      ),
                                      Text(
                                        LanguagePreferences
                                            .languageFlagMap[key]!,
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ).toList(),
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            LanguagePreferences.languageNameMap.values
                                .elementAt(selectedLangIndex),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            LanguagePreferences.languageFlagMap.values
                                .elementAt(selectedLangIndex),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: -10,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        color: Colors.white,
                        child: const Text(
                          "Langue",
                          style: TextStyle(
                            color: NotedColors.primary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30.0),
            ],
          ),
        ),
      ],
    );
  }
}
