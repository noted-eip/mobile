import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/invite_card_widget.dart';
import 'package:noted_mobile/components/slide_widget.dart';
import 'package:noted_mobile/data/providers/invite_provider.dart';
import 'package:noted_mobile/pages/notification_page.dart';

//TODO: gérer l'affichage des invites dans un group -> l'user doit pouvoir voir les invites qu'il a envoyé

class ListInvitesWidget extends ConsumerStatefulWidget {
  const ListInvitesWidget({
    this.groupId,
    this.isSender,
    super.key,
  });

  final String? groupId;
  final bool? isSender;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ListInvitesWidgetState();
}

class _ListInvitesWidgetState extends ConsumerState<ListInvitesWidget> {
  late ProviderListenable provider;

  void invalidateProvider() {
    if (widget.groupId != null) {
      ref.invalidate(groupInvitesProvider(widget.groupId!));
      ref.invalidate(groupInvitesProvider);
    } else if (widget.isSender != null && widget.isSender!) {
      ref.invalidate(sendInvitesProvider);
    } else {
      ref.invalidate(receiveInvitesProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingGroupInvites =
        ref.watch(groupInvitesProvider(widget.groupId!));
    final pendingSendInvites = ref.watch(sendInvitesProvider);
    final pendingReceiveInvites = ref.watch(receiveInvitesProvider);

    return Column(
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
        if (widget.groupId != null)
          Expanded(
            child: pendingGroupInvites.when(
              data: ((data) {
                if (data == null || data.isEmpty) {
                  return RefreshIndicator(
                    triggerMode: RefreshIndicatorTriggerMode.onEdge,
                    displacement: 0,
                    onRefresh: () async {
                      if (widget.groupId != null) {
                        ref.invalidate(groupInvitesProvider(widget.groupId!));
                        ref.invalidate(groupInvitesProvider);
                      } else if (widget.isSender != null && widget.isSender!) {
                        ref.invalidate(sendInvitesProvider);
                      } else {
                        ref.invalidate(receiveInvitesProvider);
                      }
                    },
                    child: ListView(
                      children: const [
                        Center(child: Text("No pending invites")),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  displacement: 0,
                  onRefresh: () async {
                    if (widget.groupId != null) {
                      ref.invalidate(groupInvitesProvider(widget.groupId!));
                      ref.invalidate(groupInvitesProvider);
                    } else if (widget.isSender != null && widget.isSender!) {
                      ref.invalidate(sendInvitesProvider);
                    } else {
                      ref.invalidate(receiveInvitesProvider);
                    }
                  },
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      Invite invite = data[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InviteCard(
                          invite: invite,
                          isSentInvite: true,
                          isInGroup: true,
                        ),
                      );
                    },
                  ),
                );
              }),
              error: ((error, stackTrace) {
                return const Center(child: Text("Error"));
              }),
              loading: () => ListView.builder(
                itemCount: 2,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: const CustomSlide.empty(),
                  );
                },
              ),
            ),
          ),
        if (widget.isSender != null && widget.isSender!)
          Expanded(
            child: pendingSendInvites.when(
              data: ((data) {
                if (data == null || data.isEmpty) {
                  return RefreshIndicator(
                    displacement: 0,
                    onRefresh: () async {
                      if (widget.groupId != null) {
                        ref.invalidate(groupInvitesProvider(widget.groupId!));
                        ref.invalidate(groupInvitesProvider);
                      } else if (widget.isSender != null && widget.isSender!) {
                        ref.invalidate(sendInvitesProvider);
                      } else {
                        ref.invalidate(receiveInvitesProvider);
                      }
                    },
                    child: ListView(
                      children: const [
                        Center(child: Text("No pending invites")),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  displacement: 0,
                  onRefresh: () async {},
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: CustomSlide(
                            title: "Invite",
                            subtitle: data[index].id,
                            actions: const [],
                          ));
                    },
                  ),
                );
              }),
              error: ((error, stackTrace) {
                return const Center(child: Text("Error"));
              }),
              loading: () => const Center(
                child: Text("CACA LOADING ...."),
              ),
            ),
          ),
        if (widget.isSender != null && !widget.isSender!)
          Expanded(
            child: pendingReceiveInvites.when(
              data: ((data) {
                if (data == null || data.isEmpty) {
                  return RefreshIndicator(
                    displacement: 0,
                    onRefresh: () async {
                      if (widget.groupId != null) {
                        ref.invalidate(groupInvitesProvider(widget.groupId!));
                        ref.invalidate(groupInvitesProvider);
                      } else if (widget.isSender != null && widget.isSender!) {
                        ref.invalidate(sendInvitesProvider);
                      } else {
                        ref.invalidate(receiveInvitesProvider);
                      }
                    },
                    child: ListView(
                      children: const [
                        Center(child: Text("No pending invites")),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  displacement: 0,
                  onRefresh: () async {},
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: CustomSlide(
                            title: "Invite",
                            subtitle: data[index].id,
                            actions: const [],
                          ));
                    },
                  ),
                );
              }),
              error: ((error, stackTrace) {
                return const Center(child: Text("Error"));
              }),
              loading: () => const Center(
                child: Text("CACA LOADING ...."),
              ),
            ),
          ),
      ],
    );
  }
}
