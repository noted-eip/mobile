import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/home/home_infos_widget.dart';
import 'package:noted_mobile/components/notes/latest_notes_widget.dart';
import 'package:noted_mobile/components/groups/latest_groups_widget.dart';
import 'package:noted_mobile/data/models/group/group.dart';
import 'package:noted_mobile/data/providers/group_provider.dart';
import 'package:noted_mobile/data/providers/note_provider.dart';
import 'package:noted_mobile/pages/notifications/notification_page.dart';

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
        forceMaterialTransparency: true,
        title: const Text('NOTED'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed('/notif'),
            icon: const Icon(Icons.send, color: Colors.black),
          ),
        ],
        elevation: 0,
      ),
      endDrawer: const NotificationPage(),
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
                child: const Column(
                  children: [
                    Expanded(flex: 3, child: HomeInfos()),
                    Expanded(flex: 5, child: LatestsGroups()),
                    Expanded(flex: 7, child: LatestFiles()),
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
