import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:noted_mobile/components/home_infos_widget.dart';
import 'package:noted_mobile/components/latest_files_widget.dart';
import 'package:noted_mobile/components/latest_groups_widget.dart';
import 'package:noted_mobile/data/services/api_helper.dart';
import 'package:noted_mobile/data/services/dio_singleton.dart';
import 'package:noted_mobile/data/group.dart';
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

  late Future<List<NewGroup>?> groups;

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

  Future<void> deleteGroup(String id) async {
    final api = singleton.get<APIHelper>();

    try {
      final response = await api.delete('/groups/$id', headers: {
        "Authorization":
            "Bearer eyJhbGciOiJFZERTQSIsInR5cCI6IkpXVCJ9.eyJ1aWQiOiJiMjc3YmUyMC03ZjAzLTQ5MmQtYWViNy04YjI5Zjc2ZjUxODMifQ.mcvBAMr4mPYhcxXsoEWCNWc3mafPif3bOsRLmc1_LoVlm7ozAgdobMLPg2glmJYhYvJZtHD7LnY4TF5eNsYbAw"
      });

      if (response['statusCode'] == 200) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Group deleted successfully'),
          ),
        );
      } else {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete group'),
          ),
        );
      }
    } on DioError catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future<void> createGroup() async {
    final api = singleton.get<APIHelper>();

    try {
      final response = await api.post('/groups', headers: {
        "Authorization":
            "Bearer eyJhbGciOiJFZERTQSIsInR5cCI6IkpXVCJ9.eyJ1aWQiOiJiMjc3YmUyMC03ZjAzLTQ5MmQtYWViNy04YjI5Zjc2ZjUxODMifQ.mcvBAMr4mPYhcxXsoEWCNWc3mafPif3bOsRLmc1_LoVlm7ozAgdobMLPg2glmJYhYvJZtHD7LnY4TF5eNsYbAw"
      }, body: {
        "name": "Group test 3",
        "description": "Troisième group"
      });

      if (response['statusCode'] != 200) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create group'),
          ),
        );
      } else {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Group created successfully'),
          ),
        );
      }
    } on DioError catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future<List<NewGroup>?> getGroups(String tkn, String id) async {
    List<NewGroup> groupsList = [];
    final api = singleton.get<APIHelper>();

    try {
      final groups = await api.get(
        "/groups",
        headers: {"Authorization": "Bearer $tkn"},
        queryParams: {
          "account_id": id,
          "limit": 5,
          "offset": 0,
        },
      );

      if (groups['statusCode'] != 200) {
        if (!mounted) {
          return null;
        }
        return [];
      }

      if (groups['data'] != null && groups['data']["groups"] == null) {
        return [];
      }

      for (var group in groups['data']["groups"]) {
        if (groupsList.length == 5) {
          break;
        }
        groupsList.add(NewGroup.fromJson(group));
      }

      return groupsList;
    } on DioError catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
      return null;
    }
  }

  void refreshingGroups(String tkn, String id) {
    var freshGroups = getGroups(tkn, id);

    setState(() {
      groups = freshGroups;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    refreshingGroups(userProvider.token, userProvider.id);

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
                Navigator.pushNamed(context, "/notif");
              }),
              icon: const Icon(Icons.send, color: Colors.black)),
        ],
        elevation: 0,
      ),
      body: RefreshIndicator(
        displacement: 0,
        onRefresh: () async {
          refreshingGroups(userProvider.token, userProvider.id);
        },
        child: ListView(
          children: [
            const HomeInfos(),
            LatestGroups(
                groups: groups,
                onRefresh: () {
                  refreshingGroups(userProvider.token, userProvider.id);
                }),
            const LatestFiles(),
          ],
        ),
      ),
    );
  }
}
