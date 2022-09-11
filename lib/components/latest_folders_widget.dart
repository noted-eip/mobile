import 'package:flutter/material.dart';
import 'package:noted_mobile/components/folder_card_widget.dart';
import 'package:noted_mobile/data/fake_folders_list.dart';
import 'package:noted_mobile/data/folder.dart';

class LatestFolders extends StatelessWidget {
  const LatestFolders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Latest Folders", style: TextStyle(fontSize: 20)),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                Folder folder = kFakeFoldersList[index];
                return index == 4
                    ? FolderCard(
                        folderName: "See More ...",
                        folderIcon: Icons.add,
                        displaySeeMore: true,
                        onTap: () {
                          Navigator.pushNamed(context, '/folders');
                        },
                      )
                    : FolderCard(
                        folderName: folder.title,
                        folderNotesCount: folder.nbNotes,
                        onTap: () {
                          Navigator.pushNamed(context, '/folder-detail',
                              arguments: folder.id);
                        },
                      );
              },
              itemCount: 5,
              scrollDirection: Axis.horizontal,
            ),
          ),
        ],
      ),
    );
  }
}
