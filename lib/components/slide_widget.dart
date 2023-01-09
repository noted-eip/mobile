import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
  const CustomSlide(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.actions,
      this.avatar});

  final String title;
  final String subtitle;
  final List<ActionSlidable> actions;
  final String? avatar;

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

  @override
  Widget build(BuildContext context) {
    return Slidable(
        key: const ValueKey(0),
        endActionPane: actions.isNotEmpty
            ? ActionPane(
                closeThreshold: 0.5,
                motion: const DrawerMotion(),
                dragDismissible: false,
                children: [
                  ...actions.map(_buildAction).toList(),
                ],
              )
            : null,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(avatar ?? 'A',
                  style: const TextStyle(color: Colors.black)),
            ),
            title: Text(title, style: const TextStyle(color: Colors.white)),
            subtitle:
                Text(subtitle, style: const TextStyle(color: Colors.white)),
          ),
        ));
  }
}
