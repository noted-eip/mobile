import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/common/loading_button.dart';
import 'package:noted_mobile/components/groups/group_detail_header_menu.dart';
import 'package:noted_mobile/utils/string_extension.dart';
import 'package:openapi/openapi.dart';

class GroupDetailHeader extends ConsumerStatefulWidget {
  const GroupDetailHeader({
    required this.group,
    required this.deleteGroup,
    required this.leaveGroup,
    super.key,
  });

  final V1Group group;

  final AsyncCallBack leaveGroup;
  final AsyncCallBack deleteGroup;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GroupDetailHeaderState();
}

class _GroupDetailHeaderState extends ConsumerState<GroupDetailHeader> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: AutoSizeText(
            widget.group.name == "My Workspace"
                ? "menu.workspace".tr()
                : widget.group.name.capitalize(),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        if (widget.group.workspaceAccountId == null ||
            (widget.group.workspaceAccountId != null &&
                widget.group.workspaceAccountId!.isEmpty))
          GroupHeaderMenu(
            group: widget.group,
            deleteGroup: widget.deleteGroup,
            leaveGroup: widget.leaveGroup,
          ),
      ],
    );
  }
}
