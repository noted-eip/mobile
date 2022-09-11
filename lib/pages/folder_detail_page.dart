import 'package:flutter/material.dart';
import 'package:noted_mobile/components/common/base_container.dart';
import 'package:noted_mobile/components/notes_list_widget.dart';
import 'package:noted_mobile/components/folder_info_widget.dart';
import 'package:noted_mobile/data/fake_folders_list.dart';
import 'package:noted_mobile/data/folder.dart';

// TODO:
//ajouter un scroll sur la page entière et faire disparaitre le header
//avec l'effet d'apple en gardant le nom du fichier dans l'app bar
// Voir pour refaire le design de la page

class FolderDetailPage extends StatelessWidget {
  const FolderDetailPage({Key? key}) : super(key: key);

  // final String folderId;
  Folder getFolder(String folderId) {
    return kFakeFoldersList.firstWhere((element) => element.id == folderId);
  }

  @override
  Widget build(BuildContext context) {
    final String folderId =
        ModalRoute.of(context)!.settings.arguments as String;
    Folder folder = getFolder(folderId);

    return BaseContainer(
      titleWidget: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.folder,
                color: Colors.white,
                size: 30,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                folder.title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          IconButton(
            onPressed: (() {}),
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
          ),
        ],
      ),
      primaryColor: Colors.grey.shade900,
      secondaryColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            FolderInfos(folderId: folderId),
            NotesList(notes: folder.notes),
          ],
        ),
      ),
    );

    // Scaffold(
    //   appBar: AppBar(
    //     backgroundColor: Colors.grey.shade900,
    //     leading: IconButton(
    //       icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
    //       onPressed: () {
    //         Navigator.pop(context);
    //       },
    //     ),
    //     actions: [
    //       IconButton(
    //           onPressed: (() {
    //             Navigator.pushNamed(context, '/profile');
    //           }),
    //           icon: const Icon(Icons.person, color: Colors.white)),
    //     ],
    //     elevation: 0,
    //   ),
    //   body: SingleChildScrollView(
    //     child: Column(
    //       children: [
    //         FolderInfos(folderId: folderId),
    //         NotesList(notes: folder.notes),
    //       ],
    //     ),
    //   ),
    // );
  }
}
