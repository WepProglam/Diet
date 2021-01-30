import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'indicator.dart';

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
        aspectRatio: 2,
        child: Container(
            // color: Color(0xFFFFFEF5),
            child: Row(children: <Widget>[
          RotatedBox(
              quarterTurns: 1,
              child: AspectRatio(
                aspectRatio: 0.6,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  // color: const Color(0xff020227),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
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
                          leftTitles: SideTitles(
                            showTitles: true,
                            getTextStyles: (value) => const TextStyle(
                                color: Colors.white, fontSize: 20),
                            rotateAngle: 270,
                            getTitles: (double value) {
                              print(value);
                              switch (value.toInt()) {
                                case 0:
                                  return "탄";
                                  break;
                                case 3:
                                  return "단";
                                  break;
                                case 7:
                                  return "지";
                                  break;
                                default:
                                  return '';
                                  break;
                              }
                              // return '';
                            },
                            interval: 1,
                            // margin: 8,
                            reservedSize: 150,
                          ),
                          rightTitles: SideTitles(
                            showTitles: true,
                            getTextStyles: (value) => const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700),
                            rotateAngle: 270,
                            getTitles: (double value) {
                              switch (value.toInt()) {
                                case 0:
                                  return "0";
                                case 3:
                                  return "30";
                                  break;
                                case 7:
                                  return "70";
                                  break;

                                default:
                                  break;
                              }
                              return '';
                            },
                            interval: 1,
                            // margin: 8,
                            reservedSize: 150,
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          checkToShowHorizontalLine: (value) =>
                              value == 3 || value == 7,
                          getDrawingHorizontalLine: (value) {
                            if (value == 0) {
                              return FlLine(
                                  color: const Color(0xff363753),
                                  strokeWidth: 3);
                            }
                            return FlLine(
                              color: const Color(0xff2a2747),
                              strokeWidth: 0.5,
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
                                width:
                                    MediaQuery.of(context).size.height * 0.03,
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    topRight: Radius.circular(6)),
                                rodStackItems: [
                                  BarChartRodStackItem(
                                      0, 3, Colors.deepOrangeAccent[700]),
                                  BarChartRodStackItem(
                                      3, 7, Colors.deepOrangeAccent),
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
              )),
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Spacer(
                flex: 7,
              ),
              Indicator(
                // color: Color(0xff0293ee),
                color: Colors.deepOrangeAccent[700],
                text: ' 탄수화물',
                textColor: Colors.white,
                fontSize: 12,
                isSquare: true,
              ),
              SizedBox(
                height: 4,
              ),
              Indicator(
                // color: Color(0xfff8b250),
                color: Colors.deepOrangeAccent,
                text: ' 단백질',
                textColor: Colors.white,
                fontSize: 12,
                isSquare: true,
              ),
              SizedBox(
                height: 4,
              ),
              Indicator(
                // color: Color(0xff845bef),
                color: Colors.deepOrangeAccent[100],
                text: ' 지방',
                textColor: Colors.white,
                isSquare: true,
                fontSize: 12,
              ),
              SizedBox(
                height: 4,
              ),

              Spacer(),
              // SizedBox(
              //   height: 40,
              // ),
            ],
          ),
        ])));
  }
}
