import 'package:app_settings/app_settings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_popup/internet_popup.dart';
import 'package:noted_mobile/data/clients/tracker_client.dart';
import 'package:noted_mobile/data/providers/group_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/pages/groups/group_detail_page.dart';
import 'package:noted_mobile/pages/groups/groups_list_screen.dart';
import 'package:noted_mobile/pages/notes/notes_list_screen.dart';
import 'package:noted_mobile/pages/account/profile_screen.dart';
import 'package:noted_mobile/pages/notifications/notification_page.dart';
import 'package:noted_mobile/utils/color.dart';
import 'package:noted_mobile/utils/language.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../pages/home/home_screen.dart';

class MyDrawer extends ConsumerStatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  ConsumerState<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends ConsumerState<MyDrawer> {
  late GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  void initState() {
    super.initState();
    InternetPopup().initialize(
      context: context,
      customMessage: "alert.internet.title".tr(),
      customDescription: "alert.internet.description".tr(),
      onTapPop: true,
    );

    _scaffoldKey = ref.read(mainScreenProvider).scaffoldKey;
  }

  openSettings() {
    AppSettings.openAppSettings(type: AppSettingsType.wifi);
  }

  @override
  Widget build(BuildContext context) {
    MyMenuItem currentItem = ref.watch(mainScreenProvider).item;

    var workspaceIdFromProvider = ref.read(workspaceIdProvider);

    return Scaffold(
      key: _scaffoldKey,
      drawer: MenuScreen(
        currentItem: currentItem,
        onSelected: (item) {
          ref.read(trackerProvider).trackPage(item.trackPage);
          ref.read(mainScreenProvider).setItem(item);
          Navigator.of(context).pop();
        },
      ),
      endDrawer: const NotificationPage(),
      body: getScreen(currentItem, workspaceIdFromProvider),
    );
  }

  Widget getScreen(
      MyMenuItem currentItem, AsyncValue<String> workspaceIdFromProvider) {
    switch (currentItem) {
      case MyMenuItems.home:
        return const HomePage();
      case MyMenuItems.workspace:
        if (workspaceIdFromProvider.hasValue &&
            workspaceIdFromProvider.value != null &&
            workspaceIdFromProvider.value!.isNotEmpty) {
          return GroupDetailPage(groupId: workspaceIdFromProvider.value);
        } else {
          return const GroupsListPage();
        }

      case MyMenuItems.groups:
        return const GroupsListPage();
      case MyMenuItems.notes:
        return const LatestsFilesList();
      case MyMenuItems.profil:
        return const ProfilePage();
      // case MyMenuItems.test:
      //   return const TestPage();
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
      case MyMenuItems.workspace:
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
  static const home = MyMenuItem(icon: Icons.home, title: 'menu.home');
  static const workspace =
      MyMenuItem(icon: Icons.folder, title: 'menu.workspace');
  static const groups = MyMenuItem(icon: Icons.group, title: 'menu.groups');
  static const notes = MyMenuItem(icon: Icons.description, title: 'menu.notes');
  static const profil = MyMenuItem(icon: Icons.person, title: 'menu.profile');

  static const all = <MyMenuItem>[
    home,
    workspace,
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
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            offset: Offset(5, 5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(width: 1, color: NotedColors.primary),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: NotedColors.primary,
                        blurRadius: 5,
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
                  'NOTED',
                  style: TextStyle(
                      color: Colors.black,
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
              iconColor: Colors.red,
              textColor: Colors.red,
              onTap: () {
                prefs!.remove('token');
                prefs!.remove('email');
                prefs!.remove('name');
                prefs!.remove('id');
                LanguagePreferences.resetLanguage();
                ref.read(mainScreenProvider).setItem(MyMenuItems.home);
                ref.read(trackerProvider).trackPage(TrackPage.login);

                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (r) => false);
              },
              leading: const Icon(Icons.logout),
              title: Text("menu.logout".tr()),
            ),
          ],
        ),
      ),
    );

    return drawer;
  }

  Widget _buildMenuItem(MyMenuItem item) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: widget.currentItem == item
              ? NotedColors.primary.withOpacity(0.7)
              : Colors.white,
        ),
        child: ListTile(
          selected: widget.currentItem == item,
          selectedColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          style: ListTileStyle.drawer,
          textColor: Colors.black,
          tileColor: Colors.black,
          iconColor: Colors.black,
          onTap: widget.currentItem == item
              ? null
              : () {
                  widget.onSelected(item);
                },
          leading: Icon(item.icon),
          title: Text(item.title.tr()),
        ),
      );
}
