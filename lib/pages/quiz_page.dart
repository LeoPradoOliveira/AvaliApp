import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  final String dimension;
  final int index;

  const QuizPage(this.dimension, this.index, {Key? key}) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late Map<String, dynamic> questions;
  late Map<String, dynamic> userData;
  late PageController controller;
  int questionNumber = 0;
  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("users");
  final questionsCollection =
      FirebaseFirestore.instance.collection("perguntas");
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeQuestions();
    controller = PageController(initialPage: 0);
  }

  Future<void> initializeQuestions() async {
    try {
      final DocumentReference userDocRef =
          FirebaseFirestore.instance.collection("users").doc(currentUser.uid);
      final DocumentReference questionDocRef = FirebaseFirestore.instance
          .collection("perguntas")
          .doc(widget.dimension);

      final DocumentSnapshot<Map<String, dynamic>> userDataSnapshot =
          await userDocRef.get() as DocumentSnapshot<Map<String, dynamic>>;
      final DocumentSnapshot<Map<String, dynamic>> questionDataSnapshot =
          await questionDocRef.get() as DocumentSnapshot<Map<String, dynamic>>;

      setState(() {
        questions = questionDataSnapshot.data()!;
        userData = userDataSnapshot.data()!;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[300],
        body: const SafeArea(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAppBar(),
            Expanded(
              child: PageView.builder(
                physics: const NeverScrollableScrollPhysics(),
                controller: controller,
                itemCount: questions["perguntas"].length,
                itemBuilder: (context, index) {
                  final question = questions['perguntas'][index];
                  return _buildQuestion(question);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
        color: Color.fromARGB(255, 23, 35, 60),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
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
              const SizedBox(width: 50),
            ],
          ),
          const Divider(
            thickness: 1,
            color: Colors.white,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildArrowButton(Icons.arrow_back_ios_rounded, () {
                _navigateToPreviousQuestion();
              }),
              Text(
                '${questionNumber + 1}/${questions['perguntas'].length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildArrowButton(Icons.arrow_forward_ios_rounded, () {
                _navigateToNextQuestion();
              }),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildArrowButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      color: Colors.white,
      iconSize: 32,
    );
  }

  Widget _buildQuestion(Map<String, dynamic> question) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildQuestionContainer(question['enunciado']),
            const SizedBox(height: 8),
            SingleChildScrollView(
              child: Column(
                children: [
                  ...(question['respostas'] as List<dynamic>)
                      .asMap()
                      .entries
                      .map((entry) {
                    final index = entry.key;
                    final resposta = entry.value;
                    final String texto = resposta['texto'];
                    final num valor = resposta['valor'];
                    return _buildOption(context, texto, valor, index);
                  }).toList(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionContainer(String text) {
    text = text.replaceAll(r'\n', '\n');
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 23, 35, 60),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        textAlign: TextAlign.start,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildOption(
      BuildContext context, String resposta, num valor, int index) {
    return GestureDetector(
      onTap: () async {
        DocumentReference userDocRef =
            FirebaseFirestore.instance.collection("users").doc(currentUser.uid);

        userData['Respostas']['dimensões'][widget.index][widget.dimension]
            [questionNumber] = valor;

        await userDocRef.update(userData);

        setState(() {});
      },
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          minHeight: 80.0,
        ),
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: valor ==
                  userData['Respostas']['dimensões'][widget.index]
                      [widget.dimension][questionNumber]
              ? Colors.green
              : const Color.fromARGB(255, 74, 90, 125),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              resposta,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPreviousQuestion() {
    if (questionNumber > 0) {
      setState(() {
        questionNumber--;
      });
      controller.jumpToPage(questionNumber);
    }
  }

  void _navigateToNextQuestion() {
    if (questionNumber < questions['perguntas'].length - 1) {
      setState(() {
        questionNumber++;
      });
      controller.jumpToPage(questionNumber);
    }
  }
}
