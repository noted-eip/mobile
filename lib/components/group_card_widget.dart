import 'package:flutter/material.dart';
import 'package:noted_mobile/utils/constant.dart';

class GroupCard extends StatelessWidget {
  const GroupCard({
    Key? key,
    this.groupName = 'group Name',
    this.groupDescription = 'group Description',
    this.groupColor = kPrimaryColor,
    this.groupIcon = Icons.group,
    this.groupId = 'group Id',
    this.groupUserId = 'group User Id',
    this.groupCreatedAt,
    this.groupUpdatedAt,
    this.groupNotesCount = 0,
    this.onTap,
    this.displaySeeMore = false,
  }) : super(key: key);

  final String groupName;
  final String groupDescription;
  final Color groupColor;
  final IconData groupIcon;
  final String? groupId;
  final String? groupUserId;
  final DateTime? groupCreatedAt;
  final DateTime? groupUpdatedAt;
  final int groupNotesCount;
  final bool displaySeeMore;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: groupColor,
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(20),
        height: 200,
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              groupIcon,
              color: Colors.white,
              size: 50,
            ),
            const Spacer(),
            Text(
              groupName,
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            displaySeeMore
                ? const SizedBox()
                : Text(
                    '$groupNotesCount notes',
                    style: const TextStyle(fontSize: 15, color: Colors.white),
                  ),
          ],
        ),
      ),
    );
  }
}
