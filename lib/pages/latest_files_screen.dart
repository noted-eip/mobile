import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:noted_mobile/components/common/base_container.dart';
import 'package:noted_mobile/components/note_card_widget.dart';
import 'package:noted_mobile/data/note.dart';
import 'package:noted_mobile/data/services/api_helper.dart';
import 'package:noted_mobile/data/services/dio_singleton.dart';
import 'package:noted_mobile/data/user_provider.dart';
import 'package:provider/provider.dart';

class LatestFilesList extends StatefulWidget {
  const LatestFilesList({Key? key}) : super(key: key);

  @override
  State<LatestFilesList> createState() => _LatestFilesListState();
}

class _LatestFilesListState extends State<LatestFilesList> {
  Future<List<Note>?> getNotes(String token, String id) async {
    final api = singleton.get<APIHelper>();

    final List<Note> notes = [];

    try {
      final note = await api.get(
        "/notes",
        headers: {"Authorization": "Bearer $token"},
        queryParams: {"author_id": id},
      );

      if (note['statusCode'] != 200) {
        if (!mounted) {
          return null;
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(note['error'].toString()),
        ));
        return null;
      }

      if (note["data"]["notes"] != null) {
        note["data"]["notes"].forEach((note) {
          notes.add(Note.fromJson(note));
        });
      }

      return notes;
    } on DioError catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: true,
    );

    return Scaffold(
      body: BaseContainer(
        titleWidget: const Text(
          "My Notes",
        ),
        body: Padding(
          padding:
              const EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: FutureBuilder<List<Note>?>(
                    future: getNotes(userProvider.token, userProvider.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.isEmpty) {
                          return RefreshIndicator(
                            onRefresh: () async {
                              setState(() {});
                            },
                            child: ListView(children: const [
                              Center(
                                child: Text("No Notes found"),
                              ),
                            ]),
                          );
                        }
                        return RefreshIndicator(
                          onRefresh: () async {
                            setState(() {});
                          },
                          child: ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return NoteCard(
                                title: snapshot.data![index].title,
                                id: snapshot.data![index].id,
                                onTap: () {
                                  Navigator.pushNamed(context, '/note-detail',
                                      arguments: snapshot.data![index].id);
                                },
                              );
                            },
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return const Center(
                          child: Text("Error"),
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      // return GridView.builder(
                      //   padding: EdgeInsets.zero,
                      //   gridDelegate:
                      //       const SliverGridDelegateWithFixedCrossAxisCount(
                      //           crossAxisCount: 2),
                      //   itemBuilder: (context, index) {
                      //     // Group group = kFakeGroupsList[index];
                      //     return GroupCard(
                      //       groupName: group.title,
                      //       groupCreatedAt: DateTime.now(),
                      //       groupUpdatedAt: DateTime.now(),
                      //       groupNotesCount: group.nbNotes,
                      //       onTap: () {
                      //         Navigator.pushNamed(context, '/group-detail',
                      //             arguments: group.id);
                      //       },
                      //       groupId: group.id,
                      //       groupUserId: group.author,
                      //     );
                      //   },
                      //   itemCount: kFakeGroupsList.length,
                      // );
                    }),
              ),
            ],
          ),
        ),
      ),

      // body: SingleChildScrollView(
      //   child: Padding(
      //     padding: const EdgeInsets.all(20.0),
      //     child: Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: [
      //         const Text("All Notes",
      //             style:
      //                 TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
      //         const SizedBox(
      //           height: 20,
      //         ),

      //         Expanded(
      //           child: FutureBuilder<List<Note>?>(
      //               future: getNotes(userProvider.token, userProvider.id),
      //               builder: (context, snapshot) {
      //                 if (snapshot.hasData && snapshot.data!.isNotEmpty) {
      //                   return RefreshIndicator(
      //                     displacement: 0,
      //                     onRefresh: () async {
      //                       setState(() {});
      //                     },
      //                     child: ListView.builder(
      //                       itemCount: snapshot.data!.length,
      //                       itemBuilder: (context, index) {
      //                         return NoteCard(
      //                           title: snapshot.data![index].title,
      //                           id: snapshot.data![index].id,
      //                         );
      //                       },
      //                     ),
      //                   );
      //                 } else if (snapshot.hasData &&
      //                     snapshot.data != null &&
      //                     snapshot.data!.isEmpty) {
      //                   return const Center(
      //                     child: Text("No Notes yet"),
      //                   );
      //                 } else {
      //                   return const Center(
      //                     child: CircularProgressIndicator(),
      //                   );
      //                 }
      //               }),
      //         ),
      //         // Expanded(
      //         //   child: Column(
      //         //     children: [
      //         //       const Text("No notes yet"),
      //         //       const SizedBox(
      //         //         height: 20,
      //         //       ),
      //         //       ElevatedButton(
      //         //           onPressed: () {
      //         //             createNote(
      //         //               "groupId",
      //         //               userProvider.token,
      //         //             );
      //         //           },
      //         //           child: const Text("create"))
      //         //     ],
      //         //   ),
      //         // ),

      //         // ElevatedButton(
      //         //     onPressed: () {
      //         //       createNote(
      //         //         "groupId",
      //         //         userProvider.token,
      //         //       );
      //         //     },
      //         //     child: const Text("create"))
      //         // ..._buildList(kFakeGroupsList, context),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}
