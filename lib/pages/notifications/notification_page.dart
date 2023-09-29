import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/common/base_container.dart';
import 'package:noted_mobile/components/invites/invite_card_widget.dart';
import 'package:noted_mobile/data/models/invite/invite.dart';
import 'package:noted_mobile/data/providers/invite_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
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
        return RefreshIndicator(
          onRefresh: () async {
            invalidateInvites(isSentInvite);
          },
          child: ListView(
            padding: EdgeInsets.zero,
            children: const [
              Center(child: Text("No invitations found")),
            ],
          ),
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
              Center(child: Text("No invitations found")),
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
        openDrawer: false,
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
