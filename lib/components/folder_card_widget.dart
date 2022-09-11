import 'package:flutter/material.dart';

class FolderCard extends StatelessWidget {
  const FolderCard({
    Key? key,
    this.folderName = 'Folder Name',
    this.folderDescription = 'Folder Description',
    this.folderColor = Colors.grey,
    this.folderIcon = Icons.folder,
    this.folderId = 'Folder Id',
    this.folderUserId = 'Folder User Id',
    this.folderCreatedAt,
    this.folderUpdatedAt,
    this.folderNotesCount = 0,
    this.onTap,
    this.displaySeeMore = false,
  }) : super(key: key);

  final String folderName;
  final String folderDescription;
  final Color folderColor;
  final IconData folderIcon;
  final String? folderId;
  final String? folderUserId;
  final DateTime? folderCreatedAt;
  final DateTime? folderUpdatedAt;
  final int folderNotesCount;
  final bool displaySeeMore;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: folderColor,
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
              folderIcon,
              color: Colors.white,
              size: 50,
            ),
            const Spacer(),
            Text(
              folderName,
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            displaySeeMore
                ? const SizedBox()
                : Text('$folderNotesCount notes',
                    style: const TextStyle(fontSize: 15, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
