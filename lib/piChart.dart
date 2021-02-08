import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_application_1/initPage.dart';

import 'indicator.dart';

double myCarbohydrate, myProtein, myFat, myTotalCalroie = 0.0;
double carboMass, proMass, fatMass;
double myCorrect = 0.0;

class PieChartSample2 extends StatefulWidget {
  PieChartSample2(
      {double carbohydrate,
      double protein,
      double fat,
      double totalCalorie,
      double correct}) {
    carboMass = (carbohydrate == num) ? carbohydrate / 4 : 0.0;
    proMass = (protein == num) ? protein / 4 : 0.0;
    fatMass = (fat == num) ? fat / 9 : 0.0;
    if ((carbohydrate == num && protein == num && fat == num)) {
      myCarbohydrate = carbohydrate * 100 / (carbohydrate + protein + fat);
      myProtein = protein * 100 / (carbohydrate + protein + fat);
      myFat = fat * 100 / (carbohydrate + protein + fat);
      myTotalCalroie = totalCalorie;
      myCorrect = correct;
    } else {
      myCarbohydrate = 1;
      myProtein = 0;
      myFat = 0;
      myTotalCalroie = 0.0;
      myCorrect = 0.0;
    }
  }

  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State {
  int touchedIndex;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Stack(
        children: [
          Container(
            // padding: EdgeInsets.only(top: 10),
            // color: Color(0xFFFFFEF5),
            child: Row(
              children: <Widget>[
                // SizedBox(
                //   height: 18,
                // ),
                // Spacer(),
                Expanded(
                  flex: 10,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: PieChart(
                      PieChartData(
                          pieTouchData:
                              PieTouchData(touchCallback: (pieTouchResponse) {
                            setState(() {
                              if (pieTouchResponse.touchInput
                                      is FlLongPressEnd ||
                                  pieTouchResponse.touchInput is FlPanEnd) {
                                touchedIndex = -1;
                              } else {
                                touchedIndex =
                                    pieTouchResponse.touchedSectionIndex;
                              }
                            });
                          }),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          sectionsSpace: 0,
                          centerSpaceRadius: 30,
                          sections: showingSections()),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Spacer(
                      flex: 2,
                    ),
                    Indicator(
                      // color: Color(0xff0293ee),
                      color: Colors.deepOrangeAccent[700],
                      text: ' 탄수화물\n (총 ${(carboMass).toStringAsFixed(1)}g)',
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
                      text: ' 단백질\n (총 ${(proMass).toStringAsFixed(1)}g)',
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
                      text: ' 지방\n (총 ${(fatMass).toStringAsFixed(1)}g)',
                      textColor: Colors.white,
                      isSquare: true,
                      fontSize: 12,
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Indicator(
                      // color: Colors.black,
                      color: Colors.deepOrange[100],
                      text: " ${myRounder(myTotalCalroie)}Kcal",
                      textColor: Colors.white,
                      isSquare: true,
                      fontSize: 12,
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Indicator(
                      // color: Colors.black,
                      color: Colors.deepOrange[100],
                      text: " ${myRounder(myCorrect)}% 일치",
                      textColor: Colors.white,
                      isSquare: true,
                      fontSize: 12,
                    ),
                    Spacer(),
                    // SizedBox(
                    //   height: 40,
                    // ),
                  ],
                ),
                Spacer(),
                // const SizedBox(
                //   width: 20,
                // ),
              ],
            ),
          ),
          // Align(
          //   alignment: Alignment.topCenter,
          //   child: AutoSizeText(
          //     '식단 총 열량 비율',
          //     maxLines: 1,
          //     style: TextStyle(fontSize: 15),
          //   ),
          // ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(3, (i) {
      final isTouched = i == touchedIndex;
      final double fontSize = isTouched ? 25 : 16;
      final double radius = isTouched ? 60 : 50;
      switch (i) {
        case 0:
          return PieChartSectionData(
              // color: const Color(0xff0293ee),
              color: Colors.deepOrangeAccent[700],
              value: myCarbohydrate,
              title: myRounder(myCarbohydrate) + "%",
              radius: radius,
              titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                // color: const Color(0xffffffff)
              ));
        case 1:
          return PieChartSectionData(
              // color: const Color(0xfff8b250),
              color: Colors.deepOrangeAccent,
              value: myProtein,
              title: myRounder(myProtein) + "%",
              radius: radius,
              titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                // color: const Color(0xffffffff)),
              ));
        case 2:
          return PieChartSectionData(
              // color: const Color(0xff845bef),
              color: Colors.deepOrangeAccent[100],
              value: myFat,
              title: myRounder(myFat) + "%",
              radius: radius,
              titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                // color: const Color(0xffffffff)),
              ));

        default:
          return null;
      }
    });
  }

  String myRounder(double a) {
    return a.toString().length < 5
        ? a.toString()
        : a.toString().substring(0, 5);
  }
}
