import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:noted_mobile/components/common/new_custom_drawer.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/pages/groups/groups_list_screen.dart';
import 'package:noted_mobile/pages/notes/notes_list_screen.dart';
import 'package:noted_mobile/pages/account/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../pages/home/home_screen.dart';

class MyCustomDrawer extends ConsumerStatefulWidget {
  const MyCustomDrawer({Key? key}) : super(key: key);

  @override
  ConsumerState<MyCustomDrawer> createState() => _MyCustomDrawerState();
}

class _MyCustomDrawerState extends ConsumerState<MyCustomDrawer> {
  @override
  Widget build(BuildContext context) {
    final MyMenuItem currentItem = ref.watch(mainScreenProvider).item;

    return ZoomDrawer(
      borderRadius: 16,
      angle: 0,
      mainScreenScale: 0.2,
      menuBackgroundColor: Colors.grey.shade900,
      mainScreenOverlayColor: Colors.black.withOpacity(0.2),
      mainScreenTapClose: true,
      style: DrawerStyle.style1,
      menuScreen: Builder(
        builder: (context2) {
          return MenuScreen(
            currentItem: currentItem,
            onSelected: (item) {
              ref.read(mainScreenProvider).setItem(item);
              ZoomDrawer.of(context2)!.close();
            },
          );
        },
      ),
      mainScreen: getScreen(currentItem),
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
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
