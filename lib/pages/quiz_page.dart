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

  @override
  void initState() {
    super.initState();
    initializeQuestions();
  }

  Future<void> initializeQuestions() async {
    try {
      // Substitua o caminho pelo caminho real do seu arquivo JSON
      String jsonString =
          await rootBundle.loadString('lib/components/questions.json');
      setState(() {
        questions = json.decode(jsonString);
      });
    } catch (e) {
      print('Erro ao ler o arquivo JSON: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Text(
              questions['dimensões'][widget.index][widget.dimension]['perguntas'][0]['enunciado'],
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 32),
            
          ],
        ),
      ),),
    );
  }
}
