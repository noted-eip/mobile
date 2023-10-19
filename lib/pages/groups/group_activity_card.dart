import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/models/account/account.dart';
import 'package:noted_mobile/data/providers/account_provider.dart';
import 'package:openapi/openapi.dart';

//TODO: Add a way to get the note from the group activity

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
        return " a ajouté la note ";
      case GroupActivityType.addMember:
        return " a rejoint le groupe";
      case GroupActivityType.removeMember:
        return " a quitté le groupe";
      default:
        return "Erreur";
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
    // final noteId = extractNoteId(widget.groupActivity.event) ?? "";
    final userId = extractUserId(widget.groupActivity.event) ?? "";

    final GroupActivityType type = getGroupActivityType(widget.groupActivity);

    // Tuple2<String, String> infos = Tuple2(
    //   noteId,
    //   widget.groupId,
    // );

    // final note = ref.watch(noteProvider(infos));
    final user = ref.watch(accountProvider(userId));

    return user.when(
      data: (user) {
        if (user == null) {
          return _buildListTile(null, null, type);
        }

        // note.when(
        //   data: (note) {
        //     if (note == null) {
        //       return _buildListTile(user, null, type);
        //     }
        //     return _buildListTile(user, note, type);
        //   },
        //   loading: () => const CircularProgressIndicator(),
        //   error: (error, stack) => const Text("Erreur"),
        // );

        return _buildListTile(user, null, type);
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => const Text("Erreur"),
    );
  }

  _buildListTile(Account? user, V1Note? note, GroupActivityType type) {
    String title = "";

    if (type == GroupActivityType.addNote) {
      if (user != null && note != null) {
        title =
            "${user.data.name}${getTitleFromEvent(widget.groupActivity.event)}${note.title}.";
      } else if (user != null && note == null) {
        title =
            "${user.data.name}${getTitleFromEvent(widget.groupActivity.event)} ...";
      } else if (user == null && note != null) {
        title =
            "...${getTitleFromEvent(widget.groupActivity.event)}${note.title}.";
      } else {
        title = "...${getTitleFromEvent(widget.groupActivity.event)}...";
      }
    } else if (type == GroupActivityType.addMember ||
        type == GroupActivityType.removeMember) {
      if (user != null) {
        title =
            "${user.data.name}${getTitleFromEvent(widget.groupActivity.event)}";
      } else {
        title = "...${getTitleFromEvent(widget.groupActivity.event)}";
      }
    } else {
      title = "Erreur";
    }

    return ListTile(
      contentPadding: const EdgeInsets.all(8.0),
      leading: Icon(
        getIcon(type),
        color: Colors.deepPurpleAccent,
      ),
      title: Text(
        title,
        maxLines: 2,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16.0,
        ),
      ),
      subtitle: Text(
        getDateToString(widget.groupActivity.createdAt),
        style: const TextStyle(
          fontStyle: FontStyle.italic,
          fontSize: 14.0,
        ),
      ),
    );
  }

  // _buildListTile(Account? user, Note? note, GroupActivityType type) {
  //   String title = "";

  //   if (type == GroupActivityType.addNote) {
  //     if (user != null && note != null) {
  //       title =
  //           "${user.data.name}${getTitleFromEvent(widget.groupActivity.event)}${note.title}.";
  //     } else if (user != null && note == null) {
  //       title =
  //           "${user.data.name}${getTitleFromEvent(widget.groupActivity.event)} ...";
  //     } else if (user == null && note != null) {
  //       title =
  //           "...${getTitleFromEvent(widget.groupActivity.event)}${note.title}.";
  //     } else {
  //       title = "...${getTitleFromEvent(widget.groupActivity.event)}...";
  //     }
  //   } else if (type == GroupActivityType.addMember ||
  //       type == GroupActivityType.removeMember) {
  //     if (user != null) {
  //       title =
  //           "${user.data.name}${getTitleFromEvent(widget.groupActivity.event)}";
  //     } else {
  //       title = "...${getTitleFromEvent(widget.groupActivity.event)}";
  //     }
  //   } else {
  //     title = "Erreur";
  //   }

  //   return ListTile(
  //     contentPadding: const EdgeInsets.all(8.0),
  //     leading: Icon(
  //       getIcon(type),
  //       color: Colors.deepPurpleAccent,
  //     ),
  //     title: Text(
  //       title,
  //       maxLines: 2,
  //       style: const TextStyle(
  //         fontWeight: FontWeight.bold,
  //         fontSize: 16.0,
  //       ),
  //     ),
  //     subtitle: Text(
  //       getDateToString(widget.groupActivity.createdAt),
  //       style: const TextStyle(
  //         fontStyle: FontStyle.italic,
  //         fontSize: 14.0,
  //       ),
  //     ),
  //   );
  // }
}
