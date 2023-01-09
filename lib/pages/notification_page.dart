// ignore_for_file: non_constant_identifier_names

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:noted_mobile/components/common/base_container.dart';
import 'package:noted_mobile/components/slide_widget.dart';
import 'package:noted_mobile/data/services/api_helper.dart';
import 'package:noted_mobile/data/services/dio_singleton.dart';
import 'package:noted_mobile/data/user_provider.dart';
import 'package:provider/provider.dart';

class Invite {
  final String? title;
  final String? subtitle;

  final String id;
  final String group_id;
  final String sender_account_id;
  // final String recipient_account_id;

  Invite({
    this.title,
    this.subtitle,
    required this.id,
    required this.group_id,
    required this.sender_account_id,
    // required this.recipient_account_id,
  });

  factory Invite.fromJson(Map<String, dynamic> json) {
    return Invite(
      id: json['id'],
      group_id: json['group_id'],
      sender_account_id: json['sender_account_id'],
      // recipient_account_id: json['recipient_account_id'],
    );
  }
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Future<List<Invite>?> invites;
  late Future<List<Invite>?> sentInvites;

  Future<bool> acceptInvite(String tkn, String inviteId) async {
    final api = singleton.get<APIHelper>();

    try {
      final invites = await api.post(
        "/invites/$inviteId/accept",
        headers: {"Authorization": "Bearer $tkn"},
      );

      if (invites['statusCode'] != 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(invites['error']),
          ));
        }

        return false;
      }

      return true;
    } on DioError catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
      return false;
    }
  }

  Future<bool> declineInvite(String tkn, String inviteId) async {
    final api = singleton.get<APIHelper>();

    try {
      final invites = await api.post(
        "/invites/$inviteId/deny",
        headers: {"Authorization": "Bearer $tkn"},
      );

      if (invites['statusCode'] != 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(invites['error']),
          ));
        }

        return false;
      }

      return true;
    } on DioError catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
      return false;
    }
  }

  Future<List<Invite>?> getInvites(
      String tkn, String userId, bool isSendInvite) async {
    List<Invite> invitesList = [];
    final api = singleton.get<APIHelper>();

    final inviteSendQuery = {
      "sender_account_id": userId,
    };
    final inviteReceiveQuery = {
      "recipient_account_id": userId,
    };

    try {
      final invites = await api.get(
        "/invites",
        headers: {"Authorization": "Bearer $tkn"},
        queryParams: isSendInvite ? inviteSendQuery : inviteReceiveQuery,
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

  void refreshingInvites(String tkn, String userId, bool isSendInvite) {
    var freshInvites = getInvites(tkn, userId, isSendInvite);

    setState(() {
      if (isSendInvite) {
        sentInvites = freshInvites;
      } else {
        invites = freshInvites;
      }
    });
  }

  Widget buildSentInvites(String token, String userId) {
    return FutureBuilder<List<Invite>?>(
        future: sentInvites,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  refreshingInvites(token, userId, true);
                },
                child: ListView(
                  children: const [
                    Center(child: Text("No invitations")),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                refreshingInvites(token, userId, true);
              },
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                    child: CustomSlide(
                        title: snapshot.data![index].id,
                        subtitle: snapshot.data![index].group_id,
                        actions: const []),
                  );
                },
                itemCount: snapshot.data!.length,
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error"));
          }

          return const Center(child: CircularProgressIndicator());
        });
  }

  Widget buildReceiveInvites(String token, String userId) {
    return FutureBuilder<List<Invite>?>(
        future: invites,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  refreshingInvites(token, userId, false);
                },
                child: ListView(
                  children: const [
                    Center(child: Text("No invitations")),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                refreshingInvites(token, userId, false);
              },
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return Container(
                    margin:
                        const EdgeInsets.only(bottom: 16, right: 16, left: 16),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: CustomSlide(
                      title: "Invitation",
                      subtitle: "You have been invited to join a new group",
                      actions: [
                        ActionSlidable(
                          Icons.close,
                          Colors.red,
                          () async {
                            bool isValid = await declineInvite(
                                token, snapshot.data![index].id);
                            if (isValid) {
                              if (!mounted) {
                                return;
                              }
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("Denied"),
                              ));
                              refreshingInvites(token, userId, false);
                            } else {
                              if (!mounted) {
                                return;
                              }
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("Error"),
                              ));
                            }
                          },
                        ),
                        ActionSlidable(
                          Icons.check,
                          Colors.green,
                          () async {
                            bool isValid = await acceptInvite(
                                token, snapshot.data![index].id);
                            if (isValid) {
                              if (!mounted) {
                                return;
                              }
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("Accepted"),
                              ));
                              refreshingInvites(token, userId, false);
                            } else {
                              if (!mounted) {
                                return;
                              }
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("Error"),
                              ));
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
                itemCount: snapshot.data!.length,
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Error"),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: true,
    );

    refreshingInvites(userProvider.token, userProvider.id, true);
    refreshingInvites(userProvider.token, userProvider.id, false);

    return Scaffold(
      body: BaseContainer(
        notif: true,
        titleWidget: const Text("Invitations"),
        body: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const SizedBox(
                height: 16,
              ),
              TabBar(
                indicatorColor: Colors.grey.shade900,
                tabs: const [
                  Tab(
                    text: "Sent",
                  ),
                  Tab(
                    text: "Received",
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    buildSentInvites(userProvider.token, userProvider.id),
                    buildReceiveInvites(userProvider.token, userProvider.id),
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
