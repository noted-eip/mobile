import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/providers/note_provider.dart';
import 'package:openapi/openapi.dart';
import 'package:tuple/tuple.dart';

class GroupActivityCard extends ConsumerStatefulWidget {
  const GroupActivityCard({
    super.key,
    required this.groupActivity,
    required this.groupId,
  });

  final V1GroupActivity groupActivity;
  final String groupId;

  @override
  ConsumerState<GroupActivityCard> createState() => _GroupActivityCardState();
}

class _GroupActivityCardState extends ConsumerState<GroupActivityCard> {
  String getGroupActivityType(V1GroupActivity groupActivity) {
    if (groupActivity.type == "ADD-NOTE") {
      return "added a new note";
    } else if (groupActivity.type == "ADD-MEMBER") {
      return "added a new member";
    } else if (groupActivity.type == "REMOVE-MEMBER") {
      return "removed a member";
    }
    return "";
  }

  String? extractUserId(String input) {
    final regex = RegExp(r"<userID:(.*?)>");
    final match = regex.firstMatch(input);
    return match?.group(1);
  }

  String? extractNoteId(String input) {
    final regex = RegExp(r"<noteID:(.*?)>");
    final match = regex.firstMatch(input);
    return match?.group(1);
  }

  String? extractFolderId(String input) {
    final regex = RegExp(r"<folderID:(.*?)>");
    final match = regex.firstMatch(input);
    return match?.group(1);
  }

  @override
  Widget build(BuildContext context) {
    final noteId = extractNoteId(widget.groupActivity.event);

    Tuple2<String, String> infos = Tuple2(
      noteId ?? "",
      widget.groupId,
    );

    final note = ref.read(noteProvider(infos));

    return Container(
      child: Column(
        children: [],
      ),
    );
  }
}
