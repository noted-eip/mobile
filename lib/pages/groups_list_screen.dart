import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:noted_mobile/components/common/base_container.dart';
import 'package:noted_mobile/components/group_card_widget.dart';
import 'package:noted_mobile/components/invite_form_widget.dart';
import 'package:noted_mobile/data/services/api_helper.dart';
import 'package:noted_mobile/data/services/dio_singleton.dart';
import 'package:noted_mobile/data/group.dart';
import 'package:noted_mobile/data/user.dart';
import 'package:noted_mobile/data/user_provider.dart';
import 'package:noted_mobile/pages/group_detail_page.dart';
import 'package:noted_mobile/utils/theme_helper.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class GroupsListPage extends StatefulWidget {
  const GroupsListPage({Key? key}) : super(key: key);

  @override
  State<GroupsListPage> createState() => _GroupsListPageState();
}

class _GroupsListPageState extends State<GroupsListPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();

  Future<String?> getAccountId(String tkn, String email) async {
    final api = singleton.get<APIHelper>();

    try {
      final response = await api.get('/accounts/by-email/$email',
          headers: {"Authorization": "Bearer $tkn"});

      if (response['statusCode'] != 200) {
        if (!mounted) {
          return null;
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response['error'].toString()),
        ));
        return null;
      }

      return response['data']['account']['id'].toString();
    } on DioError catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.response!.data['error'].toString()),
      ));
      return null;
    }
  }

  Future<bool> inviteMember(String tkn, String groupId, String email) async {
    final api = singleton.get<APIHelper>();

    String? userId = await getAccountId(tkn, email);

    if (userId == null) {
      return false;
    }

    try {
      final response = await api.post('/invites', headers: {
        "Authorization": "Bearer $tkn"
      }, body: {
        "group_id": groupId,
        "recipient_account_id": userId,
      });

      if (response['statusCode'] != 200) {
        if (!mounted) {
          return false;
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response['error'].toString()),
        ));
        return false;
      }
    } on DioError catch (e) {
      if (!mounted) {
        return false;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
      return false;
    }
    return true;
  }

  Future<void> createGroup(String userTkn) async {
    PageController pageController = PageController(initialPage: 0);
    int pageIndex = 0;
    String buttonText = "Next";

    final Widget page1 = Column(
      children: [
        const Text(
          "Create Group",
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 32,
        ),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: ThemeHelper()
                    .textInputDecoration('Group Title', 'Enter a Title'),
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Please enter a Title";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30.0),
              TextFormField(
                minLines: 3,
                maxLines: 3,
                controller: _descriptionController,
                decoration: ThemeHelper().textInputDecoration(
                    'Group Description', 'Enter a Description'),
                validator: (val) {
                  if (val!.isEmpty) {
                    return 'Please enter a Description';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ],
    );

    final List<TextEditingController> controller = [];
    final List<String> roles = [];
    final roleformKey = GlobalKey<FormState>();

    final Widget page2 = Column(
      children: [
        const Text(
          "Invite Members",
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 32,
        ),
        Expanded(
            child: Form(
          key: roleformKey,
          child: InviteForm(
            controller: controller,
            selectedRoles: roles,
          ),
        )),
      ],
    );

    final List<Widget> pages = [page1, page2];

    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: (() {
                      Navigator.pop(context);
                      _descriptionController.clear();
                      _titleController.clear();
                    }),
                    child: const Text(
                      "Fermer",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  Expanded(
                      child: PageView(
                    onPageChanged: (value) {
                      setState(() {
                        pageIndex = value;
                        if (pageIndex == 2) {
                          buttonText = "Create";
                        } else {
                          buttonText = "Next";
                        }
                      });
                    },
                    controller: pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: pages,
                  )),
                  RoundedLoadingButton(
                    color: Colors.grey.shade900,
                    errorColor: Colors.redAccent,
                    successColor: Colors.green.shade900,
                    onPressed: () async {
                      if (pageIndex == 0) {
                        if (_formKey.currentState!.validate()) {
                          pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn);
                          btnController.success();
                          Future.delayed(const Duration(seconds: 1), () {
                            btnController.reset();
                          });
                        } else {
                          btnController.error();
                          Future.delayed(const Duration(seconds: 1), () {
                            btnController.reset();
                          });
                        }
                      } else if (pageIndex == 1) {
                        if (roleformKey.currentState!.validate()) {
                          String? groupId = await apiCall(
                              userTkn,
                              _titleController.text,
                              _descriptionController.text,
                              context,
                              btnController);
                          if (groupId != null) {
                            controller.asMap().forEach((index, value) async {
                              await inviteMember(userTkn, groupId, value.text);
                            });

                            //TODO: change role of member from roles
                          } else {
                            btnController.error();
                            Future.delayed(const Duration(seconds: 1), () {
                              btnController.reset();
                            });
                          }

                          btnController.success();
                          Future.delayed(const Duration(seconds: 1), () {
                            btnController.reset();
                          });
                          _descriptionController.clear();
                          _titleController.clear();
                          if (mounted) {
                            Navigator.pop(context);
                          }
                          setState(() {});
                        }
                      }
                    },
                    controller: btnController,
                    width: MediaQuery.of(context).size.width,
                    borderRadius: 16,
                    child: Text(
                      buttonText.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<String?> apiCall(
      String userTkn,
      String groupTitle,
      String groupDescription,
      BuildContext context,
      RoundedLoadingButtonController btnController) async {
    final api = singleton.get<APIHelper>();

    try {
      final response = await api.post('/groups',
          headers: {"Authorization": "Bearer $userTkn"},
          body: {"name": groupTitle, "description": groupDescription});

      if (response['statusCode'] != 200) {
        if (!mounted) {
          return null;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create group'),
          ),
        );
        btnController.error();
        Future.delayed(const Duration(seconds: 1), () {
          btnController.reset();
        });
      } else {
        if (!mounted) {
          return null;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Group created successfully'),
          ),
        );
        btnController.success();
        Future.delayed(const Duration(seconds: 1), () {
          btnController.reset();
        });
        return response["data"]["group"]["id"];
      }
    } on DioError catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
      btnController.error();
      Future.delayed(const Duration(seconds: 1), () {
        btnController.reset();
      });
    }
    return null;
  }

  Future<List<NewGroup>?> getGroups(User fromUser) async {
    List<NewGroup> groupsList = [];
    final api = singleton.get<APIHelper>();

    try {
      final groups = await api.get(
        "/groups",
        headers: {"Authorization": "Bearer ${fromUser.token}"},
        queryParams: {
          "account_id": fromUser.id,
        },
      );

      if (groups['statusCode'] != 200) {
        if (!mounted) {
          return null;
        }
      }

      if (groups['data'] == null ||
          groups['data'] != null && groups['data']["groups"] == null) {
        return [];
      }

      for (var group in groups['data']["groups"]) {
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

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    return BaseContainer(
      titleWidget: Row(
        children: [
          const Text(
            "My Groups",
          ),
          const Spacer(),
          Material(
            color: Colors.transparent,
            child: IconButton(
              onPressed: () {
                createGroup(userProvider.token);
              },
              icon: const Icon(
                Icons.add,
                size: 32,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: FutureBuilder<List<NewGroup>?>(
                  future: getGroups(
                    User(
                      email: userProvider.email,
                      id: userProvider.id,
                      token: userProvider.token,
                      username: userProvider.username,
                    ),
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data!.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: () async {
                            setState(() {});
                          },
                          child: ListView(children: const [
                            Center(
                              child: Text("No groups found"),
                            ),
                          ]),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () async {
                          setState(() {});
                        },
                        child: GridView.builder(
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return GroupCard(
                              groupName: snapshot.data![index].name,
                              groupDescription:
                                  snapshot.data![index].description,
                              groupNotesCount: 0,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GroupDetailPage(
                                      groupId: snapshot.data![index].id,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text("Error"),
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
