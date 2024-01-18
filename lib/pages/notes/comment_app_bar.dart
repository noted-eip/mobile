import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:noted_mobile/components/common/custom_alerte.dart';
import 'package:noted_mobile/components/common/custom_toast.dart';
import 'package:noted_mobile/data/providers/group_provider.dart';
import 'package:noted_mobile/data/providers/note_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/pages/notes/comment_list.dart';
import 'package:noted_mobile/utils/color.dart';
import 'package:openapi/openapi.dart';
import 'package:tuple/tuple.dart';

class CommentSectionAppBar extends ConsumerStatefulWidget {
  const CommentSectionAppBar({
    Key? key,
    required this.note,
    required this.infos,
    required this.isReadOnly,
    required this.onCommentChanged,
  }) : super(key: key);

  final V1Note note;
  final Tuple2<String, String> infos;
  final bool isReadOnly;
  final VoidCallback onCommentChanged;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CommentSectionAppBarState();
}

class _CommentSectionAppBarState extends ConsumerState<CommentSectionAppBar> {
  Future<void> deleteNoteDialog(WidgetRef ref) async {
    return await showDialog(
      context: context,
      builder: ((context) {
        return CustomAlertDialog(
          title: "pop-up.delete-note.title".tr(),
          content: "pop-up.delete-note.description".tr(),
          onConfirm: () async {
            await ref.read(noteClientProvider).deleteNote(
                  noteId: widget.infos.item1,
                  groupId: widget.infos.item2,
                );

            ref.invalidate(groupNotesProvider(widget.infos.item2));
            ref.invalidate(notesProvider);
            if (!mounted) {
              return;
            }
            CustomToast.show(
              message: "pop-up.delete-note.success".tr(),
              type: ToastType.success,
              context: context,
              gravity: ToastGravity.BOTTOM,
            );
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(workspaceProvider);
    var userId = ref.read(userProvider).id;

    return workspace.when(
      data: (workspace) {
        bool isWorkspace = workspace?.data.id == widget.note.groupId;

        return Row(
          children: [
            if (widget.note.authorAccountId == userId && !isWorkspace)
              IconButton(
                onPressed: widget.onCommentChanged,
                icon: Icon(
                  widget.isReadOnly ? Icons.comment : Icons.comments_disabled,
                  color: NotedColors.primary,
                ),
              ),
            PopupMenuButton(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(16),
                ),
              ),
              itemBuilder: (context) => [
                if (userId == widget.note.authorAccountId) ...[
                  PopupMenuItem(
                    child: ListTile(
                      leading: const Icon(Icons.delete),
                      title: Text("note.delete".tr()),
                    ),
                    onTap: () async {
                      await deleteNoteDialog(ref);
                      if (mounted) {
                        ref.invalidate(groupNotesProvider(widget.infos.item2));
                        ref.invalidate(notesProvider);

                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  if (!isWorkspace)
                    PopupMenuItem(
                      child: ListTile(
                        leading: const Icon(Icons.comment),
                        title: Text("note.comments".tr()),
                      ),
                      onTap: () async {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return const CommentList();
                            },
                          ),
                        );
                      },
                    ),
                ],
              ],
            ),
          ],
        );
      },
      error: (error, stackTrace) {
        return PopupMenuButton(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
          ),
          itemBuilder: (context) => [
            if (userId == widget.note.authorAccountId) ...[
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.delete),
                  title: Text("note.delete".tr()),
                ),
                onTap: () async {
                  await deleteNoteDialog(ref);
                  if (mounted) {
                    ref.invalidate(groupNotesProvider(widget.infos.item2));
                    ref.invalidate(notesProvider);

                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
    );
  }
}
