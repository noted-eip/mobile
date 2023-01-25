import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:noted_mobile/components/home_infos_widget.dart';
import 'package:noted_mobile/components/latest_files_widget.dart';
import 'package:noted_mobile/components/latest_groups_widget.dart';
import 'package:noted_mobile/data/models/group/group.dart';
import 'package:noted_mobile/data/providers/group_provider.dart';
import 'package:noted_mobile/data/providers/note_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late Future<List<Group>?> groups;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NOTED', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        leading: Builder(builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.black,
            ),
            onPressed: () {
              ZoomDrawer.of(context)!.toggle();
            },
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          );
        }),
        actions: [
          IconButton(
              onPressed: (() {
                Navigator.pushNamed(context, "/notif");
              }),
              icon: const Icon(Icons.send, color: Colors.black)),
        ],
        elevation: 0,
      ),
      body: RefreshIndicator(
        displacement: 0,
        onRefresh: () async {
          ref.invalidate(latestGroupsProvider);
          ref.invalidate(notesProvider);
        },
        child: ListView(
          children: const [
            HomeInfos(),
            LatestsGroups(),
            LatestFiles(),
          ],
        ),
      ),
    );
  }
}
