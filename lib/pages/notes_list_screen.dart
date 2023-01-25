import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/common/base_container.dart';
import 'package:noted_mobile/components/notes_list_widget.dart';

class LatestsFilesList extends ConsumerStatefulWidget {
  const LatestsFilesList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LatestsFilesListState();
}

class _LatestsFilesListState extends ConsumerState<LatestsFilesList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseContainer(
      titleWidget: const Text(
        "My Notes",
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Expanded(
              child: NotesList(isRefresh: true, title: null),
            ),
          ],
        ),
      ),
    );
  }
}
