import 'package:flutter/material.dart';
import 'package:noted_mobile/components/common/base_container.dart';
import 'package:noted_mobile/components/folder_card_widget.dart';
import 'package:noted_mobile/data/fake_folders_list.dart';
import 'package:noted_mobile/data/folder.dart';

class FoldersListPage extends StatelessWidget {
  const FoldersListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseContainer(
      titleWidget: const Text(
        "All Folders",
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemBuilder: (context, index) {
                  Folder folder = kFakeFoldersList[index];
                  return FolderCard(
                    folderName: folder.title,
                    folderCreatedAt: DateTime.now(),
                    folderUpdatedAt: DateTime.now(),
                    folderNotesCount: folder.nbNotes,
                    onTap: () {
                      Navigator.pushNamed(context, '/folder-detail',
                          arguments: folder.id);
                    },
                    folderId: folder.id,
                    folderUserId: folder.author,
                  );
                },
                itemCount: kFakeFoldersList.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
