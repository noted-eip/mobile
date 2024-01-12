import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/common/custom_modal.dart';
import 'package:noted_mobile/components/dialog/custom_dialog.dart';
import 'package:noted_mobile/components/invites/pending_invite.dart';
import 'package:noted_mobile/components/notes/create_note.dart';
import 'package:noted_mobile/data/providers/group_provider.dart';
import 'package:noted_mobile/data/providers/invite_provider.dart';
import 'package:noted_mobile/utils/color.dart';
import 'package:noted_mobile/utils/language.dart';
import 'package:openapi/openapi.dart';

enum ActionButton { addNote, invite }

class GroupActionButton extends ConsumerStatefulWidget {
  const GroupActionButton({
    Key? key,
    required this.controller,
    required this.isWorkspace,
    required this.group,
    this.inviteMember,
  }) : super(key: key);

  final TabController controller;
  final bool isWorkspace;
  final V1Group group;

  final Function(String)? inviteMember;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GroupActionButtonState();
}

class _GroupActionButtonState extends ConsumerState<GroupActionButton> {
  Color actionButtonColor = NotedColors.primary;
  bool showButton = true;
  IconData actionButtonIcon = Icons.add;
  ActionButton actionButton = ActionButton.addNote;

  @override
  void initState() {
    widget.controller.addListener(updateButton);

    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(updateButton);

    super.dispose();
  }

  void updateButton() {
    int index = widget.controller.index;
    bool isWorkspace = widget.isWorkspace;
    if (index == 0) {
      updateColor(NotedColors.primary);
      updateVisibility(true);
      updateIcon(Icons.add);
      udpateActionButton(ActionButton.addNote);
    } else if (index == 1 && !isWorkspace) {
      updateVisibility(true);
      updateColor(Colors.grey.shade900);
      updateIcon(Icons.inbox_outlined);
      udpateActionButton(ActionButton.invite);
    } else if (index == 2 && !isWorkspace || index == 1 && isWorkspace) {
      updateVisibility(false);
      ref.invalidate(groupActivitiesProvider(widget.group.id));
    }
  }

  void updateColor(Color color) {
    setState(() {
      actionButtonColor = color;
    });
  }

  void updateVisibility(bool visibility) {
    setState(() {
      showButton = visibility;
    });
  }

  void updateIcon(IconData icon) {
    setState(() {
      actionButtonIcon = icon;
    });
  }

  void udpateActionButton(ActionButton actionButton) {
    setState(() {
      this.actionButton = actionButton;
    });
  }

  Future<void> addNote() async {
    var lang = await LanguagePreferences.getLanguageCode();

    if (!context.mounted) {
      return;
    }

    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return CreateNoteModal(
          initialLang: lang,
          group: widget.group,
        );
      },
    );
  }

  Future<void> invite() async {
    ref.invalidate(groupInvitesProvider(widget.group.id));

    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return CustomModal(
          height: 0.85,
          // iconButton: IconButton(
          //   icon: const Icon(Icons.add),
          //   onPressed: () => widget.inviteMember?.call(),
          // ),
          iconButton: TextButton(
            onPressed: () async {
              if (Platform.isIOS) {
                await showCupertinoDialog(
                  context: context,
                  builder: (context) => CustomDialogWidget(
                    onSubmited: (p0) {
                      widget.inviteMember?.call(p0);
                      ref.invalidate(groupInvitesProvider(widget.group.id));
                      ref.invalidate(groupInvitesProvider);
                      // setState(() {
                      //   members.add(p0);
                      // });
                    },
                  ),
                );
              } else {
                await showDialog(
                  context: context,
                  builder: (context) => CustomDialogWidget(
                    onSubmited: (p0) {
                      widget.inviteMember?.call(p0);
                      ref.invalidate(groupInvitesProvider(widget.group.id));
                      ref.invalidate(groupInvitesProvider);
                      // setState(() {
                      //   members.add(p0);
                      // });
                    },
                  ),
                );
              }
            },
            child: Text(
              "${"dialog.add_members".tr()} +",
              textAlign: TextAlign.start,
            ),
          ),
          child: ListInvitesWidget(
            group: widget.group,
          ),
          onClose: (context2) {
            Navigator.pop(context2, false);
          },
        );
      },
    );
  }

  void selectAction() async {
    switch (actionButton) {
      case ActionButton.addNote:
        await addNote();
        break;
      case ActionButton.invite:
        await invite();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return !showButton
        ? const SizedBox.shrink()
        : FloatingActionButton(
            backgroundColor: actionButtonColor,
            onPressed: selectAction,
            child: Icon(
              actionButtonIcon,
              color: Colors.white,
            ),
          );
  }
}
