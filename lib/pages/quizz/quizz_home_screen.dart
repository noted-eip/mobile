import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:noted_mobile/components/common/custom_modal.dart';
import 'package:noted_mobile/components/common/custom_toast.dart';
import 'package:noted_mobile/components/common/loading_button.dart';
import 'package:noted_mobile/data/providers/note_provider.dart';
import 'package:noted_mobile/pages/quizz/quizz_screen.dart';
import 'package:noted_mobile/utils/color.dart';
import 'package:openapi/openapi.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:tuple/tuple.dart';

class QuizzHomeScreen extends ConsumerStatefulWidget {
  const QuizzHomeScreen({
    Key? key,
    required this.infos,
    required this.note,
  }) : super(key: key);

  final Tuple2<String, String> infos;
  final V1Note note;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _QuizzHomeScreenState();
}

class _QuizzHomeScreenState extends ConsumerState<QuizzHomeScreen> {
  final ScrollController _controller = ScrollController();

  bool isLoading = false;

  void _scrollDown() {
    _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
    );
  }

  Future<bool> creatQuiz(
      WidgetRef ref, Tuple2<String, String> infos, V1Note note) async {
    try {
      await ref.read(noteClientProvider).quizzGenerator(
            noteId: widget.infos.item1,
            groupId: widget.infos.item2,
          );
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var quizList = ref.watch(quizzListProvider(widget.infos));
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Quizz",
              style: Theme.of(context).textTheme.displayLarge,
            ),
            IconButton(
                onPressed: () async {
                  ref.invalidate(quizzListProvider(widget.infos));

                  await Future.delayed(const Duration(milliseconds: 500), () {
                    _scrollDown();
                  });
                },
                icon: const Icon(Icons.refresh)),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: quizList.when(
            data: (quizList) {
              if (quizList == null || quizList.isEmpty) {
                return Center(
                  child: Text("note-detail.quiz-content.empty".tr()),
                );
              } else {
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  controller: _controller,
                  itemCount: quizList.length,
                  itemBuilder: (context, index) {
                    V1Quiz quiz = quizList[index];
                    return ListTile(
                      title: Text("Quiz ${index + 1}"),
                      subtitle: Text(
                          "${quiz.questions!.length} questions - ${quiz.questions!.length * 10} points"),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        showModalBottomSheet(
                          backgroundColor: Colors.transparent,
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return CustomModal(
                              height: 0.85,
                              onClose: (context) {
                                ref.invalidate(quizzListProvider(widget.infos));
                                Navigator.pop(context);
                              },
                              child: QuizzPage(
                                quiz: quiz,
                                infos: widget.infos,
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              }
            },
            error: ((error, stackTrace) => Center(
                  child: Text(error.toString()),
                )),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
        const SizedBox(height: 20),
        LoadingButton(
          disabledColor: Colors.grey.shade900,
          color: NotedColors.primary,
          animateOnTap: false,
          btnController: RoundedLoadingButtonController(),
          onPressed: isLoading
              ? () async {}
              : () async {
                  setState(() {
                    isLoading = true;
                  });

                  bool result = await creatQuiz(ref, widget.infos, widget.note);

                  if (result) {
                    if (!mounted) {
                      return;
                    }
                    ref.invalidate(quizzListProvider(widget.infos));

                    await Future.delayed(const Duration(milliseconds: 500), () {
                      _scrollDown();
                    });

                    if (!mounted) {
                      return;
                    }
                    CustomToast.show(
                      message: "note-detail.quiz-content.success".tr(),
                      type: ToastType.success,
                      gravity: ToastGravity.TOP,
                      context: context,
                    );
                  } else {
                    if (!mounted) {
                      return;
                    }

                    CustomToast.show(
                      message: "note-detail.quiz-content.error".tr(),
                      type: ToastType.error,
                      context: context,
                    );
                  }
                  setState(() {
                    isLoading = false;
                  });
                },
          text: "note-detail.quiz-content.create".tr(),
          child: isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("note-detail.quiz-content.inProgress".tr(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20)),
                    const SizedBox(width: 10),
                    LoadingAnimationWidget.prograssiveDots(
                      color: Colors.white,
                      size: 32,
                    ),
                  ],
                )
              : null,
        ),
      ],
    );
  }
}
