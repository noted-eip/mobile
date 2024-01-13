import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/common/custom_slide.dart';
import 'package:noted_mobile/data/models/account/account.dart';
import 'package:noted_mobile/data/providers/account_provider.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:openapi/openapi.dart';

class GroupMemberCard extends ConsumerStatefulWidget {
  const GroupMemberCard(
      {required this.memberData, required this.actions, super.key});

  final V1GroupMember memberData;
  final List<ActionSlidable> actions;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GroupMemberCardState();
}

class _GroupMemberCardState extends ConsumerState<GroupMemberCard> {
  @override
  Widget build(BuildContext context) {
    final account = ref.watch(accountProvider(widget.memberData.accountId));
    final userEmail = ref.read(userProvider).email;

    return account.when(
      data: (account) {
        if (account == null) {
          return const Center(
            child: Text("Pas de compte trouvé"),
          );
        }

        return _buildCard(account, userEmail);
      },
      loading: () => Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: const CustomSlide.empty()),
      error: (error, stack) => const Center(
        child: Text("Error"),
      ),
    );
  }

  Widget _buildCard(Account account, String userEmail) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
          color: Colors.red, borderRadius: BorderRadius.circular(16)),
      child: CustomSlide(
        color: account.data.email == userEmail
            ? Colors.blueGrey.shade700
            : Colors.blueGrey.shade900,
        onTap: () {},
        actions: widget.actions,
        titleWidget: Text(
          account.data.email,
          maxLines: 2,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
        withWidget: true,
        subtitleWidget: Text(
          widget.memberData.isAdmin
              ? "member.admin".tr()
              : "member.member".tr(),
          maxLines: 2,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
        avatarWidget: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: account.data.email == userEmail
                  ? Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 1,
                    )
                  : null,
            ),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            child: Text(
              account.data.name.substring(0, 1).toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Colors.white,
              ),
            )),
      ),
    );
  }
}
