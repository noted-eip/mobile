import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/common/base_container.dart';
import 'package:noted_mobile/components/common/loading_button.dart';
import 'package:noted_mobile/data/models/note/note.dart';
import 'package:noted_mobile/data/models/note/note_block.dart';
import 'package:noted_mobile/data/providers/note_provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:tuple/tuple.dart';

class NoteDetail extends ConsumerStatefulWidget {
  const NoteDetail({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NoteDetailState();
}

class _NoteDetailState extends ConsumerState<NoteDetail> {
  int numberedPoint = 1;

  Widget _buildBlocks(Note note) {
    List<Widget> blocks = [];

    if (note.blocks != null) {
      note.blocks!.asMap().forEach((key, value) {
        Block? previousBlock = key > 0 ? note.blocks![key - 1] : null;

        switch (value.type) {
          case BlockType.heading1:
            {
              blocks.add(
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    value.text,
                    textAlign: TextAlign.start,
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
                    value.text,
                    textAlign: TextAlign.start,
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
                    value.text,
                    textAlign: TextAlign.start,
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
          case BlockType.numberPoint:
            {
              if (previousBlock?.type != BlockType.numberPoint) {
                numberedPoint = 1;
              }

              blocks.add(
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    "$numberedPoint. ${value.text}",
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              );
              blocks.add(const SizedBox(height: 10));
              numberedPoint++;
            }
            break;
          case BlockType.bulletPoint:
            {
              blocks.add(
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    "• ${value.text}",
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              );
              blocks.add(const SizedBox(height: 10));
            }
            break;

          default:
            {
              blocks.add(
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    value.text,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              );
              blocks.add(const SizedBox(height: 10));
            }
            break;
        }
      });
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
    final Tuple2<String, String> infos =
        ModalRoute.of(context)!.settings.arguments as Tuple2<String, String>;
    final note = ref.watch(noteProvider(infos));

    RoundedLoadingButtonController btnController =
        RoundedLoadingButtonController();

    return Scaffold(
      body: BaseContainer(
        titleWidget: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              note.hasValue ? note.value!.title : "Note Detail",
            ),
            LoadingButton(
              width: 48,
              elevation: 0,
              color: Colors.white,
              secondaryColor: Colors.black,
              btnController: btnController,
              onPressed: () async {
                ref.invalidate(noteProvider(infos));
              },
              resetDuration: 3,
              child: const Icon(
                Icons.refresh,
                color: Colors.black,
                size: 32,
              ),
            ),
          ],
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
