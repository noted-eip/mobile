import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:noted_mobile/components/home/home_infos_widget.dart';
import 'package:noted_mobile/components/notes/latest_notes_widget.dart';
import 'package:noted_mobile/components/groups/latest_groups_widget.dart';
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
    final homePageHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom -
        kToolbarHeight;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight,
        title: const Text('NOTED', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        leading: Builder(builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.only(left: 4),
            child: IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.black,
                size: 32,
              ),
              onPressed: () {
                ZoomDrawer.of(context)!.toggle();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            ),
          );
        }),
        actions: [
          Container(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              onPressed: (() {
                Navigator.pushNamed(context, "/notif");
              }),
              icon: const Icon(Icons.send, color: Colors.black),
            ),
          ),
        ],
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          displacement: 0,
          onRefresh: () async {
            ref.invalidate(latestGroupsProvider);
            ref.invalidate(notesProvider);
          },
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                height: homePageHeight,
                child: Column(
                  children: const [
                    Expanded(flex: 2, child: HomeInfos()),
                    Expanded(flex: 4, child: LatestsGroups()),
                    Expanded(flex: 5, child: LatestFiles()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
