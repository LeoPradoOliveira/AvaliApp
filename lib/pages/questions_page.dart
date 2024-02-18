import 'package:avaliapp/components/dimension_button.dart';
import 'package:avaliapp/components/object_models/reviews.dart';
import 'package:avaliapp/pages/quiz_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class QuestionsPage extends StatefulWidget {
  const QuestionsPage({super.key});

  @override
  State<QuestionsPage> createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
            child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (
                  context,
                  snapshot,
                ) {
                  if (snapshot.hasData) {
                    int countNotNull = 0;
                    int countNull = 0;
                    final userData =
                        snapshot.data!.data() as Map<String, dynamic>;

                    for (var dimensao in userData['Respostas']['dimensões']) {
                      dimensao.entries.forEach((entry) {
                        entry.value.forEach((element) {
                          if (element != null) {
                            countNotNull++;
                          } else {
                            countNull++;
                          }
                        });
                      });
                    }

                    return Column(
                      children: [
                        profileBar(userData),
                        const SizedBox(height: 32),
                        countNotNull / (countNotNull + countNull) == 1
                            ? GestureDetector(
                                onTap: () {
                                  saveReview(userData);
                                  setState(() {});
                                },
                                child: Container(
                                  width: 320,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: const Center(
                                    child: Text(
                                      'Salvar Análise',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                width: 320,
                                height: 20,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Stack(
                                  children: [
                                    Container(
                                      width: countNotNull /
                                          (countNotNull + countNull) *
                                          320,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        '${(countNotNull / (countNotNull + countNull) * 100).round()}%',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        const SizedBox(
                          height: 16,
                        ),
                        const Row(
                          children: [
                            SizedBox(
                              width: 16,
                            ),
                            Text(
                              'Dimensões',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                          ),
                          itemCount: 6,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(8),
                          itemBuilder: (context, index) => DimensionButton(
                            imagePath: 'lib/images/Frame$index.png',
                            onTap: () {
                              _navigateToDestinationScreen(context, index);
                            },
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Erro${snapshot.error}',
                      ),
                    );
                  }
                  return const Center();
                }),
          ),
        ),
      ),
    );
  }

  Widget profileBar(Map<String, dynamic> userData) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 23, 35, 60),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 50,
              left: 10,
            ),
            child: Container(
              height: 120,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
              ),
              child: CircleAvatar(
                backgroundImage: NetworkImage(userData['Foto']),
                radius: 55,
              ),
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: SizedBox(
                width: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData['Nome'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      userData['Instituição'],
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  saveReview(Map<String, dynamic> userData) async {
    DocumentReference userDocRef = FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid);

    final answers = userData['Respostas']['dimensões'];
    List<double> dimensoes = [0, 0, 0, 0, 0, 0];
    for (var i = 0; i < answers.length; i++) {
      for (var key in answers[i].keys) {
        var array = answers[i][key] as List?;

        double sum = 0;
        for (var j = 0; j < array!.length; j++) {
          sum += array[j];
        }
        dimensoes[i] = (sum / (array.length));
      }
    }

    Review review = Review(
        data: DateTime.now().toUtc().add(const Duration(hours: -3)),
        dimensoes: dimensoes);

    addReviewToFirestore(FirebaseAuth.instance.currentUser!.uid, review);

    for (var dimension in userData["Respostas"]["dimensões"]) {
      dimension.forEach((key, value) {
        for (int i = 0; i < value.length; i++) {
          if (value[i] is num) {
            value[i] = null;
          }
        }
      });
    }

    await userDocRef.update(userData);
  }

  void _navigateToDestinationScreen(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuizPage("Ambiente", index)),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuizPage("Cuidado", index)),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuizPage("Lar", index)),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => QuizPage("Gestão da ILPI", index)),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => QuizPage("Equipe de Trabalho", index)),
        );
        break;
      case 5:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => QuizPage("Envolvimento Familiar", index)),
        );
        break;
      default:
        break;
    }
  }
}
