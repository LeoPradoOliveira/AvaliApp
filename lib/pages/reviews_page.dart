import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  late Map<String, dynamic> userData;
  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("users");
  List<DocumentSnapshot> reviewsDocs = [];
  bool isLoading = true;
  List<List<RadarDataSet>> data = [];

  @override
  void initState() {
    super.initState();
    getReviews();
  }

  Future<void> getReviews() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .collection("reviews")
          .get();

      for (var doc in querySnapshot.docs) {
        reviewsDocs.add(doc);

        List<RadarDataSet> graph = [
          RadarDataSet(
            dataEntries: [
              RadarEntry(value: doc.get('dimensoes')[0]),
              RadarEntry(value: doc.get('dimensoes')[1]),
              RadarEntry(value: doc.get('dimensoes')[2]),
              RadarEntry(value: doc.get('dimensoes')[3]),
              RadarEntry(value: doc.get('dimensoes')[4]),
              RadarEntry(value: doc.get('dimensoes')[5])
            ],
            fillColor: const Color.fromARGB(90, 0, 250, 75),
            borderColor: const Color.fromARGB(255, 40, 199, 88),
          ),
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

        data.add(graph);
      }
      data = data.reversed.toList();
      reviewsDocs = reviewsDocs.reversed.toList();

      setState(() {
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
        appBar: AppBar(
            backgroundColor: Colors.grey[300],
            surfaceTintColor: Colors.transparent),
        body: const SafeArea(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
          backgroundColor: Colors.grey[300],
          surfaceTintColor: Colors.transparent),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: SingleChildScrollView(
            child: Column(
              children: [
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: reviewsDocs.length,
                  padding: const EdgeInsets.all(4),
                  itemBuilder: (context, index) => Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey[200],
                    ),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('dd/MM/yyyy').format(
                            reviewsDocs.elementAt(index).get('data').toDate(),
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        AspectRatio(
                          aspectRatio: 2,
                          child: RadarChart(
                            swapAnimationCurve: Curves.linear,
                            RadarChartData(
                              titlePositionPercentageOffset: 0.1,
                              titleTextStyle: const TextStyle(fontSize: 12),
                              dataSets: data[index],
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
                              getTitle: (i, angle) {
                                switch (i) {
                                  case 0:
                                    return RadarChartTitle(
                                        text:
                                            'Ambiente\n${data[index][0].dataEntries[i].value.toStringAsFixed(2)}',
                                        angle: angle);
                                  case 1:
                                    return RadarChartTitle(
                                        text:
                                            'Cuidado\n${data[index][0].dataEntries[i].value.toStringAsFixed(2)}',
                                        angle: angle);
                                  case 2:
                                    return RadarChartTitle(
                                        text:
                                            '${data[index][0].dataEntries[i].value.toStringAsFixed(2)}\nLar',
                                        angle: 300);
                                  case 3:
                                    return RadarChartTitle(
                                        text:
                                            '${data[index][0].dataEntries[i].value.toStringAsFixed(2)}\nGestão',
                                        angle: 0);
                                  case 4:
                                    return RadarChartTitle(
                                        text:
                                            '${data[index][0].dataEntries[i].value.toStringAsFixed(2)}\nEquipe',
                                        angle: 60);
                                  case 5:
                                    return RadarChartTitle(
                                        text:
                                            'Envolvimento\n${data[index][0].dataEntries[i].value.toStringAsFixed(2)}',
                                        angle: angle);
                                  default:
                                    return const RadarChartTitle(text: '');
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
