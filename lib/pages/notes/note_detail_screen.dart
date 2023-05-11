import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/common/base_container.dart';
import 'package:noted_mobile/data/models/note/note.dart';
import 'package:noted_mobile/data/models/note/note_block.dart';
import 'package:noted_mobile/data/providers/note_provider.dart';
import 'package:tuple/tuple.dart';

class NoteDetail extends ConsumerStatefulWidget {
  const NoteDetail({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NoteDetailState();
}

class _NoteDetailState extends ConsumerState<NoteDetail> {
  Widget _buildBlocks(Note note) {
    List<Widget> blocks = [];
    if (note.blocks != null) {
      for (var block in note.blocks!) {
        switch (block.type) {
          case BlockType.heading1:
            {
              blocks.add(
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    block.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
              blocks.add(const SizedBox(height: 16));
            }
            break;
          case BlockType.heading2:
            {
              blocks.add(
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    block.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
              blocks.add(const SizedBox(height: 14));
            }
            break;
          case BlockType.heading3:
            {
              blocks.add(
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    block.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
              blocks.add(const SizedBox(height: 12));
            }
            break;

          default:
            {
              blocks.add(
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    block.text,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              );
              blocks.add(const SizedBox(height: 10));
            }
        }
      }
    }

    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: blocks,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final String noteId = ModalRoute.of(context)!.settings.arguments as String;
    final Tuple2<String, String> infos =
        ModalRoute.of(context)!.settings.arguments as Tuple2<String, String>;
    // print("noteId: $noteId");
    final note = ref.watch(noteProvider(infos));

    return Scaffold(
      body: BaseContainer(
        titleWidget: const Text(
          "Note Detail",
        ),
        body: Padding(
          padding:
              const EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 20),
          child: note.when(
            data: (data) {
              if (data == null) {
                return const Center(
                  child: Text("No data"),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      data.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildBlocks(data),
                  ],
                ),
              );
            },
            error: (error, stackTrace) {
              return Text(error.toString());
            },
            loading: (() {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }),
          ),
        ),
      ),
    );
  }
}
