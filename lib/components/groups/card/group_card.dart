import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:noted_mobile/utils/constant.dart';
import 'package:noted_mobile/utils/string_extension.dart';
import 'package:shimmer/shimmer.dart';

class GroupCard extends StatelessWidget {
  const GroupCard.empty({
    Key? key,
  }) : this(key: key);

  const GroupCard({
    Key? key,
    this.groupName,
    this.groupDescription,
    this.groupColor = kPrimaryColor,
    this.groupIcon = Icons.group,
    this.groupId,
    this.groupNotesCount = 0,
    this.onTap,
    this.displaySeeMore = false,
  }) : super(key: key);

  final String? groupName;
  final String? groupDescription;
  final Color? groupColor;
  final IconData? groupIcon;
  final String? groupId;
  final int? groupNotesCount;
  final bool displaySeeMore;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final isLoadingCard = groupName == null;

    Widget buildEmptyCard() {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade800,
        highlightColor: Colors.grey.shade700,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(20),
          height: 200,
          width: 140,
        ),
      );
    }

    Widget buildCard() {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: Gradient.lerp(
              LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  groupColor!.withOpacity(0.9),
                  groupColor!.withOpacity(0.6),
                ],
              ),
              LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  groupColor!.withOpacity(0.9),
                  groupColor!.withOpacity(0.6),
                ],
              ),
              0.5,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          padding: const EdgeInsets.all(20),
          height: 200,
          width: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                groupIcon,
                color: Colors.white,
                size: 50,
              ),
              const Spacer(),
              SizedBox(
                height: 42,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AutoSizeText(
                      groupName!.capitalize(),
                      textAlign: TextAlign.start,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return isLoadingCard ? buildEmptyCard() : buildCard();
  }
}
