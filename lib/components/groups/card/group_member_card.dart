import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/common/custom_slide.dart';
import 'package:noted_mobile/data/models/account/account.dart';
import 'package:noted_mobile/data/providers/account_provider.dart';
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

    return account.when(
      data: (account) {
        if (account == null) {
          return const Center(
            child: Text("No members"),
          );
        }

        return _buildCard(account);
      },
      loading: () => Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: const CustomSlide.empty()),
      error: (error, stack) => const Center(
        child: Text("Error"),
      ),
    );
  }

  Widget _buildCard(Account account) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
          color: Colors.red, borderRadius: BorderRadius.circular(16)),
      child: CustomSlide(
        title: account.data.email,
        subtitle: widget.memberData.isAdmin ? "Admin" : "User",
        avatar: account.data.name.substring(0, 1).toUpperCase(),
        actions: widget.actions,
        color: Colors.blueGrey.shade800,
      ),
    );
  }
}
