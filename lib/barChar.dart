import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartSample5 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BarChartSample5State();
}

class BarChartSample5State extends State<BarChartSample5> {
  static const double barWidth = 22;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        // color: const Color(0xff020227),
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.center,
              maxY: 10,
              minY: 0,
              groupsSpace: 0,
              barTouchData: BarTouchData(
                enabled: false,
              ),
              titlesData: FlTitlesData(
                show: true,
                // topTitles: SideTitles(
                //   showTitles: true,
                //   getTextStyles: (value) =>
                //       const TextStyle(color: Colors.white, fontSize: 10),
                //   margin: 10,
                //   rotateAngle: 0,
                //   getTitles: (double value) {
                //     switch (value.toInt()) {
                //       default:
                //         return '';
                //     }
                //   },
                // ),
                // bottomTitles: SideTitles(
                //   showTitles: true,
                //   getTextStyles: (value) =>
                //       const TextStyle(color: Colors.white, fontSize: 10),
                //   margin: 10,
                //   rotateAngle: 0,
                //   getTitles: (double value) {
                //     switch (value.toInt()) {
                //       default:
                //         return '';
                //     }
                //   },
                // ),
                // leftTitles: SideTitles(
                //   showTitles: true,
                //   getTextStyles: (value) =>
                //       const TextStyle(color: Colors.white, fontSize: 20),
                //   rotateAngle: 0,
                //   getTitles: (double value) {
                //     switch (value.toInt()) {
                //       case 3:
                //         return "30";
                //         break;
                //       case 7:
                //         return "70";
                //         break;
                //       default:
                //         break;
                //     }
                //     return '';
                //   },
                //   interval: 1,
                //   // margin: 8,
                //   reservedSize: 100,
                // ),
                rightTitles: SideTitles(
                  showTitles: true,
                  getTextStyles: (value) => const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w700),
                  rotateAngle: 0,
                  getTitles: (double value) {
                    switch (value.toInt()) {
                      case 3:
                        return "30%";
                        break;
                      case 7:
                        return "70%";
                        break;
                      default:
                        break;
                    }
                    return '';
                  },
                  interval: 1,
                  // margin: 8,
                  reservedSize: 90,
                ),
              ),
              gridData: FlGridData(
                show: true,
                checkToShowHorizontalLine: (value) => value == 3 || value == 7,
                getDrawingHorizontalLine: (value) {
                  if (value == 0) {
                    return FlLine(
                        color: const Color(0xff363753), strokeWidth: 3);
                  }
                  return FlLine(
                    color: const Color(0xff2a2747),
                    strokeWidth: 0.8,
                  );
                },
              ),
              borderData: FlBorderData(
                show: true,
              ),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      y: 10,
                      width: MediaQuery.of(context).size.width * 0.3,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6)),
                      rodStackItems: [
                        BarChartRodStackItem(
                            0, 3, Colors.deepOrangeAccent[700]),
                        BarChartRodStackItem(3, 7, Colors.deepOrangeAccent),
                        BarChartRodStackItem(
                            7, 10, Colors.deepOrangeAccent[100]),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
