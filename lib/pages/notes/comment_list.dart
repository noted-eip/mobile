import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/providers/note_provider.dart';
import 'package:noted_mobile/data/providers/utils/periodic_function_executor.dart';
import 'package:noted_mobile/pages/notes/comment_section.dart';
import 'package:noted_mobile/pages/notes/editor/note_utility.dart';
import 'package:openapi/openapi.dart';
import 'package:tuple/tuple.dart';

class CommentList extends ConsumerStatefulWidget {
  const CommentList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentListState();
}

class _CommentListState extends ConsumerState<CommentList> {
  late String groupId;
  late String noteId;

  PeriodicFunctionExecutor periodicFunctionExecutor =
      PeriodicFunctionExecutor();

  void refreshBlockList() {
    ref.invalidate(blocksWithCommentsProvider(Tuple2(groupId, noteId)));
  }

  @override
  void initState() {
    super.initState();
    periodicFunctionExecutor.start(
      refreshBlockList,
      const Duration(seconds: 20),
    );
    groupId = ref.read(groupIdProvider);
    noteId = ref.read(noteIdProvider);
  }

  @override
  void dispose() {
    periodicFunctionExecutor.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<List<V1Block>?> blockList = ref.watch(blocksWithCommentsProvider(
      Tuple2(groupId, noteId),
    ));

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text("note.comments".tr()),
      ),
      body: SafeArea(
        child: blockList.when(
          data: (data) {
            if (data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (data.isEmpty) {
                return Center(
                  child: Text('note.no-comments'.tr()),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CommentSection(
                              blockId: data[index].id,
                              blockContent:
                                  getBlockTextFromV1Block(data[index]),
                            ),
                          ),
                        );
                      },
                      child: Card(
                        child: ListTile(
                          title: Text(
                            getBlockTextFromV1Block(data[index]),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          },
          error: (error, stack) {
            return Center(
              child: Text(error.toString()),
            );
          },
          loading: () {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
