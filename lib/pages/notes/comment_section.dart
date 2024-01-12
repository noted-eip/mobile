import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/providers/note_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/data/providers/utils/periodic_function_executor.dart';
import 'package:noted_mobile/utils/color.dart';
import 'package:openapi/openapi.dart';
import 'package:tuple/tuple.dart';

class CommentSection extends ConsumerStatefulWidget {
  const CommentSection({
    Key? key,
    required this.blockId,
    required this.blockContent,
  }) : super(key: key);

  final String blockId;
  final String blockContent;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentSectionState();
}

class _CommentSectionState extends ConsumerState<CommentSection> {
  late String groupId;
  late String noteId;
  late String userId;

  TextEditingController commentController = TextEditingController();

  FocusNode focusNode = FocusNode();

  final ScrollController _scrollController =
      ScrollController(initialScrollOffset: 3000);

  bool _isButtonDisabled = true;

  late bool internetStatus;

  PeriodicFunctionExecutor periodicFunctionExecutor =
      PeriodicFunctionExecutor();

  void refreshCommentList() {
    ref.invalidate(noteComments(Tuple3(groupId, noteId, widget.blockId)));
  }

  @override
  void initState() {
    super.initState();
    groupId = ref.read(groupIdProvider);
    noteId = ref.read(noteIdProvider);
    userId = ref.read(userProvider).id;

    periodicFunctionExecutor.start(
      refreshCommentList,
      const Duration(seconds: 5),
    );

    commentController.addListener(_checkText);
  }

  @override
  void dispose() {
    commentController.dispose();
    periodicFunctionExecutor.stop();
    super.dispose();
  }

  void _checkText() {
    setState(() {
      _isButtonDisabled = commentController.text.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<List<BlockComment>?> comments =
        ref.watch(noteComments(Tuple3(groupId, noteId, widget.blockId)));

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text('note.block.title'.tr()),
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.blockContent,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: comments.when(
                data: (data) {
                  if (data == null) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    if (data.isEmpty) {
                      return Center(
                        child: Text('note.block.empty'.tr()),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      itemBuilder: (context, index) {
                        bool isAuthor = userId == data[index].authorId;

                        if (isAuthor) {
                          return Container(
                            alignment: Alignment.centerRight,
                            margin: const EdgeInsets.only(
                              right: 0,
                              left: 64,
                            ),
                            child: CupertinoContextMenu.builder(
                              actions: [
                                CupertinoContextMenuAction(
                                  isDefaultAction: true,
                                  onPressed: () async {
                                    Navigator.pop(context);

                                    await ref
                                        .read(noteClientProvider)
                                        .removeComment(
                                          groupId: groupId,
                                          noteId: noteId,
                                          blockId: widget.blockId,
                                          commentId: data[index].id!,
                                        )
                                        .then((value) => ref.invalidate(
                                            noteComments(Tuple3(groupId, noteId,
                                                widget.blockId))));
                                  },
                                  child: Text(
                                    "note.block.delete".tr(),
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                )
                              ],
                              builder: (BuildContext context,
                                  Animation<double> animation) {
                                return Material(
                                  color: Colors.transparent,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    decoration: animation.value <
                                            CupertinoContextMenu
                                                .animationOpensAt
                                        ? const BoxDecoration(
                                            color: Colors.transparent,
                                          )
                                        : BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            color: Colors.transparent,
                                            boxShadow: CupertinoContextMenu
                                                .kEndBoxShadow,
                                          ),
                                    child: Material(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      color: Colors.transparent,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        decoration: BoxDecoration(
                                          color: NotedColors.tertiary,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          data[index].content!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        } else {
                          return Container(
                            alignment: Alignment.centerLeft,
                            margin: const EdgeInsets.only(
                              right: 64,
                              left: 0,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.transparent,
                                ),
                                child: Material(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  color: Colors.transparent,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      data[index].content!,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      itemCount: data.length,
                    );
                  }
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => Center(
                  child: Text(error.toString()),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                focusNode: focusNode,
                minLines: 1,
                maxLines: 3,
                controller: commentController,
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: IconButton(
                      color: NotedColors.primary,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          _isButtonDisabled ? Colors.grey : NotedColors.primary,
                        ),
                        shape: MaterialStateProperty.all(
                            const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(16),
                          ),
                        )),
                      ),
                      onPressed: _isButtonDisabled
                          ? null
                          : () async {
                              await ref.read(noteClientProvider).addComment(
                                    groupId: groupId,
                                    noteId: noteId,
                                    blockId: widget.blockId,
                                    comment: commentController.text,
                                    authorId: ref.read(userProvider).id,
                                  );
                              ref.invalidate(noteComments(
                                  Tuple3(groupId, noteId, widget.blockId)));

                              commentController.clear();

                              await Future.delayed(
                                  const Duration(milliseconds: 500), () {
                                _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOut,
                                );
                              });
                            },
                      icon: const Icon(
                        Icons.arrow_upward_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  hintText: "note.block.add-comment".tr(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
