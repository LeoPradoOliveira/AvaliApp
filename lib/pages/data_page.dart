import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DataPage extends StatefulWidget {
  const DataPage({Key? key}) : super(key: key);

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("users");

  @override
  Widget build(BuildContext context) {
    List<List<int>> lengthsOfAnswers = [
      [4, 4, 4, 3, 3],
      [4, 3, 4, 3, 2, 4, 4, 4],
      [2, 2, 3],
      [4, 3, 4, 4],
      [4, 3, 4, 4, 3],
      [4, 3]
    ];
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final userData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  List notAnswered = [];
                  List<double> radarEntries = [];
                  final answers = userData['Respostas']['dimensões'];
                  for (var i = 0; i < answers.length; i++) {
                    for (var key in answers[i].keys) {
                      var array = answers[i][key] as List?;
                      if (array != null && array.contains(null)) {
                        notAnswered.add(key);
                        radarEntries.add(0);
                        break;
                      } else {
                        double sum = 0;
                        for (var j = 0; j < array!.length - 1; j++) {
                          sum += array[j] / (lengthsOfAnswers[i][j] - 1);
                        }
                        radarEntries.add((sum / (array.length - 1)) * 10);
                      }
                    }
                  }

                  List<RadarDataSet>? data = [
                    RadarDataSet(
                      dataEntries: [
                        RadarEntry(value: radarEntries[0]),
                        RadarEntry(value: radarEntries[1]),
                        RadarEntry(value: radarEntries[2]),
                        RadarEntry(value: radarEntries[3]),
                        RadarEntry(value: radarEntries[4]),
                        RadarEntry(value: radarEntries[5])
                      ],
                      fillColor: const Color.fromARGB(90, 0, 250, 75),
                      borderColor: const Color.fromARGB(255, 40, 199, 88),
                    ),
                    //Um conjunto de dados que existe apenas para fazer o gráfico
                    //ter o tamanho fixo que eu quiser
                    RadarDataSet(
                      dataEntries: [
                        const RadarEntry(value: 10),
                        const RadarEntry(value: 10),
                        const RadarEntry(value: 10),
                        const RadarEntry(value: 0),
                        const RadarEntry(value: 0),
                        const RadarEntry(value: 0),
                      ],
                      fillColor: Colors.transparent,
                      borderColor: Colors.transparent,
                    ),
                  ];

                  return Column(
                    children: [
                      notAnswered.isEmpty
                          ? const SizedBox()
                          : SizedBox(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.info,
                                        size: 30,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  const Text(
                                    "É necessário responder todas as perguntas de uma dimensão para receber uma nota.",
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "As seguintes dimensões ainda possuem perguntas a serem respondidas:",
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(
                                    height: 7.5,
                                  ),
                                  const Divider(
                                    thickness: 1,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(
                                    height: 7.5,
                                  ),
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 5.0,
                                      mainAxisSpacing: 5.0,
                                      childAspectRatio: 10,
                                    ),
                                    itemBuilder: (context, index) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            notAnswered[index],
                                          )
                                        ],
                                      );
                                    },
                                    itemCount: notAnswered.length,
                                  ),
                                ],
                              ),
                            ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(
                        thickness: 1,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        height: 52.5,
                      ),
                      AspectRatio(
                        aspectRatio: 1.5,
                        child: RadarChart(
                          swapAnimationDuration:
                              const Duration(milliseconds: 900),
                          swapAnimationCurve: Curves.linear,
                          RadarChartData(
                            titlePositionPercentageOffset: 0.1,
                            dataSets: data,
                            radarBackgroundColor: Colors.white,
                            radarBorderData: const BorderSide(
                              width: 0,
                            ),
                            tickCount: 4,
                            tickBorderData: const BorderSide(
                                width: 1,
                                color: Color.fromARGB(255, 160, 160, 160)),
                            ticksTextStyle: (const TextStyle(fontSize: 0)),
                            radarShape: RadarShape.polygon,
                            getTitle: (index, angle) {
                              switch (index) {
                                case 0:
                                  return RadarChartTitle(
                                      text:
                                          'Ambiente\n${double.parse(data.first.dataEntries[index].value.toStringAsFixed(2))}',
                                      angle: angle);
                                case 1:
                                  return RadarChartTitle(
                                      text:
                                          'Cuidado\n${double.parse(data.first.dataEntries[index].value.toStringAsFixed(2))}',
                                      angle: angle);
                                case 2:
                                  return RadarChartTitle(
                                      text:
                                          '${double.parse(data.first.dataEntries[index].value.toStringAsFixed(2))}\nLar',
                                      angle: 300);
                                case 3:
                                  return RadarChartTitle(
                                      text:
                                          '${double.parse(data.first.dataEntries[index].value.toStringAsFixed(2))}\nGestão',
                                      angle: 0);
                                case 4:
                                  return RadarChartTitle(
                                      text:
                                          '${double.parse(data.first.dataEntries[index].value.toStringAsFixed(2))}\nEquipe',
                                      angle: 60);
                                case 5:
                                  return RadarChartTitle(
                                      text:
                                          'Envolvimento\n${double.parse(data.first.dataEntries[index].value.toStringAsFixed(2))}',
                                      angle: angle);
                                default:
                                  return const RadarChartTitle(text: '');
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 80,
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro${snapshot.error}',
                    ),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }),
        ),
      ),
    );
  }
}
