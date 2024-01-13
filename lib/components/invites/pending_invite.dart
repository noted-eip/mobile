import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/invites/invite_card_widget.dart';
import 'package:noted_mobile/components/common/custom_slide.dart';
import 'package:noted_mobile/data/models/invite/invite.dart';
import 'package:noted_mobile/data/providers/group_provider.dart';
import 'package:noted_mobile/data/providers/invite_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:openapi/openapi.dart';

class ListInvitesWidget extends ConsumerStatefulWidget {
  const ListInvitesWidget({
    this.group,
    this.isSender,
    super.key,
  });

  final bool? isSender;
  final V1Group? group;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ListInvitesWidgetState();
}

class _ListInvitesWidgetState extends ConsumerState<ListInvitesWidget> {
  void invalidateProvider() {
    if (widget.group != null) {
      ref.invalidate(groupInvitesProvider(widget.group!.id));
      ref.invalidate(groupInvitesProvider);
    } else if (widget.isSender != null && widget.isSender!) {
      ref.invalidate(sendInvitesProvider);
    } else {
      ref.invalidate(receiveInvitesProvider);
    }
    ref.invalidate(groupsProvider);
  }

  bool canRevoke = false;

  @override
  void initState() {
    var userId = ref.read(userProvider).id;

    if (widget.group != null && widget.group!.members != null) {
      canRevoke = widget.group!.members!
          .firstWhere((element) => element.accountId == userId)
          .isAdmin;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final pendingGroupInvites =
        ref.watch(groupInvitesProvider(widget.group!.id));
    final pendingSendInvites = ref.watch(sendInvitesProvider);
    final pendingReceiveInvites = ref.watch(receiveInvitesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "invites.pending".tr(),
          textAlign: TextAlign.start,
          style: const TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 32,
        ),
        if (widget.group != null)
          Expanded(
            child: pendingGroupInvites.when(
              data: ((data) {
                if (data == null || data.isEmpty) {
                  return RefreshIndicator(
                    triggerMode: RefreshIndicatorTriggerMode.onEdge,
                    displacement: 0,
                    onRefresh: () async {
                      invalidateProvider();
                    },
                    child: ListView(
                      children: [
                        Center(
                          child: Text(
                            "invites.empty".tr(),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  displacement: 0,
                  onRefresh: () async {
                    invalidateProvider();
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
                          canRevoke: canRevoke,
                          onRefresh: () {
                            invalidateProvider();
                          },
                        ),
                      );
                    },
                  ),
                );
              }),
              error: ((error, stackTrace) {
                return Center(child: Text(error.toString()));
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
                      invalidateProvider();
                    },
                    child: ListView(
                      children: [
                        Center(
                          child: Text(
                            "invites.empty".tr(),
                          ),
                        ),
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
                        ),
                      );
                    },
                  ),
                );
              }),
              error: ((error, stackTrace) {
                return Center(child: Text(error.toString()));
              }),
              loading: () => const Center(
                child: CircularProgressIndicator(),
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
                      invalidateProvider();
                    },
                    child: ListView(
                      children: [
                        Center(
                          child: Text(
                            "invites.empty".tr(),
                          ),
                        ),
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
                        ),
                      );
                    },
                  ),
                );
              }),
              error: (error, stackTrace) =>
                  Center(child: Text(error.toString())),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
