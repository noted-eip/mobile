import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/home/home_infos_widget.dart';
import 'package:noted_mobile/components/notes/latest_notes_widget.dart';
import 'package:noted_mobile/components/groups/latest_groups_widget.dart';
import 'package:noted_mobile/data/clients/tracker_client.dart';
import 'package:noted_mobile/data/models/group/group.dart';
import 'package:noted_mobile/data/providers/group_provider.dart';
import 'package:noted_mobile/data/providers/note_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/pages/notifications/notification_page.dart';

class Product {
  final String name;
  final String category;
  final double price;

  Product({required this.name, required this.category, required this.price});
}

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
        leading: Container(
          padding: const EdgeInsets.only(left: 4),
          child: IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.black,
              size: 32,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          ),
        ),
        actions: const [
          NotifButton(),
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
                    Expanded(flex: 2, child: HomeInfos()),
                    Expanded(flex: 4, child: LatestsGroups()),
                    Expanded(flex: 6, child: LatestFiles()),
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

class NotifButton extends ConsumerStatefulWidget {
  const NotifButton({super.key});

  @override
  ConsumerState<NotifButton> createState() => _NotifButtonState();
}

class _NotifButtonState extends ConsumerState<NotifButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 4),
      child: IconButton(
        onPressed: (() {
          ref.read(trackerProvider).trackPage(TrackPage.notification);
          Scaffold.of(context).openEndDrawer();
        }),
        icon: const Icon(Icons.send, color: Colors.black),
      ),
    );
  }
}
