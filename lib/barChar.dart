import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'indicator.dart';

int carbo = 5;
int carboPro = 8;

class BarChartSample5 extends StatefulWidget {
  num purpose;
  BarChartSample5({this.purpose});

  @override
  State<StatefulWidget> createState() => BarChartSample5State();
}

class BarChartSample5State extends State<BarChartSample5> {
  static const double barWidth = 22;
  List<int> nutriRate = [5, 3, 2];

  void getNutriRate(int purpose) {
    switch (purpose) {
      case 0:
        nutriRate = [3, 4, 3];

        break;
      case 1:
        nutriRate = [4, 4, 2];

        break;
      case 2:
        nutriRate = [5, 3, 2];

        break;

      default:
        nutriRate = [5, 3, 2];
    }
    carbo = nutriRate[0];
    carboPro = carbo + nutriRate[1];
  }

  @override
  void initState() {
    getNutriRate(widget.purpose);
    print(nutriRate[0]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: Container(
        // color: Color(0xFFFFFEF5),
        child: Row(children: <Widget>[
          AspectRatio(
            aspectRatio: 1,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              // color: const Color(0xff020227),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
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
                        getTextStyles: (value) =>
                            const TextStyle(color: Colors.white, fontSize: 20),
                        rotateAngle: 270,
                        getTitles: (double value) {
                          // print(value);
                          switch (value.toInt()) {
                            // case 0:
                            //   return "탄";
                            //   break;
                            // case 3:
                            //   return "단";
                            //   break;
                            // case 7:
                            //   return "지";
                            //   break;
                            default:
                              return '';
                              break;
                          }
                          // return '';
                        },
                        interval: 1,
                        // margin: 8,
                        reservedSize: 60,
                      ),
                      rightTitles: SideTitles(
                        showTitles: true,
                        getTextStyles: (value) => const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700),
                        getTitles: (double value) {
                          int intVal = value.toInt();
                          if (intVal == 0) {
                            return "${0}";
                          } else if (intVal == carbo) {
                            return "${nutriRate[0] * 10}";
                          } else if (intVal == carboPro) {
                            return "${(nutriRate[0] + nutriRate[1]) * 10}";
                          } else if (intVal == 10) {
                            return "100";
                          } else {
                            // return '';
                          }
                        },
                        interval: 1,
                        // margin: 8,
                        reservedSize: 60,
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      checkToShowHorizontalLine: (value) =>
                          value == 5 || value == 8,
                      getDrawingHorizontalLine: (value) {
                        if (value == 0) {
                          return FlLine(
                              color: const Color(0xff363753), strokeWidth: 3);
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
                            width: MediaQuery.of(context).size.width * 0.2,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6)),
                            rodStackItems: [
                              BarChartRodStackItem(0, carbo.toDouble(),
                                  Colors.deepOrangeAccent[700]),
                              BarChartRodStackItem(carbo.toDouble(),
                                  carboPro.toDouble(), Colors.deepOrangeAccent),
                              BarChartRodStackItem(carboPro.toDouble(), 10,
                                  Colors.deepOrangeAccent[100]),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Column(mainAxisSize: MainAxisSize.max,
              // mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 10),
                  child: AutoSizeText(
                    '탄 : 단 : 지',
                    // style: TextStyle(fontSize: 40),
                    maxLines: 1,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 10),
                  child: AutoSizeText(
                    '${nutriRate[0]} : ${nutriRate[1]} : ${nutriRate[2]}',
                    style: TextStyle(fontSize: 40),
                    maxLines: 1,
                  ),
                ),

                // SizedBox(
                //   width: MediaQuery.of(context).size.width / 10,
                // ),
                //Indicator
                // Spacer(),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Spacer(
                      //   flex: 7,
                      // ),
                      Container(
                        margin: EdgeInsets.only(top: 4),
                        child: Indicator(
                          // color: Color(0xff0293ee),
                          color: Colors.deepOrangeAccent[700],
                          text: ' 탄수화물',
                          textColor: Colors.white,
                          fontSize: 15,
                          isSquare: true,
                        ),
                      ),
                      // SizedBox(
                      //   height: 4,
                      // ),
                      Container(
                        margin: EdgeInsets.only(top: 4),
                        child: Indicator(
                          // color: Color(0xfff8b250),
                          color: Colors.deepOrangeAccent,
                          text: ' 단백질',
                          textColor: Colors.white,
                          fontSize: 15,
                          isSquare: true,
                        ),
                      ),
                      // SizedBox(
                      //   height: 4,
                      // ),
                      Container(
                        margin: EdgeInsets.only(top: 4, bottom: 30),
                        child: Indicator(
                          // color: Color(0xff845bef),
                          color: Colors.deepOrangeAccent[100],
                          text: ' 지방',
                          textColor: Colors.white,
                          isSquare: true,
                          fontSize: 15,
                        ),
                      ),
                      // SizedBox(
                      //   height: 4,
                      // ),

                      // Spacer(),
                      // SizedBox(
                      //   height: 40,
                      // ),
                    ],
                  ),
                ),
                // SizedBox(
                //   height: 30,
                // ),
              ]),
        ]),
      ),
    );
  }
}
