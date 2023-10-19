import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/notes/notes_list_widget.dart';

class LatestFiles extends ConsumerStatefulWidget {
  const LatestFiles({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LatestFilesState();
}

class _LatestFilesState extends ConsumerState<LatestFiles> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Mes Dernières Notes", style: TextStyle(fontSize: 20)),
          SizedBox(height: 16),
          Expanded(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: NotesList(
              title: null,
              isRefresh: false,
            ),
          ))
        ],
      ),
    );
  }
}
