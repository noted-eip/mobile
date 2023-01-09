import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:noted_mobile/components/note_card_widget.dart';
import 'package:noted_mobile/data/note.dart';
import 'package:noted_mobile/data/services/api_helper.dart';
import 'package:noted_mobile/data/services/dio_singleton.dart';
import 'package:noted_mobile/data/user_provider.dart';
import 'package:provider/provider.dart';

class LatestFiles extends StatefulWidget {
  const LatestFiles({Key? key}) : super(key: key);

  @override
  State<LatestFiles> createState() => _LatestFilesState();
}

class _LatestFilesState extends State<LatestFiles> {
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
        note["data"]["notes"].asMap().forEach((index, note) {
          if (index < 5) {
            notes.add(Note.fromJson(note));
          }
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
      listen: false,
    );
    return Container(
      padding: const EdgeInsets.all(20),
      height: 370,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Latest Files", style: TextStyle(fontSize: 20)),
          Expanded(
            child: FutureBuilder<List<Note>?>(
                future: getNotes(userProvider.token, userProvider.id),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.isEmpty) {
                      return ListView(children: const [
                        Center(
                          child: Text("No Notes found"),
                        ),
                      ]);
                    }
                    return ListView.builder(
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
                }),
          ),
        ],
      ),
    );
  }
}
