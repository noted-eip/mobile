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
      super.key});

  final String title;

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final StringCallBack onGroupSelected;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NoteInfosInputState();
}

class _NoteInfosInputState extends ConsumerState<NoteInfosInput> {
  int selectedGroupIndex = 0;

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
                decoration: ThemeHelper()
                    .textInputDecoration('Note Title', 'Enter a Title'),
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Please enter a Title";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30.0),
              TextFormField(
                // enabled: false,
                minLines: 1,
                maxLines: 1,
                controller: widget.descriptionController,
                decoration: ThemeHelper().textInputDecoration(
                    'Group', 'Choose a group for your note'),
                validator: (val) {
                  if (val!.isEmpty) {
                    return 'Please enter a Description';
                  }
                  return null;
                },
                onTap: () {
                  if (groups.hasValue && groups.value != null) {
                    if (widget.descriptionController.text.isEmpty) {
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
            ],
          ),
        ),
      ],
    );
  }
}
