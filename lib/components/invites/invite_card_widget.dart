import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:noted_mobile/components/common/custom_slide.dart';
import 'package:noted_mobile/components/common/custom_toast.dart';
import 'package:noted_mobile/data/models/invite/invite.dart';
import 'package:noted_mobile/data/providers/account_provider.dart';
import 'package:noted_mobile/data/providers/group_provider.dart';
import 'package:noted_mobile/data/providers/invite_provider.dart';
import 'package:noted_mobile/utils/string_extension.dart';
import 'package:shimmer/shimmer.dart';

//TODO: Factorize the code for invitations and notifications

class InviteCard extends ConsumerStatefulWidget {
  const InviteCard({
    required this.invite,
    required this.isSentInvite,
    this.isInGroup,
    this.onRefresh,
    this.canRevoke = false,
    super.key,
  });

  final Invite invite;
  final bool isSentInvite;
  final bool? isInGroup;
  final VoidCallback? onRefresh;
  final bool canRevoke;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InviteCardState();
}

class _InviteCardState extends ConsumerState<InviteCard> {
  Future<bool> acceptInvite(
      {required String inviteId, required String? groupId}) async {
    if (groupId == null) {
      return false;
    }

    try {
      await ref
          .read(inviteClientProvider)
          .acceptInvite(inviteId: inviteId, groupId: groupId);

      ref.invalidate(groupsProvider);
      if (mounted) {
        CustomToast.show(
          message: "invites.accepted".tr(),
          type: ToastType.success,
          context: context,
          gravity: ToastGravity.BOTTOM,
        );
      }

      return true;
    } catch (e) {
      if (mounted) {
        CustomToast.show(
          message: e.toString().capitalize(),
          type: ToastType.error,
          context: context,
          gravity: ToastGravity.BOTTOM,
        );
      }

      return false;
    }
  }

  Future<bool> declineInvite(
      {required String inviteId, required String? groupId}) async {
    if (groupId == null) {
      return false;
    }

    try {
      await ref
          .read(inviteClientProvider)
          .denyInvite(inviteId: inviteId, groupId: groupId);
      if (mounted) {
        CustomToast.show(
          message: "invites.declined".tr(),
          type: ToastType.success,
          context: context,
          gravity: ToastGravity.BOTTOM,
        );
      }

      return true;
    } catch (e) {
      if (mounted) {
        CustomToast.show(
          message: e.toString().capitalize(),
          type: ToastType.error,
          context: context,
          gravity: ToastGravity.BOTTOM,
        );
      }

      return false;
    }
  }

  Future<bool> revokeInvite(
      {required String inviteId, required String? groupId}) async {
    if (groupId == null) {
      return false;
    }
    try {
      await ref
          .read(inviteClientProvider)
          .revokeInvite(inviteId: inviteId, groupId: groupId);
      if (mounted) {
        CustomToast.show(
          message: "invites.revoked".tr(),
          type: ToastType.success,
          context: context,
          gravity: ToastGravity.BOTTOM,
        );
      }

      return true;
    } catch (e) {
      if (mounted) {
        CustomToast.show(
          message: e.toString().capitalize(),
          type: ToastType.error,
          context: context,
          gravity: ToastGravity.BOTTOM,
        );
      }

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
    final bool isPendingGroupInvites =
        widget.isInGroup != null && widget.isInGroup!;

    if (!isPendingGroupInvites && widget.invite.group_id != null) {
      final group = ref.watch(groupProvider(widget.invite.group_id!));
      group.when(data: (group) {
        if (group == null) {
          setState(() {
            groupAlive = false;
            titleWidget = Text(
              "invites.invality".tr(),
              style: const TextStyle(color: Colors.white),
            );
          });

          return null;
        }
        setState(() {
          groupAlive = true;
          titleWidget =
              Text(group.name, style: const TextStyle(color: Colors.white));
        });

        return null;
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
        return null;
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
          return null;
        }
        setState(() {
          if (widget.isSentInvite) {
            titleWidget = Text(
              "${"invites.to".tr()}${account.data.email}",
              style: const TextStyle(color: Colors.white, fontSize: 14),
            );
          } else {
            titleWidget = Text("${"invites.from".tr()}${account.data.email}",
                style: const TextStyle(color: Colors.white, fontSize: 14));
          }
        });

        return null;
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
        return null;
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
          subtitleWidget = Text("${"invites.to".tr()}${account.data.email}",
              style: const TextStyle(color: Colors.white, fontSize: 12));
        } else {
          subtitleWidget = Text("${"invites.from".tr()}${account.data.email}",
              style: const TextStyle(color: Colors.white, fontSize: 12));
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
          ? widget.canRevoke
              ? [
                  ActionSlidable(
                    Icons.cancel_schedule_send,
                    Colors.grey,
                    () async {
                      await revokeInvite(
                              inviteId: widget.invite.id,
                              groupId: widget.invite.group_id)
                          .then((value) =>
                              invalidateInvites(widget.isSentInvite));
                      widget.onRefresh?.call();
                    },
                  ),
                ]
              : null
          : [
              ActionSlidable(
                Icons.check,
                Colors.green,
                () async {
                  if (await acceptInvite(
                    inviteId: widget.invite.id,
                    groupId: widget.invite.group_id,
                  )) {
                    invalidateInvites(widget.isSentInvite);
                  }
                },
              ),
              ActionSlidable(
                Icons.close,
                Colors.red,
                () async {
                  if (await declineInvite(
                    inviteId: widget.invite.id,
                    groupId: widget.invite.group_id,
                  )) {
                    invalidateInvites(widget.isSentInvite);
                  }
                },
              ),
            ],
    );
  }
}
