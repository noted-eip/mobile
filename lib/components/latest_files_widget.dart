import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/notes_list_widget.dart';

class LatestFiles extends ConsumerStatefulWidget {
  const LatestFiles({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LatestFilesState();
}

class _LatestFilesState extends ConsumerState<LatestFiles> {
  //TODO: change container height to 370

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 370,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Expanded(
              child: NotesList(
            title: Text("Latest Files", style: TextStyle(fontSize: 20)),
            isRefresh: false,
          ))
        ],
      ),
    );
  }
}
