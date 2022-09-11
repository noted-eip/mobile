import 'package:flutter/material.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    Key? key,
    this.title = 'file Name',
    this.description = 'file Description',
    this.color = Colors.grey,
    this.icon = Icons.description,
    this.id = 'file Id',
    this.authorId = 'file User Id',
    this.createdAt,
    this.updateAt,
    this.onTap,
    this.displaySeeMore = false,
    this.baseColor,
  }) : super(key: key);

  final String title;
  final String description;
  final Color color;
  final IconData icon;
  final String? id;
  final String? authorId;
  final DateTime? createdAt;
  final DateTime? updateAt;
  final bool displaySeeMore;
  final Function()? onTap;
  final Color? baseColor;

  String formatDate(DateTime? date) {
    if (date == null) {
      return '';
    }
    return '${updateAt!.day}/${updateAt!.month}/${updateAt!.year} : ${updateAt!.hour}:${updateAt!.minute}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              height: 40,
              width: 40,
              child: Icon(
                icon,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      TextStyle(fontSize: 18, color: baseColor ?? Colors.black),
                ),
                displaySeeMore
                    ? const SizedBox()
                    : Row(
                        children: [
                          const Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: 15,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            authorId!,
                            style: TextStyle(
                                fontSize: 15, color: baseColor ?? Colors.black),
                          ),
                        ],
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
