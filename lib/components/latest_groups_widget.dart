import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:noted_mobile/components/group_card_widget.dart';
import 'package:noted_mobile/data/services/api_helper.dart';
import 'package:noted_mobile/data/services/dio_singleton.dart';
import 'package:noted_mobile/data/group.dart';
import 'package:noted_mobile/data/user_provider.dart';
import 'package:noted_mobile/utils/theme_helper.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

typedef GroupRefreshCallBack = void Function(String, String);

class LatestGroups extends StatefulWidget {
  const LatestGroups({Key? key, required this.groups, required this.onRefresh})
      : super(key: key);

  final Future<List<NewGroup>?> groups;
  final VoidCallback onRefresh;

  @override
  State<LatestGroups> createState() => _LatestGroupsState();
}

class _LatestGroupsState extends State<LatestGroups> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();

  // Future<List<NewGroup>?> getGroups(User fromUser) async {
  //   List<NewGroup> groupsList = [];
  //   final api = singleton.get<APIHelper>();

  //   try {
  //     final groups = await api.get(
  //       "/groups",
  //       headers: {"Authorization": "Bearer ${fromUser.token}"},
  //       queryParams: {
  //         "account_id": fromUser.id,
  //         "limit": 5,
  //         "offset": 0,
  //       },
  //     );

  //     if (groups['statusCode'] != 200) {
  //       if (!mounted) {
  //         return null;
  //       }
  //       return [];
  //     }

  //     if (groups['data'] != null && groups['data']["groups"] == null) {
  //       return [];
  //     }

  //     for (var group in groups['data']["groups"]) {
  //       if (groupsList.length == 5) {
  //         break;
  //       }
  //       groupsList.add(NewGroup.fromJson(group));
  //     }

  //     return groupsList;
  //   } on DioError catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text(e.toString()),
  //     ));
  //     return null;
  //   }
  // }

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

    // final Widget page2 = Column(
    //   children: const [
    //     Text(
    //       "Invite Members",
    //       style: TextStyle(
    //           color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
    //     ),
    //     SizedBox(
    //       height: 64,
    //     ),
    //     Center(
    //       child: Text(
    //         "Feature coming soon!",
    //         style: TextStyle(
    //             color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
    //       ),
    //     ),
    //   ],
    // );

    // final Widget page3 = Column(
    //   children: const [
    //     Text(
    //       "Invite Message",
    //       style: TextStyle(
    //           color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
    //     ),
    //     SizedBox(
    //       height: 64,
    //     ),
    //     Center(
    //       child: Text(
    //         "Feature coming soon!",
    //         style: TextStyle(
    //             color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
    //       ),
    //     ),
    //   ],
    // );

    final List<Widget> pages = [page1];
    // final List<Widget> pages = [page1, page2, page3];

    String result = await showModalBottomSheet(
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
                      Navigator.pop(context, false);
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
                        if (pageIndex == pages.length - 1) {
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
                    onPressed: () {
                      if (pageIndex == pages.length - 1) {
                        apiCall(
                            userTkn,
                            _titleController.text,
                            _descriptionController.text,
                            context,
                            btnController);

                        btnController.success();
                        Future.delayed(const Duration(seconds: 1), () {
                          btnController.reset();
                        });
                        _descriptionController.clear();
                        _titleController.clear();
                        Navigator.pop(context, "refresh");
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

    if (result == "refresh") {
      if (kDebugMode) {
        print("refreshing in create group");
      }
      // TODO: delete this delay
      // delay for 1 second to allow the modal to close
      await Future.delayed(const Duration(seconds: 1));
      widget.onRefresh();
    } else {
      if (kDebugMode) {
        print("not refreshing in create group");
      }
    }
  }

  Future<void> apiCall(
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
          return;
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
          return;
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
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    return Container(
      padding: const EdgeInsets.all(20),
      height: 250,
      child: FutureBuilder<List<NewGroup>?>(
          future: widget.groups,
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data!.isNotEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Latest Groups", style: TextStyle(fontSize: 20)),
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return index == 4
                            ? GroupCard(
                                groupName: "See More ...",
                                groupIcon: Icons.add,
                                displaySeeMore: true,
                                onTap: () {
                                  Navigator.pushNamed(context, '/groups');
                                },
                              )
                            : GroupCard(
                                groupName: snapshot.data?[index].name ?? "",
                                groupNotesCount: 0,
                                onTap: () async {
                                  var result = await Navigator.pushNamed(
                                      context, '/group-detail',
                                      arguments: snapshot.data?[index].id);

                                  if (result == "refresh") {
                                    //TODO: fix this
                                    // delay to allow the animation to finish
                                    await Future.delayed(
                                        const Duration(seconds: 1));
                                    widget.onRefresh();
                                  }
                                },
                              );
                      },
                      itemCount: snapshot.data?.length ?? 0,
                      scrollDirection: Axis.horizontal,
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data!.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Start with Groups",
                      style: TextStyle(fontSize: 20)),
                  Expanded(
                    child: Row(
                      children: [
                        GroupCard(
                          groupName: "Create a Group",
                          groupIcon: Icons.add,
                          displaySeeMore: true,
                          onTap: () async {
                            await createGroup(userProvider.token);
                          },
                        ),
                        // GroupCard(
                        //   groupName: "Join a Group",
                        //   groupIcon: Icons.join_inner,
                        //   displaySeeMore: true,
                        //   onTap: () {
                        //     // Navigator.pushNamed(context, '/groups');
                        //   },
                        // )
                      ],
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return Center(
                child: CircularProgressIndicator(
              color: Colors.grey.shade900,
            ));
          }),
    );
  }
}
