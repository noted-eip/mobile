import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:noted_mobile/utils/color.dart';
import 'package:noted_mobile/utils/constant.dart';
import 'package:shimmer/shimmer.dart';

class ActionSlidable {
  const ActionSlidable(
    this.icon,
    this.color,
    this.onPressed,
  );

  final IconData icon;
  final Color color;
  final Function() onPressed;
}

class CustomSlide extends StatelessWidget {
  const CustomSlide.empty({
    Key? key,
  }) : this(
            key: key,
            title: null,
            subtitle: null,
            titleWidget: const SizedBox(),
            subtitleWidget: const SizedBox(),
            avatarWidget: const SizedBox(),
            actions: const [],
            avatar: null,
            withWidget: null,
            onTap: null);

  const CustomSlide({
    super.key,
    this.title,
    this.subtitle,
    required this.actions,
    this.subtitleWidget,
    this.titleWidget,
    this.avatar,
    this.withWidget,
    this.avatarWidget,
    this.onTap,
    this.color,
  });

  final String? title;
  final String? subtitle;
  final Widget? titleWidget;
  final Widget? subtitleWidget;
  final Widget? avatarWidget;
  final List<ActionSlidable>? actions;
  final String? avatar;
  final bool? withWidget;
  final VoidCallback? onTap;
  final Color? color;

  SlidableAction _buildAction(ActionSlidable action) {
    return SlidableAction(
      borderRadius: BorderRadius.circular(16),
      onPressed: ((context) {
        action.onPressed();
      }),
      backgroundColor: action.color,
      foregroundColor: Colors.white,
      icon: action.icon,
    );
  }

  bool loading() {
    if (withWidget != null && withWidget!) {
      return (titleWidget == const SizedBox());
    }
    return (title == null);
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = loading();

    Widget buildEmptyCard() {
      return Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          leading: Shimmer.fromColors(
            baseColor: Colors.grey.shade800,
            highlightColor: Colors.grey.shade600,
            child: const CircleAvatar(
              backgroundColor: Colors.white,
            ),
          ),
          title: Shimmer.fromColors(
            baseColor: Colors.grey.shade800,
            highlightColor: Colors.grey.shade600,
            child: Container(
              height: 18,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          subtitle: Shimmer.fromColors(
            baseColor: Colors.grey.shade800,
            highlightColor: Colors.grey.shade600,
            child: Container(
              height: 14,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      );
    }

    Widget buildTitle() {
      if (titleWidget != null) {
        return titleWidget!;
      }
      return Text(title!, style: const TextStyle(color: Colors.white));
    }

    Widget? buildSubtitle() {
      if (withWidget != null && withWidget!) {
        return subtitleWidget;
      }
      return Text(subtitle!, style: const TextStyle(color: Colors.white));
    }

    Widget buildAvatar() {
      if (avatarWidget != null) {
        return avatarWidget!;
      }
      return CircleAvatar(
        backgroundColor: Colors.white,
        child:
            Text(avatar ?? 'A', style: TextStyle(color: Colors.grey.shade900)),
      );
    }

    Widget buildCard() {
      return Slidable(
        key: const ValueKey(0),
        endActionPane: actions != null && actions!.isNotEmpty
            ? ActionPane(
                closeThreshold: 0.5,
                motion: const DrawerMotion(),
                dragDismissible: false,
                children: [
                  ...actions!.map(_buildAction).toList(),
                ],
              )
            : null,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: Gradient.lerp(
                  LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      NotedColors.secondary.withOpacity(0.9),
                      NotedColors.secondary.withOpacity(0.6),
                    ],
                  ),
                  LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      NotedColors.secondary.withOpacity(0.9),
                      NotedColors.secondary.withOpacity(0.6),
                    ],
                  ),
                  0.5,
                ),
              ),
              child: Center(
                child: ListTile(
                  leading: buildAvatar(),
                  title: buildTitle(),
                  subtitle: buildSubtitle(),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return isLoading ? buildEmptyCard() : buildCard();
  }
}
