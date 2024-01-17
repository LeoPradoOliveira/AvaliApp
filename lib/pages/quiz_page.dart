import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class QuizPage extends StatefulWidget {
  final String dimension;
  final int index;
  const QuizPage(this.dimension, this.index, {Key? key}) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late Map<String, dynamic> questions;
  late PageController controller;
  int questionNumber = 0;

  @override
  void initState() {
    super.initState();
    initializeQuestions();
    controller = PageController(initialPage: 0);
  }

  Future<void> initializeQuestions() async {
    String jsonString =
        await rootBundle.loadString('lib/components/questions.json');
    setState(() {
      questions = json.decode(jsonString);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: Colors.grey[300],
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(22),
                  bottomRight: Radius.circular(22),
                ),
                color: Color.fromARGB(255, 23, 35, 60),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        color: Colors.white,
                      ),
                      Text(
                        widget.dimension,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        width: 50,
                      ),
                    ],
                  ),
                  const Divider(
                    thickness: 1,
                    color: Colors.white,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_rounded),
                        onPressed: () {
                          if (questionNumber > 0) {
                            setState(() {
                              questionNumber--;
                            });
                            controller.jumpToPage(questionNumber);
                          }
                        },
                        color: Colors.white,
                        iconSize: 32,
                      ),
                      Text(
                        '${questionNumber + 1}/${questions['dimensões'][widget.index][widget.dimension]['perguntas'].length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios_rounded),
                        onPressed: () {
                          if (questionNumber <
                              questions['dimensões'][widget.index]
                                          [widget.dimension]['perguntas']
                                      .length -
                                  1) {
                            setState(() {
                              questionNumber++;
                            });
                            controller.jumpToPage(questionNumber);
                          }
                        },
                        color: Colors.white,
                        iconSize: 32,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                physics: const NeverScrollableScrollPhysics(),
                controller: controller,
                itemCount: questions['dimensões'][widget.index]
                        [widget.dimension]['perguntas']
                    .length,
                itemBuilder: (context, index) {
                  final question = questions['dimensões'][widget.index]
                      [widget.dimension]['perguntas'][index];
                  return buildQuestion(question);
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Padding buildQuestion(Map<String, dynamic> question) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 23, 35, 60),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              child: Text(
                question['enunciado'],
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  ...question['respostas']
                      .map((resposta) => buildOption(context, resposta))
                      .toList(),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOption(BuildContext context, String resposta) {
    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 74, 90, 125),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              resposta,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
