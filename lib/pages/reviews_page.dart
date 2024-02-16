import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  @override
  Widget build(BuildContext context) {
    List<RadarDataSet>? data = [
      RadarDataSet(
        dataEntries: [
          RadarEntry(value: 4.6),
          RadarEntry(value: 7.8),
          RadarEntry(value: 3.6),
          RadarEntry(value: 1.9),
          RadarEntry(value: 6.7),
          RadarEntry(value: 5.0)
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
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Text(textAlign: TextAlign.center,"01/11/2021"),
            AspectRatio(
              aspectRatio: 3,
              child: RadarChart(
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
                      width: 1, color: Color.fromARGB(255, 160, 160, 160)),
                  ticksTextStyle: (const TextStyle(fontSize: 0)),
                  radarShape: RadarShape.polygon,
                ),
              ),
            ),
            Text(textAlign: TextAlign.center,"01/09/2021"),
            AspectRatio(
              aspectRatio: 3,
              child: RadarChart(
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
                      width: 1, color: Color.fromARGB(255, 160, 160, 160)),
                  ticksTextStyle: (const TextStyle(fontSize: 0)),
                  radarShape: RadarShape.polygon,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
