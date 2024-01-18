import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:noted_mobile/components/common/custom_modal.dart';
import 'package:noted_mobile/components/common/custom_toast.dart';
import 'package:noted_mobile/data/providers/note_provider.dart';
import 'package:noted_mobile/pages/notes/note_summary_screen.dart';
import 'package:noted_mobile/pages/quizz/quizz_home_screen.dart';
import 'package:noted_mobile/pages/recommendation/recommendation_screen.dart';
import 'package:noted_mobile/utils/color.dart';
import 'package:openapi/openapi.dart';
import 'package:tuple/tuple.dart';

class NotedNoteTools extends ConsumerStatefulWidget {
  const NotedNoteTools({Key? key, required this.infos, required this.note})
      : super(key: key);

  final Tuple2<String, String> infos;
  final V1Note note;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NotedNoteToolsState();
}

class _NotedNoteToolsState extends ConsumerState<NotedNoteTools> {
  bool isLoadingQuizz = false;
  bool isLoadingRecommendation = false;
  bool isLoadingSummary = false;

  Future<String?> createSummary(
    WidgetRef ref,
    Tuple2<String, String> infos,
    V1Note note,
  ) async {
    try {
      String? summary = await ref.read(noteClientProvider).summaryGenerator(
            noteId: widget.infos.item1,
            groupId: widget.infos.item2,
          );

      return summary;
    } catch (e) {
      return null;
    }
  }

  Future<List<V1Widget>?> createRecommendation(
    WidgetRef ref,
    Tuple2<String, String> infos,
    V1Note note,
  ) async {
    try {
      List<V1Widget>? recommendations =
          await ref.read(noteClientProvider).recommendationGenerator(
                noteId: widget.infos.item1,
                groupId: widget.infos.item2,
              );

      return recommendations;
    } catch (e) {
      debugPrint("catch failed to generate recommendation");
      return null;
    }
  }

  bool noteContainMoreThan100Words(V1Note note) {
    int nbWords = 0;

    for (var block in note.blocks!) {
      if (block.type == V1BlockType.PARAGRAPH) {
        nbWords += block.paragraph!.split(" ").length;
      } else if (block.type == V1BlockType.hEADING1 ||
          block.type == V1BlockType.hEADING2 ||
          block.type == V1BlockType.hEADING3) {
        nbWords += block.heading!.split(" ").length;
      } else if (block.type == V1BlockType.BULLET_POINT) {
        nbWords += block.bulletPoint!.split(" ").length;
      } else if (block.type == V1BlockType.NUMBER_POINT) {
        nbWords += block.numberPoint!.split(" ").length;
      }
    }

    if (nbWords < 100) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return ExpandableFab(
      overlayStyle: ExpandableFabOverlayStyle(
        color: Colors.black.withOpacity(0.5),
      ),
      distance: 80,
      type: ExpandableFabType.up,
      pos: ExpandableFabPos.right,
      openButtonBuilder: RotateFloatingActionButtonBuilder(
        child: const Icon(Icons.bolt),
        fabSize: ExpandableFabSize.regular,
        backgroundColor: NotedColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      closeButtonBuilder: DefaultFloatingActionButtonBuilder(
        child: const Icon(Icons.close),
        fabSize: ExpandableFabSize.regular,
        backgroundColor: NotedColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: NotedColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                "note-detail.quiz".tr(),
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(color: Colors.white),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                heroTag: "quiz",
                tooltip: "note-detail.quiz".tr(),
                elevation: 5,
                backgroundColor: NotedColors.secondary,
                foregroundColor: Colors.white,
                onPressed: () async {
                  bool validNote = noteContainMoreThan100Words(widget.note);

                  if (!validNote) {
                    CustomToast.show(
                      message:
                          "${"note-detail.100words.base".tr()}${"note-detail.100words.quiz".tr()}",
                      type: ToastType.warning,
                      context: context,
                      gravity: ToastGravity.TOP,
                    );

                    return;
                  }

                  return showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return CustomModal(
                        height: 1,
                        onClose: (context) {
                          ref.invalidate(quizzListProvider(widget.infos));
                          Navigator.pop(context);
                        },
                        child: QuizzHomeScreen(
                          infos: widget.infos,
                          note: widget.note,
                        ),
                      );
                    },
                  );
                },
                child: isLoadingQuizz
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Icon(
                        Icons.quiz,
                      ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: NotedColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                "note-detail.summary".tr(),
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(color: Colors.white),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                heroTag: "summary",
                tooltip: "note-detail.summary".tr(),
                backgroundColor: NotedColors.secondary,
                foregroundColor: Colors.white,
                elevation: 5,
                onPressed: () async {
                  bool validNote = noteContainMoreThan100Words(widget.note);

                  if (!validNote) {
                    CustomToast.show(
                      message:
                          "${"note-detail.100words.base".tr()}${"note-detail.100words.summary".tr()}",
                      type: ToastType.warning,
                      context: context,
                      gravity: ToastGravity.TOP,
                    );

                    return;
                  }

                  setState(() {
                    isLoadingSummary = true;
                  });

                  String? summary = await createSummary(
                    ref,
                    widget.infos,
                    widget.note,
                  );

                  setState(() {
                    isLoadingSummary = false;
                  });

                  if (summary == null) {
                    if (!mounted) {
                      return;
                    }
                    CustomToast.show(
                      message: "note-detail.error.summary".tr(),
                      type: ToastType.error,
                      context: context,
                      gravity: ToastGravity.TOP,
                    );
                    return;
                  }

                  if (!mounted) {
                    return;
                  }

                  return showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return CustomModal(
                        height: 1,
                        onClose: (context) {
                          Navigator.pop(context);
                        },
                        child: SummaryScreen(
                          infos: widget.infos,
                          summary: summary,
                        ),
                      );
                    },
                  );
                },
                child: isLoadingSummary
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Icon(
                        Icons.summarize,
                      ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: NotedColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                "note-detail.recommandations".tr(),
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(color: Colors.white),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                heroTag: "recommendation",
                tooltip: "note-detail.recommandations".tr(),
                backgroundColor: NotedColors.secondary,
                foregroundColor: Colors.white,
                elevation: 5,
                onPressed: () async {
                  bool validNote = noteContainMoreThan100Words(widget.note);

                  if (!validNote) {
                    CustomToast.show(
                      message:
                          "${"note-detail.100words.base".tr()}${"note-detail.100words.recommandations".tr()}",
                      type: ToastType.warning,
                      context: context,
                      gravity: ToastGravity.TOP,
                    );

                    return;
                  }

                  setState(() {
                    isLoadingRecommendation = true;
                  });

                  List<V1Widget>? widgetList = await createRecommendation(
                    ref,
                    widget.infos,
                    widget.note,
                  );

                  setState(() {
                    isLoadingRecommendation = false;
                  });

                  if (widgetList == null && mounted) {
                    CustomToast.show(
                      message: "note-detail.error.recommendations".tr(),
                      type: ToastType.error,
                      context: context,
                      gravity: ToastGravity.TOP,
                    );
                    return;
                  }

                  if (widgetList!.isEmpty && mounted) {
                    CustomToast.show(
                      message: "note-detail.error.recommendations-empty".tr(),
                      type: ToastType.warning,
                      context: context,
                      gravity: ToastGravity.TOP,
                    );
                    return;
                  }

                  if (!mounted) {
                    return;
                  }

                  return showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return CustomModal(
                        height: 1,
                        onClose: (context) {
                          Navigator.pop(context);
                        },
                        child: RecommendationPage(
                          infos: widget.infos,
                          widgetList: widgetList,
                        ),
                      );
                    },
                  );
                },
                child: isLoadingRecommendation
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Icon(
                        Icons.recommend,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
