import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DataPage extends StatefulWidget {
  const DataPage({Key? key}) : super(key: key);

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  @override
  Widget build(BuildContext context) {
    List<RadarDataSet>? data = [
      RadarDataSet(
        dataEntries: [
          const RadarEntry(value: 7.564),
          const RadarEntry(value: 4.65),
          const RadarEntry(value: 7.5),
          const RadarEntry(value: 0),
          const RadarEntry(value: 5),
          const RadarEntry(value: 6)
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
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AspectRatio(
              aspectRatio: 1.5,
              child: RadarChart(
                swapAnimationDuration: const Duration(milliseconds: 900),
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
          ],
        ),
      ),
    );
  }
}
