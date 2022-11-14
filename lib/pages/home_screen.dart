import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:noted_mobile/components/home_infos_widget.dart';
import 'package:noted_mobile/components/latest_files_widget.dart';
import 'package:noted_mobile/components/latest_folders_widget.dart';
import 'package:noted_mobile/data/user.dart';
import 'package:noted_mobile/data/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SharedPreferences? prefs;
  User? user;

  @override
  void initState() {
    super.initState();
    getPrefs().whenComplete(() {
      setState(() {
        user = User(
          email: prefs?.getString('email') ?? '',
          id: prefs?.getString('id') ?? '',
          token: prefs?.getString('token') ?? '',
          username: prefs?.getString('username') ?? '',
        );
      });
    });
  }

  Future<void> getPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    if (user != null && user?.email != '') {
      Future.delayed(Duration.zero, () {
        userProvider.setToken(user?.token ?? '');
        userProvider.setID(user?.id ?? '');
        userProvider.setUsername(user?.username ?? '');
        userProvider.setEmail(user?.email ?? '');
      });
    }
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
                Navigator.pushNamed(context, '/profile');
              }),
              icon: const Icon(Icons.person, color: Colors.black)),
        ],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: const [
            HomeInfos(),
            LatestFolders(),
            LatestFiles(),
          ],
        ),
      ),
    );
  }
}
