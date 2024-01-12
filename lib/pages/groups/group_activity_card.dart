import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/common/custom_slide.dart';
import 'package:noted_mobile/data/models/account/account.dart';
import 'package:noted_mobile/data/providers/account_provider.dart';
import 'package:noted_mobile/data/providers/note_provider.dart';
import 'package:openapi/openapi.dart';
import 'package:tuple/tuple.dart';

enum GroupActivityType {
  addNote,
  removeMember,
  addMember,
  unknown,
}

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
  GroupActivityType getGroupActivityType(V1GroupActivity groupActivity) {
    if (groupActivity.type == "ADD-NOTE") {
      return GroupActivityType.addNote;
    } else if (groupActivity.type == "ADD-MEMBER") {
      return GroupActivityType.addMember;
    } else if (groupActivity.type == "REMOVE-MEMBER") {
      return GroupActivityType.removeMember;
    }
    return GroupActivityType.unknown;
  }

  IconData getIcon(GroupActivityType type) {
    switch (type) {
      case GroupActivityType.addNote:
        return Icons.note_add;
      case GroupActivityType.addMember:
        return Icons.person_add;
      case GroupActivityType.removeMember:
        return Icons.person_remove;
      default:
        return Icons.error;
    }
  }

  String getDateToString(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
  }

  String getTitleFromEvent(String event) {
    final type = getGroupActivityType(widget.groupActivity);

    switch (type) {
      case GroupActivityType.addNote:
        return "group-detail.activity.add-note".tr();
      case GroupActivityType.addMember:
        return "group-detail.activity.add-member".tr();
      case GroupActivityType.removeMember:
        return "group-detail.activity.remove-member".tr();
      default:
        return "group-detail.activity.unknown".tr();
    }
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

  @override
  Widget build(BuildContext context) {
    final noteId = extractNoteId(widget.groupActivity.event);
    final userId = extractUserId(widget.groupActivity.event);

    final GroupActivityType type = getGroupActivityType(widget.groupActivity);
    if (userId == null || noteId == null) {
      return _buildListTile(null, null, type);
    }

    Tuple2<String, String> infos = Tuple2(
      noteId,
      widget.groupId,
    );

    AsyncValue<V1Note?> note = ref.watch(noteProvider(infos));
    AsyncValue<Account?> user = ref.watch(accountProvider(userId));

    return user.when(
      data: (user) {
        return note.when(
          data: (note) {
            return _buildListTile(user, note, type);
          },
          loading: () => _buildListTile(user, null, type),
          error: (error, stack) => _buildListTile(user, null, type),
        );
      },
      loading: () => Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: CustomSlide(
          color: Colors.purple.shade900,
          actions: null,
          titleWidget: SizedBox(
            height: 20,
            width: 100,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          withWidget: true,
          avatarWidget: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            height: 40,
            width: 40,
            child: Icon(
              getIcon(type),
              color: Colors.white,
            ),
          ),
        ),
      ),
      error: (error, stack) => const SizedBox(),
    );
  }

  _buildListTile(Account? user, V1Note? note, GroupActivityType type) {
    String title = "";

    if (type == GroupActivityType.addNote) {
      if (user != null && note != null) {
        title =
            "${user.data.name}${getTitleFromEvent(widget.groupActivity.event)}${note.title}.";
      }
    } else if (type == GroupActivityType.addMember ||
        type == GroupActivityType.removeMember) {
      if (user != null) {
        title =
            "${user.data.name}${getTitleFromEvent(widget.groupActivity.event)}";
      }
    }

    if (title.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: CustomSlide(
        color: Colors.purple.shade900,
        onTap: () {
          if (type == GroupActivityType.addNote && note != null) {
            Navigator.pushNamed(context, "/note-detail",
                arguments: Tuple2(note.id, note.groupId));
          }
        },
        actions: null,
        titleWidget: Text(
          title,
          maxLines: 2,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
        withWidget: true,
        avatarWidget: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          height: 40,
          width: 40,
          child: Icon(
            getIcon(type),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
