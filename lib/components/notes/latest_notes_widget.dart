import 'package:easy_localization/easy_localization.dart';
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("home.lastest-notes".tr(), style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 16),
          const Expanded(
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
