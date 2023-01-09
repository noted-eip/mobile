import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:noted_mobile/components/common/base_container.dart';
import 'package:noted_mobile/components/group_info_widget.dart';
import 'package:noted_mobile/components/notes_list_widget.dart';
import 'package:noted_mobile/components/slide_widget.dart';
import 'package:noted_mobile/data/note.dart';
import 'package:noted_mobile/data/services/api_helper.dart';
import 'package:noted_mobile/data/services/dio_singleton.dart';
import 'package:noted_mobile/data/group.dart';
import 'package:noted_mobile/data/user_provider.dart';
import 'package:noted_mobile/pages/notification_page.dart';
import 'package:noted_mobile/utils/theme_helper.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

//ajouter un scroll sur la page entière et faire disparaitre le header
//avec l'effet d'apple en gardant le nom du fichier dans l'app bar
// Voir pour refaire le design de la page

class GroupDetailPage extends StatefulWidget {
  const GroupDetailPage({Key? key, this.groupId}) : super(key: key);

  final String? groupId;

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<TextEditingController> _inviteController = [
    TextEditingController(),
  ];
  final RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();

  late Future<NewGroup?> group;

  Future<void> deleteGroup(String groupId, userTkn) async {
    final api = singleton.get<APIHelper>();

    try {
      final response = await api.delete(
        '/groups/$groupId',
        headers: {"Authorization": "Bearer $userTkn"},
      );

      if (response['statusCode'] != 200) {
        if (!mounted) {
          return;
        }
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('Failed to delete group'),
        //   ),
        // );
        if (kDebugMode) {
          print("Failed to delete group");
        }

        return;
      } else {
        if (!mounted) {
          return;
        }
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('Group deleted successfully'),
        //   ),
        // );
        if (kDebugMode) {
          print("Group deleted successfully");
        }
        return;
      }
    } on DioError catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(e.toString()),
      //   ),
      // );
      if (kDebugMode) {
        print(e.toString());
      }

      return;
    }
  }

  Future<List<Invite>?> getGroupInvites(String tkn, String groupId) async {
    List<Invite> invitesList = [];
    final api = singleton.get<APIHelper>();

    try {
      final invites = await api.get(
        "/invites",
        headers: {"Authorization": "Bearer $tkn"},
        queryParams: {
          "group_id": groupId,
        },
      );

      if (invites['statusCode'] != 200) {
        if (!mounted) {
          return null;
        }
        return [];
      }

      if (invites['data'] != null && invites['data']["invites"] == null) {
        if (!mounted) {
          return null;
        }
        return [];
      }

      for (var invite in invites['data']["invites"]) {
        if (invitesList.length == 5) {
          break;
        }
        invitesList.add(Invite.fromJson(invite));
      }

      return invitesList;
    } on DioError catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
      return null;
    }
  }

  Future<void> invitePendingModal(String tkn, String groupId) async {
    final Widget page1 = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pending Invitations",
          textAlign: TextAlign.start,
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 32,
        ),
        Expanded(
          child: FutureBuilder<List<Invite>?>(
              future: getGroupInvites(tkn, groupId),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return RefreshIndicator(
                    displacement: 0,
                    onRefresh: () async {
                      setState(() {});
                    },
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: CustomSlide(
                              title: "Invite",
                              subtitle: snapshot.data![index].id,
                              actions: const [],
                            ));
                      },
                    ),
                  );
                } else if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("No pending invitations"),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        ),
      ],
    );

    return await showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Container(
            height: 700,
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
                      _inviteController[0].clear();
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
                    child: page1,
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<void> inviteMemberModal(String tkn, String groupId) async {
    final Widget page1 = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Invite new members",
          textAlign: TextAlign.start,
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
                controller: _inviteController[0],
                decoration: ThemeHelper()
                    .textInputDecoration('Email', 'Enter member email'),
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Please enter an email";
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ],
    );

    return await showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Container(
            height: 700,
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
                      _inviteController[0].clear();
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
                    child: page1,
                  ),
                  RoundedLoadingButton(
                    color: Colors.grey.shade900,
                    errorColor: Colors.redAccent,
                    successColor: Colors.green.shade900,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final isValidChange = await inviteMember(
                            tkn, groupId, _inviteController[0].text);

                        if (isValidChange) {
                          btnController.success();
                          Future.delayed(const Duration(seconds: 1), () {
                            btnController.reset();
                          });
                          _inviteController[0].clear();
                          if (!mounted) {
                            return;
                          }
                          Navigator.pop(context, true);
                          refreshingGroup(tkn, groupId);
                        } else {
                          btnController.error();
                          Future.delayed(const Duration(seconds: 1), () {
                            btnController.reset();
                          });
                        }

                        // if (isValidChange) {
                        //   btnController.success();
                        //   Future.delayed(const Duration(seconds: 1), () {
                        //     btnController.reset();
                        //   });
                        //   _descriptionController.clear();
                        //   _titleController.clear();
                        //   if (!mounted) {
                        //     return;
                        //   }
                        //   Navigator.pop(context, true);
                        //   refreshingGroup(userTkn, groupId);
                      } else {
                        btnController.error();
                        Future.delayed(const Duration(seconds: 1), () {
                          btnController.reset();
                        });
                      }
                    },
                    controller: btnController,
                    width: MediaQuery.of(context).size.width,
                    borderRadius: 16,
                    child: const Text(
                      "Validate",
                      style: TextStyle(
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

  Future<bool> editGroup(String groupId, String userTkn, String baseTitle,
      String baseDescription) async {
    _titleController.text = baseTitle;
    _descriptionController.text = baseDescription;
    PageController pageController = PageController(initialPage: 0);
    int pageIndex = 0;
    String buttonText = "Next";

    final Widget page1 = Column(
      children: [
        const Text(
          "Edit Group",
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

    final Widget page2 = Column(
      children: const [
        Text(
          "Invite Members",
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 64,
        ),
        Center(
          child: Text(
            "Feature coming soon!",
            style: TextStyle(
                color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );

    final Widget page3 = Column(
      children: const [
        Text(
          "Invite Message",
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 64,
        ),
        Center(
          child: Text(
            "Feature coming soon!",
            style: TextStyle(
                color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );

    final List<Widget> pages = [page1, page2, page3];

    return await showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Container(
            height: 700,
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
                          // pageController.nextPage(
                          //     duration: const Duration(milliseconds: 300),
                          //     curve: Curves.easeIn);
                          final bool isValidChange = await apiCall(
                              groupId,
                              userTkn,
                              _titleController.text,
                              _descriptionController.text,
                              context,
                              btnController);

                          if (isValidChange) {
                            btnController.success();
                            Future.delayed(const Duration(seconds: 1), () {
                              btnController.reset();
                            });
                            _descriptionController.clear();
                            _titleController.clear();
                            if (!mounted) {
                              return;
                            }
                            Navigator.pop(context, true);
                            refreshingGroup(userTkn, groupId);
                          } else {
                            btnController.error();
                            Future.delayed(const Duration(seconds: 1), () {
                              btnController.reset();
                            });
                          }
                          //   btnController.success();
                          //   Future.delayed(const Duration(seconds: 1), () {
                          //     btnController.reset();
                          //   });
                          // } else {
                          //   btnController.error();
                          //   Future.delayed(const Duration(seconds: 1), () {
                          //     btnController.reset();
                          //   });
                        }
                      }
                      //  else if (pageIndex == 1) {
                      //   btnController.success();
                      //   Future.delayed(const Duration(seconds: 1), () {
                      //     btnController.reset();
                      //   });
                      //   pageController.nextPage(
                      //       duration: const Duration(milliseconds: 300),
                      //       curve: Curves.easeIn);
                      // } else if (pageIndex == 2) {
                      //   final bool isValidChange = await apiCall(
                      //       groupId,
                      //       userTkn,
                      //       _titleController.text,
                      //       _descriptionController.text,
                      //       context,
                      //       btnController);

                      //   if (isValidChange) {
                      //     btnController.success();
                      //     Future.delayed(const Duration(seconds: 1), () {
                      //       btnController.reset();
                      //     });
                      //     _descriptionController.clear();
                      //     _titleController.clear();
                      //     if (!mounted) {
                      //       return;
                      //     }
                      //     Navigator.pop(context);
                      //   } else {
                      //     btnController.error();
                      //     Future.delayed(const Duration(seconds: 1), () {
                      //       btnController.reset();
                      //     });
                      //   }
                      // }
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

  Future<bool> deleteGroupMember(
      String userTkn, String userId, String groupId) async {
    final api = singleton.get<APIHelper>();

    try {
      final response = await api.delete(
        "/groups/$groupId/members/$userId",
        headers: {"Authorization": "Bearer $userTkn"},
      );

      if (response['statusCode'] != 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['error']),
            ),
          );
        }

        return false;
      }

      return true;
    } on DioError catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }

  Future<void> leaveGroupDialog(
      String userTkn, String userId, String groupId) async {
    return await showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: const Text("Leave the Group"),
          content: const Text("Are you sure you want to leave this group?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                bool isLeave = await deleteGroupMember(
                  userTkn,
                  userId,
                  groupId,
                );

                if (!mounted) {
                  return;
                }

                if (isLeave) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context, "refresh");
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Something went wrong"),
                    ),
                  );
                }
              },
              child: const Text("Leave"),
            ),
          ],
        );
      }),
    );
  }

  Future<void> openSettings(String userTkn, String userId, String groupId,
      String groupName, String groupDescription) async {
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              height: 700,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: (() => Navigator.pop(context)),
                        child: const Text(
                          "Fermer",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          // Navigator.pop(context);
                          var res = await editGroup(
                            groupId,
                            userTkn,
                            groupName,
                            groupDescription,
                          );

                          if (res == true) {
                            // setState(() {
                            //   refreshingGroup(
                            //       userTkn,
                            //       groupId);
                            // });
                            if (mounted) {
                              Navigator.pop(context);
                            }
                          }
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  Text(
                    groupName,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  Text(
                    groupDescription,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.normal),
                  ),
                  const SizedBox(
                    height: 48,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Member List",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              await invitePendingModal(
                                userTkn,
                                groupId,
                              );
                            },
                            icon: const Icon(
                              Icons.inbox,
                              color: Colors.black,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await inviteMemberModal(
                                userTkn,
                                groupId,
                              );
                            },
                            icon: const Icon(
                              Icons.add,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Expanded(
                    child: FutureBuilder<List<GroupMember>?>(
                        future: getGroupMembers(groupId, userTkn),
                        builder: (context, snapshot) {
                          if (snapshot.hasData &&
                              snapshot.data != null &&
                              snapshot.data!.isNotEmpty) {
                            return RefreshIndicator(
                              displacement: 0,
                              onRefresh: () async {
                                setState(() {});
                              },
                              child: ListView.builder(
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    child: CustomSlide(
                                      title: snapshot.data![index].email!,
                                      subtitle: snapshot.data![index].role,
                                      avatar: snapshot.data![index].username
                                          ?.substring(0, 1)
                                          .toUpperCase(),
                                      actions: [
                                        ActionSlidable(
                                          Icons.delete,
                                          Colors.red,
                                          (() async {
                                            if (kDebugMode) {
                                              print("delete");
                                            }
                                            bool isDelete =
                                                await deleteGroupMember(
                                                    userTkn,
                                                    snapshot.data![index]
                                                        .account_id,
                                                    groupId);

                                            if (isDelete == true &&
                                                mounted &&
                                                userId ==
                                                    snapshot.data![index]
                                                        .account_id) {
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            } else {
                                              setState(() {});
                                            }
                                          }),
                                        ),
                                        ActionSlidable(
                                          Icons.edit,
                                          Colors.grey,
                                          (() async {
                                            await editRole(
                                              userTkn,
                                              snapshot.data![index].account_id,
                                              groupId,
                                            );

                                            if (kDebugMode) {
                                              print("Edit");
                                            }
                                          }),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          } else if (snapshot.hasData &&
                              snapshot.data == null) {
                            return const Center(
                              child: Text(
                                "No member",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal),
                              ),
                            );
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        }),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  TextButton(
                    onPressed: () async {
                      await leaveGroupDialog(userTkn, userId, groupId);
                    },
                    child: const Text(
                      "Leave the groupe",
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }

  Future<bool> apiCall(
      String groupId,
      String userTkn,
      String groupTitle,
      String groupDescription,
      BuildContext context,
      RoundedLoadingButtonController btnController) async {
    final api = singleton.get<APIHelper>();

    try {
      final response = await api.patch('/groups/$groupId', headers: {
        "Authorization": "Bearer $userTkn"
      }, body: {
        "group": {
          "id": groupId,
          "name": groupTitle,
          "description": groupDescription,
        },
        "update_mask": "name,description"
      });

      if (response['statusCode'] != 200) {
        if (!mounted) {
          return false;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to edit group'),
          ),
        );
        btnController.error();
        Future.delayed(const Duration(seconds: 1), () {
          btnController.reset();
        });
        return false;
      } else {
        if (!mounted) {
          return false;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Group edit successfully'),
          ),
        );
        btnController.success();
        Future.delayed(const Duration(seconds: 1), () {
          btnController.reset();
        });
        return true;
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

      return false;
    }
  }

  Future<NewGroup?> getGroupFromAPI(String groupId, String token) async {
    final api = singleton.get<APIHelper>();

    try {
      final group = await api.get(
        "/groups/$groupId",
        headers: {"Authorization": "Bearer $token"},
      );

      if (group['statusCode'] != 200) {
        if (!mounted) {
          return null;
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(group['error'].toString()),
        ));
      }
      return NewGroup.fromJson(group['data']['group']);
    } on DioError catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
      return null;
    }
  }

  // Future<List<Note>?> getGroupNotes(
  //     String token, String id, String groupId) async {
  //   final api = singleton.get<APIHelper>();

  //   final List<Note> notes = [];

  //   try {
  //     final note = await api.get(
  //       "/groups/$groupId/notes",
  //       headers: {"Authorization": "Bearer $token"},
  //     );

  //     if (note['statusCode'] != 200) {
  //       if (!mounted) {
  //         return null;
  //       }
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         content: Text(note['error'].toString()),
  //       ));
  //       return null;
  //     }

  //     print(note["data"]["notes"]);

  //     // if (note["data"]["notes"] != null) {

  //     //   note["data"]["notes"].forEach((note) {
  //     //     print(note);
  //     //     notes.add(Note.fromJson(note));
  //     //   });
  //     // }

  //     return notes;

  //     // return Note.fromJson(note['data']);
  //   } on DioError catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text(e.toString()),
  //     ));
  //     return null;
  //   }
  // }

  Future<List<Note>?> getNotes(String token, String id) async {
    final api = singleton.get<APIHelper>();

    final List<Note> notes = [];

    try {
      final note = await api.get(
        "/notes",
        headers: {"Authorization": "Bearer $token"},
        queryParams: {"author_id": id},
      );

      if (note['statusCode'] != 200) {
        if (!mounted) {
          return null;
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(note['error'].toString()),
        ));
        return null;
      }

      if (note["data"]["notes"] != null) {
        note["data"]["notes"].forEach((note) {
          notes.add(Note.fromJson(note));
        });
      }

      return notes;

      // return Note.fromJson(note['data']);
    } on DioError catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
      return null;
    }
  }

  void refreshingGroup(String tkn, String groupId) {
    var freshGroups = getGroupFromAPI(groupId, tkn);

    setState(() {
      group = freshGroups;
    });
  }

  @override
  Widget build(BuildContext context) {
    String groupId = widget.groupId ?? "";
    if (ModalRoute.of(context)!.settings.arguments != null) {
      groupId = ModalRoute.of(context)!.settings.arguments as String;
    }
    final userProvider = Provider.of<UserProvider>(context);
    refreshingGroup(userProvider.token, groupId);

    FutureBuilder<NewGroup?> groupBuilder = FutureBuilder<NewGroup?>(
      future: group,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            body: BaseContainer(
              titleWidget: Material(
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.group,
                          color: Colors.grey.shade900,
                          size: 30,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          snapshot.data!.name,
                          overflow: TextOverflow.fade,
                          maxLines: 2,
                          style: TextStyle(
                              color: Colors.grey.shade900,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    PopupMenuButton(
                        itemBuilder: ((context) {
                          return [
                            PopupMenuItem(
                              child: TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await openSettings(
                                      userProvider.token,
                                      userProvider.id,
                                      groupId,
                                      snapshot.data!.name,
                                      snapshot.data!.description);
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      color: Colors.grey.shade900,
                                      size: 30,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "Edit",
                                      style: TextStyle(
                                          color: Colors.grey.shade900,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              child: TextButton(
                                onPressed: () async {
                                  await showDialog(
                                      context: context,
                                      builder: ((context) {
                                        return AlertDialog(
                                          title: const Text("Delete Group"),
                                          content: const Text(
                                              "Are you sure you want to delete this group?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                Navigator.pop(context);
                                                Navigator.pop(
                                                    context, "refresh");
                                                await deleteGroup(
                                                  snapshot.data!.id,
                                                  userProvider.token,
                                                );
                                              },
                                              child: const Text("Delete"),
                                            ),
                                          ],
                                        );
                                      }));

                                  if (mounted) {
                                    Navigator.pop(context, "refresh");
                                  }
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      color: Colors.grey.shade900,
                                      size: 30,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "Delete",
                                      style: TextStyle(
                                          color: Colors.grey.shade900,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ];
                        }),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Icon(
                            Icons.more_vert,
                            color: Colors.grey.shade900,
                            size: 32,
                          ),
                        )),
                  ],
                ),
              ),
              primaryColor: Colors.white,
              secondaryColor: Colors.grey.shade900,
              body: SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    children: [
                      GroupInfos(group: snapshot.data!),
                      Expanded(
                        child: FutureBuilder<List<Note>?>(
                            future:
                                getNotes(userProvider.token, userProvider.id),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data!.isEmpty) {
                                  return RefreshIndicator(
                                    onRefresh: () async {
                                      setState(() {});
                                    },
                                    child: ListView(children: const [
                                      Center(
                                        child: Text("No Notes found"),
                                      ),
                                    ]),
                                  );
                                }
                                return RefreshIndicator(
                                  onRefresh: () async {
                                    setState(() {});
                                  },
                                  child: NotesList(
                                    notes: snapshot.data!,
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
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        return Center(
            child: CircularProgressIndicator(
          color: Colors.grey.shade900,
        ));
      },
    );

    return Scaffold(
      body: groupBuilder,
    );
  }

  Future<List<GroupMember>?> getGroupMembers(String id, String token) async {
    List<GroupMember> membersList = [];
    final api = singleton.get<APIHelper>();

    try {
      final members = await api.get(
        "/groups/$id/members",
        headers: {"Authorization": "Bearer $token"},
        // queryParams: {
        //   "group_id": id,
        // },
      );

      if (members['statusCode'] != 200) {
        if (!mounted) {
          return null;
        }
      }

      if (members['data'] == null ||
          members['data'] != null && members['data']["members"] == null) {
        return [];
      }

      for (var member in members['data']["members"]) {
        GroupMember groupMember = GroupMember("", "",
            account_id: member['account_id'],
            role: member["role"],
            created_at: member["created_at"]);

        final user = await api.get(
          "/accounts/${member['account_id']}",
          headers: {"Authorization": "Bearer $token"},
        );

        if (user['statusCode'] == 200) {
          groupMember.setEmail(user['data']["account"]['email']);
          groupMember.setUserName(user['data']["account"]['name']);
        }

        membersList.add(groupMember);
      }

      return membersList;
    } on DioError catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<void> editRole(
      String userTkn, String accountId, String groupId) async {
    return await showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          icon: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close)),
          title: const Text("Edit Role"),
          content: const Text("Select a new role for this member"),
          actions: [
            TextButton(
              onPressed: () async {
                bool isValid =
                    await editGroupMember(userTkn, accountId, groupId, "admin");
                if (isValid && mounted) {
                  Navigator.pop(context);
                  setState(() {});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Something went wrong"),
                    ),
                  );
                }
              },
              child: const Text("Admin"),
            ),
            TextButton(
              onPressed: () async {
                bool isValid =
                    await editGroupMember(userTkn, accountId, groupId, "user");
                if (isValid && mounted) {
                  Navigator.pop(context);
                  setState(() {});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Something went wrong"),
                    ),
                  );
                }
              },
              child: const Text("Member"),
            ),
          ],
        );
      }),
    );
  }

  Future<bool> editGroupMember(
      String userTkn, String accountId, String groupId, String role) async {
    final api = singleton.get<APIHelper>();
    try {
      final response = await api.patch(
        "/groups/$groupId/members/$accountId",
        headers: {"Authorization ": "Bearer $userTkn"},
        body: {
          "member": {
            "role": role,
          },
          "update_mask": "role"
        },
      );

      if (response['statusCode'] != 200) {
        return false;
      }

      return true;
    } on DioError catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }
}
