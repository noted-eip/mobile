import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/providers/note_provider.dart';
import 'package:noted_mobile/utils/constant.dart';
import 'package:openapi/openapi.dart';
import 'package:tuple/tuple.dart';

class QuizzPage extends ConsumerStatefulWidget {
  const QuizzPage({
    super.key,
    required this.quiz,
    required this.infos,
  });

  final V1Quiz quiz;
  final Tuple2<String, String> infos;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _QuizzPageState();
}

class _QuizzPageState extends ConsumerState<QuizzPage> {
  int nbQuestion = 0;
  int nbRightAnswer = 0;
  Map<String, bool> answers = {};
  bool isVerified = false;
  bool isValid = false;

  void setNbQuestion(int newNbQuestion) {
    setState(() {
      nbQuestion = newNbQuestion;
    });
  }

  void setAnswersList(List<String> newAnswers) {
    setState(() {
      for (var element in newAnswers) {
        answers[element] = false;
      }
    });
  }

  void setSelectAnswer(String answer, bool value) {
    setState(() {
      answers[answer] = value;
    });
  }

  Color getAnswerColor(String answer, List<String> solutions, bool isSelect) {
    if (isVerified && solutions.contains(answer)) {
      return Colors.green;
    } else if (isVerified && !solutions.contains(answer) && isSelect) {
      return Colors.red;
    } else {
      return Colors.white;
    }
  }

  void checkAnswers(
      {required List<String> solutions, required List<String> answers}) {
    setState(() {
      isVerified = true;
    });

    final nbSolution = solutions.length;

    int goodAnswer = 0;
    int badAnswer = 0;

    for (var element in answers) {
      if (solutions.contains(element)) {
        goodAnswer++;
      } else {
        badAnswer++;
      }
    }

    if (goodAnswer == nbSolution && badAnswer == 0) {
      setState(() {
        nbRightAnswer++;
        isValid = true;
      });
    } else {
      setState(() {
        isValid = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    PageController controller = PageController();
    String getFinishText() {
      if (nbRightAnswer == nbQuestion) {
        return "Parfait !";
      } else if (nbRightAnswer == 0) {
        return "Réésaie !";
      } else if (nbRightAnswer < nbQuestion / 2) {
        return "Tu peux mieux faire !";
      } else {
        return "Bien joué !";
      }
    }

    return PageView.builder(
      controller: controller,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.quiz.questions!.length + 1,
      itemBuilder: (context, index) {
        if (index == widget.quiz.questions!.length) {
          return Column(
            children: [
              Image.asset("images/illustration.png"),
              const Spacer(),
              Text("Vous avez $nbRightAnswer / $nbQuestion bonnes réponses !",
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              RatingBarIndicator(
                rating: nbRightAnswer.toDouble(),
                itemBuilder: (context, index) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                itemCount: nbQuestion,
                itemSize: 50.0,
                unratedColor: Colors.amber.withAlpha(50),
                direction: Axis.horizontal,
              ),
              const SizedBox(height: 20),
              Text(getFinishText(), style: const TextStyle(fontSize: 18)),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(quizzProvider(widget.infos));

                  Navigator.pop(context);
                },
                child: const Text("Quitter"),
              ),
            ],
          );
        }

        final currentAnswers = widget.quiz.questions![index].answers!;
        final currentSolutions = widget.quiz.questions![index].solutions!;

        return Column(
          children: [
            Text(widget.quiz.questions![index].question ?? "Pas de question",
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...currentAnswers.map((answer) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isVerified
                                ? getAnswerColor(
                                    answer,
                                    currentSolutions.toList(),
                                    answers[answer] ?? false)
                                : Colors.black,
                          ),
                        ),
                        child: CheckboxListTile(
                          shape: ShapeBorder.lerp(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              1),
                          enabled: !isVerified,
                          value: answers[answer] ?? false,
                          selected: answers[answer] ?? false,
                          activeColor: kPrimaryColor,
                          selectedTileColor: Colors.green,
                          title: Text(answer),
                          onChanged: (value) {
                            if (answers.isEmpty) {
                              setAnswersList(currentAnswers.toList());
                            }
                            setSelectAnswer(answer, value ?? false);
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            if (isVerified)
              Text(
                isValid
                    ? "Bonne réponse"
                    : "Mauvaise Réponse, la bonne réponse est : ${currentSolutions.join(", ")}",
                style: TextStyle(
                  color: isValid ? Colors.green : Colors.red,
                ),
              ),
            const SizedBox(height: 20),
            Text("Question ${index + 1} / ${widget.quiz.questions!.length}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (nbQuestion == 0) {
                  setNbQuestion(widget.quiz.questions!.length);
                }

                if (isVerified) {
                  controller.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeIn);
                  setState(() {
                    isVerified = false;
                    isValid = false;
                    answers = {};
                  });
                  return;
                } else {
                  List<String> answersList = [];
                  answers.forEach((key, value) {
                    if (value) {
                      answersList.add(key);
                    }
                  });

                  checkAnswers(
                      answers: answersList,
                      solutions: currentSolutions.toList());
                }
              },
              child: Text(
                isVerified ? "Suivant" : "Vérifier",
                style: TextStyle(
                  color: isVerified ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
