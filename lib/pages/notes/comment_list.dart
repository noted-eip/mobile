import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/providers/note_provider.dart';
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

  @override
  void initState() {
    super.initState();
    groupId = ref.read(groupIdProvider);
    noteId = ref.read(noteIdProvider);
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<List<V1Block>?> blockList = ref.watch(blocksWithCommentsProvider(
      Tuple2(groupId, noteId),
    ));

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text('Comment List'),
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
                return const Center(
                  child: Text('No comments'),
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
                          title: Text(getBlockTextFromV1Block(data[index])),
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
