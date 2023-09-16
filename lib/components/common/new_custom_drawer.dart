import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/clients/tracker_client.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/pages/groups/groups_list_screen.dart';
import 'package:noted_mobile/pages/notes/notes_list_screen.dart';
import 'package:noted_mobile/pages/account/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../pages/home/home_screen.dart';

class MyDrawer extends ConsumerStatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  ConsumerState<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends ConsumerState<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    MyMenuItem currentItem = ref.watch(mainScreenProvider).item;

    return Scaffold(
      drawer: MenuScreen(
        currentItem: currentItem,
        onSelected: (item) {
          ref.read(trackerProvider).trackPage(item.trackPage);
          ref.read(mainScreenProvider).setItem(item);
          Navigator.of(context).pop();
        },
      ),
      body: getScreen(currentItem),
    );
  }

  Widget getScreen(MyMenuItem currentItem) {
    switch (currentItem) {
      case MyMenuItems.home:
        return const HomePage();
      case MyMenuItems.groups:
        return const GroupsListPage();
      case MyMenuItems.notes:
        return const LatestsFilesList();
      case MyMenuItems.profil:
        return const ProfilePage();
      default:
        return const HomePage();
    }
  }
}

class MyMenuItem {
  final String title;
  final IconData icon;
  final Function()? onTap;

  const MyMenuItem({
    required this.title,
    required this.icon,
    this.onTap,
  });

  TrackPage get trackPage {
    switch (this) {
      case MyMenuItems.home:
        return TrackPage.home;
      case MyMenuItems.groups:
        return TrackPage.groupsList;
      case MyMenuItems.notes:
        return TrackPage.notesList;
      case MyMenuItems.profil:
        return TrackPage.profile;
      default:
        return TrackPage.home;
    }
  }
}

class MyMenuItems {
  static const home = MyMenuItem(icon: Icons.home, title: 'Home');
  static const groups = MyMenuItem(icon: Icons.group, title: 'My Groups');
  static const notes = MyMenuItem(icon: Icons.description, title: 'My Notes');
  static const profil = MyMenuItem(icon: Icons.person, title: 'Profile');

  static const all = <MyMenuItem>[
    home,
    groups,
    notes,
    profil,
  ];
}

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen(
      {Key? key, required this.currentItem, required this.onSelected})
      : super(key: key);
  final MyMenuItem currentItem;
  final ValueChanged<MyMenuItem> onSelected;

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    getPrefs();
  }

  void getPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    final drawer = Container(
      width: MediaQuery.of(context).size.width * 0.75,
      color: Colors.grey[900],
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(width: 5, color: Colors.white),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(5, 5),
                      ),
                    ],
                  ),
                  child: const Image(
                    image: AssetImage('./images/noted_logo.png'),
                    fit: BoxFit.fill,
                    height: 80.0,
                    width: 80.0,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Noted',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Column(
              children: [
                ...MyMenuItems.all.map(_buildMenuItem).toList(),
              ],
            ),
            ListTile(
              iconColor: Colors.white,
              textColor: Colors.white,
              onTap: () {
                prefs!.remove('token');
                prefs!.remove('email');
                prefs!.remove('name');
                prefs!.remove('id');

                ref.read(mainScreenProvider).setItem(MyMenuItems.home);
                ref.read(trackerProvider).trackPage(TrackPage.login);

                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (r) => false);
              },
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
            ),
          ],
        ),
      ),
    );

    return drawer;
  }

  Widget _buildMenuItem(MyMenuItem item) => ListTile(
        selected: widget.currentItem == item,
        selectedTileColor: Colors.black,
        textColor: Colors.white,
        iconColor: Colors.white,
        onTap: () {
          widget.onSelected(item);
        },
        leading: Icon(item.icon),
        title: Text(item.title),
      );
}
