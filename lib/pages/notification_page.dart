// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/common/base_container.dart';
import 'package:noted_mobile/components/invite_card_widget.dart';
import 'package:noted_mobile/data/providers/invite_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';

class Invite {
  final String? title;
  final String? subtitle;
  final String? groupName;
  final String? groupDescription;
  final String? senderEmail;

  final String id;
  final String group_id;
  final String sender_account_id;
  final String recipient_account_id;

  Invite({
    this.groupName,
    this.groupDescription,
    this.senderEmail,
    this.title,
    this.subtitle,
    required this.id,
    required this.group_id,
    required this.sender_account_id,
    required this.recipient_account_id,
  });

  factory Invite.fromJson(Map<String, dynamic> json) {
    return Invite(
      id: json['id'] ?? "",
      group_id: json['group_id'] ?? "",
      sender_account_id: json['sender_account_id'] ?? "",
      recipient_account_id: json['recipient_account_id'] ?? "",
    );
  }
}

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  Future<bool> acceptInvite(String tkn, String inviteId) async {
    try {
      await ref.read(inviteClientProvider).acceptInvite(inviteId, tkn);

      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
      return false;
    }
  }

  Future<bool> declineInvite(String tkn, String inviteId) async {
    try {
      await ref.read(inviteClientProvider).denyInvite(inviteId, tkn);

      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
      return false;
    }
  }

  void invalidateInvites(bool isSendInvite) {
    if (isSendInvite) {
      ref.invalidate(sendInvitesProvider);
    } else {
      ref.invalidate(receiveInvitesProvider);
    }
  }

  Widget buildInvites({
    required String token,
    required AsyncValue<List<Invite>?> invites,
    required bool isSentInvite,
  }) {
    return invites.when(data: ((data) {
      if (data == null) {
        return const Center(
          child: Text("No invitations chh"),
        );
      }

      if (data.isEmpty) {
        return RefreshIndicator(
          onRefresh: () async {
            invalidateInvites(isSentInvite);
          },
          child: ListView(
            padding: EdgeInsets.zero,
            children: const [
              Center(child: Text("No invitations")),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          invalidateInvites(isSentInvite);
        },
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            final Invite invite = data[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0, left: 16, right: 16),
              child: InviteCard(invite: invite, isSentInvite: isSentInvite),
            );
          },
          itemCount: data.length,
        ),
      );
    }), error: ((error, stackTrace) {
      return const Center(child: Text("Error"));
    }), loading: () {
      return const Center(child: CircularProgressIndicator());
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider);
    final sendInvites = ref.watch(sendInvitesProvider);
    final receiveInvites = ref.watch(receiveInvitesProvider);

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
                    buildInvites(
                      token: user.token,
                      invites: sendInvites,
                      isSentInvite: true,
                    ),
                    buildInvites(
                      token: user.token,
                      invites: receiveInvites,
                      isSentInvite: false,
                    ),
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
