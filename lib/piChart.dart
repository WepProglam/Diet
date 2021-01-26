import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/initPage.dart';

import 'indicator.dart';

double myCarbohydrate, myProtein, myFat, myTotalCalroie = 0.0;
double myCorrect = 0.0;

class PieChartSample2 extends StatefulWidget {
  PieChartSample2(
      {double carbohydrate,
      double protein,
      double fat,
      double totalCalorie,
      double correct}) {
    if ((carbohydrate != 0.0 || protein != 0.0 || fat != 0.0)) {
      myCarbohydrate = carbohydrate * 100 / (carbohydrate + protein + fat);
      myProtein = protein * 100 / (carbohydrate + protein + fat);
      myFat = fat * 100 / (carbohydrate + protein + fat);
      myTotalCalroie = totalCalorie;
      myCorrect = correct;
    } else {
      myCarbohydrate = 33;
      myProtein = 33;
      myFat = 34;
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
      child: Container(
        color: Color(0xFFFFFEF5),
        child: Row(
          children: <Widget>[
            // SizedBox(
            //   height: 18,
            // ),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                      pieTouchData:
                          PieTouchData(touchCallback: (pieTouchResponse) {
                        setState(() {
                          if (pieTouchResponse.touchInput is FlLongPressEnd ||
                              pieTouchResponse.touchInput is FlPanEnd) {
                            touchedIndex = -1;
                          } else {
                            touchedIndex = pieTouchResponse.touchedSectionIndex;
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
                Indicator(
                  color: Color(0xff0293ee),
                  text: '탄수화물',
                  fontSize: 12,
                  isSquare: true,
                ),
                SizedBox(
                  height: 4,
                ),
                Indicator(
                  color: Color(0xfff8b250),
                  text: '단백질',
                  fontSize: 12,
                  isSquare: true,
                ),
                SizedBox(
                  height: 4,
                ),
                Indicator(
                  color: Color(0xff845bef),
                  text: '지방',
                  isSquare: true,
                  fontSize: 12,
                ),
                SizedBox(
                  height: 4,
                ),
                Indicator(
                  color: Colors.black,
                  text: "${myRounder(myTotalCalroie)}Kcal",
                  isSquare: true,
                  fontSize: 12,
                ),
                SizedBox(
                  height: 4,
                ),
                Indicator(
                  color: Colors.black,
                  text: "${myRounder(myCorrect)}% 일치",
                  isSquare: true,
                  fontSize: 12,
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
            const SizedBox(
              width: 20,
            ),
          ],
        ),
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
            color: const Color(0xff0293ee),
            value: myCarbohydrate,
            title: myRounder(myCarbohydrate) + "%",
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 1:
          return PieChartSectionData(
            color: const Color(0xfff8b250),
            value: myProtein,
            title: myRounder(myProtein) + "%",
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 2:
          return PieChartSectionData(
            color: const Color(0xff845bef),
            value: myFat,
            title: myRounder(myFat) + "%",
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );

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
