import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/slide_widget.dart';
import 'package:noted_mobile/data/providers/account_provider.dart';
import 'package:noted_mobile/data/providers/group_provider.dart';
import 'package:noted_mobile/data/providers/invite_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/pages/notification_page.dart';
import 'package:shimmer/shimmer.dart';

//TODO: Factorize the code

class InviteCard extends ConsumerStatefulWidget {
  const InviteCard({
    required this.invite,
    required this.isSentInvite,
    this.isInGroup,
    super.key,
  });

  final Invite invite;
  final bool isSentInvite;
  final bool? isInGroup;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InviteCardState();
}

class _InviteCardState extends ConsumerState<InviteCard> {
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

  Widget loadingWidget = Shimmer.fromColors(
      baseColor: Colors.white70,
      highlightColor: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        height: 20,
        width: 30,
      ));

  late Widget titleWidget;
  late Widget subtitleWidget;
  bool groupAlive = false;

  @override
  Widget build(BuildContext context) {
    final userTkn = ref.read(userProvider).token;

    final bool isPendingGroupInvites =
        widget.isInGroup != null && widget.isInGroup!;

    if (!isPendingGroupInvites) {
      final group = ref.watch(groupProvider(widget.invite.group_id));
      group.when(data: (group) {
        if (group == null) {
          setState(() {
            groupAlive = false;
            titleWidget = const Text(
              "Group not found",
              style: TextStyle(color: Colors.white),
            );
          });
          return const SizedBox();
        }
        setState(() {
          groupAlive = true;
          titleWidget = Text(group.data.name,
              style: const TextStyle(color: Colors.white));
        });

        return const SizedBox();
      }, error: ((error, stackTrace) {
        setState(() {
          groupAlive = false;
          titleWidget = Text(error.toString(),
              style: const TextStyle(color: Colors.white));
        });
        return Text(error.toString());
      }), loading: (() {
        setState(() {
          titleWidget = loadingWidget;
        });
        return const SizedBox();
      }));
    } else {
      setState(() {
        groupAlive = true;
      });
      final recipientAccount =
          ref.watch(accountProvider(widget.invite.recipient_account_id));

      recipientAccount.when(data: (account) {
        if (account == null) {
          setState(() {
            titleWidget = loadingWidget;
          });
          return const SizedBox();
        }
        setState(() {
          titleWidget = Text("To: ${account.data.name.toUpperCase()}",
              style: const TextStyle(color: Colors.white));
        });

        return const SizedBox();
      }, error: ((error, stackTrace) {
        setState(() {
          titleWidget = Text(error.toString(),
              style: const TextStyle(color: Colors.white));
        });
        return Text(error.toString());
      }), loading: (() {
        setState(() {
          titleWidget = loadingWidget;
        });
        return const SizedBox();
      }));
    }

    final memberId = widget.isSentInvite && !isPendingGroupInvites
        ? widget.invite.recipient_account_id
        : widget.invite.sender_account_id;

    final account = ref.watch(accountProvider(memberId));

    account.when(data: (account) {
      if (account == null) {
        setState(() {
          subtitleWidget = loadingWidget;
        });
        return const SizedBox();
      }
      setState(() {
        if (!isPendingGroupInvites) {
          subtitleWidget = Text("To: ${account.data.email}",
              style: const TextStyle(color: Colors.white));
        } else {
          subtitleWidget = Text("From: ${account.data.email}",
              style: const TextStyle(color: Colors.white));
        }
      });

      return const SizedBox();
    }, error: ((error, stackTrace) {
      setState(() {
        subtitleWidget =
            Text(error.toString(), style: const TextStyle(color: Colors.white));
      });
      return Text(error.toString());
    }), loading: (() {
      setState(() {
        subtitleWidget = loadingWidget;
      });
      return const SizedBox();
    }));

    return CustomSlide(
      titleWidget: titleWidget,
      subtitleWidget: groupAlive ? subtitleWidget : null,
      withWidget: true,
      avatarWidget: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white10,
        ),
        height: 40,
        width: 40,
        child: Icon(
          groupAlive ? Icons.group_add_rounded : Icons.error_outline_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
      actions: widget.isSentInvite
          ? null
          : [
              ActionSlidable(
                Icons.check,
                Colors.green,
                () async {
                  if (await acceptInvite(userTkn, widget.invite.id)) {
                    invalidateInvites(widget.isSentInvite);
                  }
                },
              ),
              ActionSlidable(
                Icons.close,
                Colors.red,
                () async {
                  if (await declineInvite(userTkn, widget.invite.id)) {
                    invalidateInvites(widget.isSentInvite);
                  }
                },
              ),
            ],
    );
  }
}
