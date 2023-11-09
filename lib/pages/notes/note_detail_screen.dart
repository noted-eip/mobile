import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:noted_mobile/data/models/note/note.dart';
// import 'package:noted_mobile/data/models/note/note_block.dart';
import 'package:noted_mobile/data/providers/note_provider.dart';
import 'package:noted_mobile/pages/notes/editor/noted_editor.dart';
// import 'package:openapi/openapi.dart';
// import 'package:super_editor/super_editor.dart';
import 'package:tuple/tuple.dart';

//TODO: invalidate QuizzProvider when user click on refresh button
// VOIR pourquoi le widget ne passe pas en chargement quand on refresh

class NoteDetail extends ConsumerStatefulWidget {
  const NoteDetail({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NoteDetailState();
}

class _NoteDetailState extends ConsumerState<NoteDetail> {
  @override
  Widget build(BuildContext context) {
    final Tuple2<String, String> infos =
        ModalRoute.of(context)!.settings.arguments as Tuple2<String, String>;
    final note = ref.watch(noteProvider(infos));

    return Scaffold(
      body: SafeArea(
        child: note.when(
          data: (data) {
            if (data == null) {
              return const Center(
                child: Text("No data"),
              );
            }
            return NotedEditor(
              note: data,
              infos: infos,
            );
          },
          error: (error, stackTrace) => Text(error.toString()),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );

    // // final AsyncValue<V1Quiz?> quizz = ref.watch(quizzProvider(infos));
    // // final AsyncValue<List<V1Widget>?> widgetsList =
    // //     ref.watch(recommendationListProvider(infos));

    // RoundedLoadingButtonController btnController =
    //     RoundedLoadingButtonController();

    // return Scaffold(
    //   floatingActionButtonLocation: ExpandableFab.location,
    //   // floatingActionButton: ExpandableFab(
    //   //   openButtonBuilder: RotateFloatingActionButtonBuilder(
    //   //     child: const Icon(Icons.more_vert_rounded),
    //   //     fabSize: ExpandableFabSize.regular,
    //   //     foregroundColor: Colors.white,
    //   //     backgroundColor: kPrimaryColor,
    //   //     shape: const CircleBorder(),
    //   //   ),
    //   //   closeButtonBuilder: DefaultFloatingActionButtonBuilder(
    //   //     child: const Icon(Icons.close),
    //   //     fabSize: ExpandableFabSize.small,
    //   //     foregroundColor: Colors.white,
    //   //     backgroundColor: Colors.redAccent,
    //   //     shape: const CircleBorder(),
    //   //   ),
    //   //   children: [
    //   //     quizz.when(
    //   //       data: (quiz) {
    //   //         return FloatingActionButton(
    //   //           heroTag: "quizz-data",
    //   //           onPressed: () async {
    //   //             if (quiz == null) {
    //   //               return;
    //   //             }
    //   //             return showModalBottomSheet(
    //   //               backgroundColor: Colors.transparent,
    //   //               context: context,
    //   //               isScrollControlled: true,
    //   //               builder: (context) {
    //   //                 return CustomModal(
    //   //                   height: 0.9,
    //   //                   onClose: (context) {
    //   //                     print("close");
    //   //                     ref.invalidate(quizzProvider(infos));
    //   //                     Navigator.pop(context);
    //   //                   },
    //   //                   child: QuizzPage(
    //   //                     quiz: quiz,
    //   //                     infos: infos,
    //   //                   ),
    //   //                 );
    //   //               },
    //   //             );
    //   //           },
    //   //           child: const Icon(
    //   //             Icons.quiz,
    //   //             color: Colors.white,
    //   //           ),
    //   //         );
    //   //       },
    //   //       error: (err, stack) {
    //   //         return FloatingActionButton(
    //   //           heroTag: "quizz-error",
    //   //           onPressed: () {
    //   //             ref.invalidate(quizzProvider(infos));
    //   //           },
    //   //           child: const Icon(
    //   //             Icons.error,
    //   //             color: Colors.white,
    //   //           ),
    //   //         );
    //   //       },
    //   //       loading: () {
    //   //         return FloatingActionButton(
    //   //           heroTag: "quizz-loading",
    //   //           onPressed: () {},
    //   //           child: const CircularProgressIndicator(),
    //   //         );
    //   //       },
    //   //     ),
    //   //     widgetsList.when(
    //   //       data: (widgetList) {
    //   //         return FloatingActionButton(
    //   //           heroTag: "recommandation-data",
    //   //           onPressed: () async {
    //   //             if (widgetList == null || widgetList.isEmpty) {
    //   //               return;
    //   //             }

    //   //             return showModalBottomSheet(
    //   //               backgroundColor: Colors.transparent,
    //   //               context: context,
    //   //               isScrollControlled: true,
    //   //               builder: (context) {
    //   //                 return CustomModal(
    //   //                   height: 1,
    //   //                   onClose: (context) {
    //   //                     Navigator.pop(context);
    //   //                   },
    //   //                   child: RecommendationPage(
    //   //                       infos: infos, widgetList: widgetList),
    //   //                 );
    //   //               },
    //   //             );
    //   //           },
    //   //           child: const Icon(
    //   //             Icons.recommend_rounded,
    //   //           ),
    //   //         );
    //   //       },
    //   //       loading: () => FloatingActionButton(
    //   //         heroTag: "recommandation-loading",
    //   //         onPressed: () {},
    //   //         child: const CircularProgressIndicator(),
    //   //       ),
    //   //       error: (err, stack) {
    //   //         return FloatingActionButton(
    //   //           heroTag: "recommandation-error",
    //   //           onPressed: () {
    //   //             ref.invalidate(recommendationListProvider(infos));
    //   //           },
    //   //           child: const Icon(
    //   //             Icons.error,
    //   //             color: Colors.white,
    //   //           ),
    //   //         );
    //   //       },
    //   //     ),
    //   //   ],
    //   // ),
    //   appBar: AppBar(
    //     title: Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       children: [
    //         Text(
    //           note.hasValue
    //               ? note.value!.title.substring(
    //                   0,
    //                   note.value!.title.length > 15
    //                       ? 15
    //                       : note.value!.title.length,
    //                 )
    //               : "Note Detail",
    //         ),
    //         LoadingButton(
    //           width: 48,
    //           elevation: 0,
    //           color: Colors.white,
    //           secondaryColor: Colors.black,
    //           btnController: btnController,
    //           onPressed: () async {
    //             ref.invalidate(noteProvider(infos));
    //           },
    //           resetDuration: 3,
    //           child: const Icon(
    //             Icons.refresh,
    //             color: Colors.black,
    //             size: 32,
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    //   body: SizedBox(
    //     height: 600,
    //     child: Column(
    //       children: [
    //         Expanded(
    //           child: note.when(
    //             data: (data) {
    //               if (data == null) {
    //                 return const Center(
    //                   child: Text("No data"),
    //                 );
    //               }

    //               MutableDocument doc = createInitialDocument(note: data);

    //               return NotedEditor(doc: doc);

    //               // return SingleChildScrollView(
    //               //   child: Column(
    //               //     mainAxisAlignment: MainAxisAlignment.start,
    //               //     crossAxisAlignment: CrossAxisAlignment.center,
    //               //     mainAxisSize: MainAxisSize.max,
    //               //     children: [
    //               //       const SizedBox(height: 32),
    //               //       _buildBlocks(data),
    //               //     ],
    //               //   ),
    //               // );
    //             },
    //             error: (error, stackTrace) {
    //               return Text(error.toString());
    //             },
    //             loading: (() {
    //               return const Center(
    //                 child: CircularProgressIndicator(),
    //               );
    //             }),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }

  // DocumentNode getNodeFromBlock(V1Block block) {
  //   switch (block.type) {
  //     case V1BlockType.hEADING1:
  //       return ParagraphNode(
  //         id: block.id,
  //         text: AttributedText(text: block.text),
  //         metadata: {
  //           'blockType': header1Attribution,
  //         },
  //       );
  //     case V1BlockType.hEADING2:
  //       return ParagraphNode(
  //         id: block.id,
  //         text: AttributedText(text: block.text),
  //         metadata: {
  //           'blockType': header2Attribution,
  //         },
  //       );
  //     case V1BlockType.hEADING3:
  //       return ParagraphNode(
  //         id: block.id,
  //         text: AttributedText(text: block.text),
  //         metadata: {
  //           'blockType': header3Attribution,
  //         },
  //       );

  //     default:
  //       return ParagraphNode(
  //         id: block.id,
  //         text: AttributedText(text: block.text),
  //       );
  //   }
  // }

  // DocumentNode getNodeFromBlock(Block block) {
  //   switch (block.type) {
  //     case BlockType.heading1:
  //       return ParagraphNode(
  //         id: block.id,
  //         text: AttributedText(text: block.text),
  //         metadata: {
  //           'blockType': header1Attribution,
  //         },
  //       );
  //     case BlockType.heading2:
  //       return ParagraphNode(
  //         id: block.id,
  //         text: AttributedText(text: block.text),
  //         metadata: {
  //           'blockType': header2Attribution,
  //         },
  //       );
  //     case BlockType.heading3:
  //       return ParagraphNode(
  //         id: block.id,
  //         text: AttributedText(text: block.text),
  //         metadata: {
  //           'blockType': header3Attribution,
  //         },
  //       );

  //     default:
  //       return ParagraphNode(
  //         id: block.id,
  //         text: AttributedText(text: block.text),
  //       );
  //   }
  // }

  // MutableDocument createInitialDocument({required Note note}) {
  //   List<DocumentNode>? nodes = [];

  //   if (note.blocks != null) {
  //     note.blocks!.asMap().forEach((key, block) {
  //       nodes.add(getNodeFromBlock(block));
  //     });
  //   }
  //   return MutableDocument(nodes: nodes);
  // }
}
