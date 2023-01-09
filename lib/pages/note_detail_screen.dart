import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:noted_mobile/components/common/base_container.dart';
import 'package:noted_mobile/data/note.dart';
import 'package:noted_mobile/data/note_block.dart';
import 'package:noted_mobile/data/services/api_helper.dart';
import 'package:noted_mobile/data/services/dio_singleton.dart';
import 'package:noted_mobile/data/user_provider.dart';
import 'package:provider/provider.dart';

class NoteDetail extends StatefulWidget {
  const NoteDetail({Key? key}) : super(key: key);

  @override
  State<NoteDetail> createState() => _NoteDetailState();
}

class _NoteDetailState extends State<NoteDetail> {
  Widget _buildBlocks(Note note) {
    List<Widget> blocks = [];
    if (note.blocks != null) {
      for (var block in note.blocks!) {
        switch (block.type) {
          case BlockType.heading1:
            {
              blocks.add(
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    block.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
              blocks.add(const SizedBox(height: 16));
            }
            break;
          case BlockType.heading2:
            {
              blocks.add(
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    block.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
              blocks.add(const SizedBox(height: 14));
            }
            break;
          case BlockType.heading3:
            {
              blocks.add(
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    block.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
              blocks.add(const SizedBox(height: 12));
            }
            break;

          default:
            {
              blocks.add(
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    block.text,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              );
              blocks.add(const SizedBox(height: 10));
            }
        }
      }
    }

    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: blocks,
      ),
    );
  }

  Future<Note?> getNoteById(
    String id,
    String tkn,
  ) async {
    final api = singleton.get<APIHelper>();

    try {
      final note = await api.get(
        "/notes/$id",
        headers: {"Authorization": "Bearer $tkn"},
      );

      if (note['statusCode'] != 200) {
        return null;
      }

      if (note['data'] != null && note['data']["note"] == null) {
        return null;
      }

      return Note.fromJson(note['data']["note"]);
    } on DioError catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String noteId = ModalRoute.of(context)!.settings.arguments as String;
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: true,
    );

    return Scaffold(
      body: BaseContainer(
        titleWidget: const Text(
          "Note Detail",
        ),
        body: Padding(
          padding:
              const EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 20),
          child: FutureBuilder<Note?>(
              future: getNoteById(noteId, userProvider.token),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          snapshot.data!.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildBlocks(snapshot.data!),
                      ],
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
              }),
        ),
      ),
    );
  }
}
