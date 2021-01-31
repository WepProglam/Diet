import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'db_helper.dart';
import 'model.dart';
import "indicator.dart";

final dbHelperPerson = DBHelperPerson();

//성취도 함수

List<dynamic> myPersonTimeArchieveInfo = [];
List<num> myKcalArchieve = [];
List<num> myNutriArchieve = [];

List<num> myMaxKcalArchieve = [];
List<num> myMaxNutriArchieve = [];

class LineChartSample2 extends StatefulWidget {
  int index = 0;
  int secondIndex = 0;
  //성취도 함수
  List<dynamic> personTimeArchieveInfo = [];
  List<num> kcalArchieve = [];
  List<num> nutriArchieve = [];

  LineChartSample2(
      {this.index,
      this.personTimeArchieveInfo,
      this.kcalArchieve,
      this.nutriArchieve,
      this.secondIndex}) {
    if (kcalArchieve != null) {
      secondIndex = secondIndex;
      if (kcalArchieve.isNotEmpty) {
        myPersonTimeArchieveInfo = personTimeArchieveInfo;
        myKcalArchieve = kcalArchieve;
        myNutriArchieve = nutriArchieve;
      } else {
        myPersonTimeArchieveInfo = [];
        myKcalArchieve = [];
        myNutriArchieve = [];
      }
    }
  }
  @override
  _LineChartSample2State createState() =>
      _LineChartSample2State(index: index, secondIndex: secondIndex);
}

class _LineChartSample2State extends State<LineChartSample2> {
  int index = 0;
  int secondIndex = 100;
  _LineChartSample2State({this.index, this.secondIndex});

  List<Color> gradientColorsKcal = [
    Colors.deepOrangeAccent[400],
    Colors.deepOrangeAccent[400]
  ];

  List<Color> gradientColorsNutri = [
    Colors.deepOrangeAccent,
    Colors.deepOrangeAccent
  ];

  List<Color> gradientColors = [
    Colors.white,
    Colors.white,
  ];

  bool isShowingMainData;
  List<String> personTimeInfo = [];
  List<FlSpot> personWeightSpot = [];
  List<FlSpot> personBmiSpot = [];
  List<FlSpot> personMuscleSpot = [];

  List<FlSpot> personTargetWeightSpot = [];
  List<FlSpot> personTargetBmiSpot = [];
  List<FlSpot> personTargetMuscleSpot = [];

  List<double> maxWeigt = [];
  List<double> maxBmi = [];
  List<double> maxMuscle = [];

  int personInfoLength = 0;

  @override
  void initState() {
    getInfo();
    super.initState();
    isShowingMainData = true;
  }

  void getInfo() async {
    print("get info in getinfo");
    print(myKcalArchieve);
    myPersonTimeArchieveInfo = [];
    myKcalArchieve = [];
    myNutriArchieve = [];
    if (index == -1) {
      if (myKcalArchieve != null && myKcalArchieve.isNotEmpty) {
        print("get info in getinfo");
      } else {
        print("empty!!!");
        // myKcalArchieveSpot = [FlSpot.nullSpot];
        // myNutriArchieveSpot = [FlSpot.nullSpot];
      }
    } else {
      await dbHelperPerson.getAllPerson().then((value) {
        personWeightSpot = [];
        personBmiSpot = [];
        personMuscleSpot = [];
        personTimeInfo = [];

        personTargetWeightSpot = [];
        personTargetBmiSpot = [];
        personTargetMuscleSpot = [];

        setState(() {
          for (var item in value) {
            maxWeigt.add(item.weight);
            maxWeigt.add(item.weightTarget);
            maxBmi.add(item.bmi);
            maxBmi.add(item.bmiTarget);
            maxMuscle.add(item.muscleMass);
            maxMuscle.add(item.muscleTarget);
            personTimeInfo.add(item.time.split("-").sublist(1, 2).join());
          }

          maxWeigt.sort();
          maxBmi.sort();
          maxMuscle.sort();

          int i = 0;

          for (var item in value) {
            personWeightSpot.add(FlSpot(double.parse(i.toString()),
                myRounder((item.weight * 8) / maxWeigt.last)));
            personBmiSpot.add(FlSpot(double.parse(i.toString()),
                myRounder((item.bmi * 8) / maxBmi.last)));
            personMuscleSpot.add(FlSpot(double.parse(i.toString()),
                myRounder((item.muscleMass * 8) / maxMuscle.last)));

            personTargetWeightSpot.add(FlSpot(double.parse(i.toString()),
                myRounder((item.weightTarget * 8) / maxWeigt.last)));

            personTargetBmiSpot.add(FlSpot(double.parse(i.toString()),
                myRounder((item.bmiTarget * 8) / maxBmi.last)));

            personTargetMuscleSpot.add(FlSpot(double.parse(i.toString()),
                myRounder((item.muscleTarget * 8) / maxMuscle.last)));
            i += 1;
          }
          personInfoLength = personWeightSpot.length - 1;
        });

        // print(personWeightSpot);
      });
    }
  }

  List<String> graphTitle = ["체중", "BMI", "골격근량"];

  @override
  void didChangeDependencies() {
    getInfo();
    super.didChangeDependencies();
  }

  bool showAvg = false;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var a;
    var b;
    try {
      a = LineChart(archieveDataKcal());
      b = LineChart(archieveDataNutri());
    } catch (e) {}

    var plotting;
    if (index == -1 && secondIndex == 1) {
      plotting = a;
    } else if (index == -1 && secondIndex == 0) {
      plotting = b;
    } else if (index != -1) {
      plotting = LineChart(mainData(index: index));
    }
    print(personTargetBmiSpot);
    return Column(
      children: [
        Stack(
          children: <Widget>[
            AspectRatio(
              aspectRatio: index == -1 ? size.width / size.height * 3 : 1.1,
              child: FractionallySizedBox(
                  heightFactor: 1.1,
                  widthFactor: 1,
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(18),
                      ),
                      // color: Color(0xff232d37)
                    ),
                    child: Padding(
                        padding: const EdgeInsets.only(
                            right: 15, left: 15, top: 30, bottom: 0),
                        child: plotting == null ? null : plotting),
                  )),
            ),
            index == -1
                ? Container()
                : Positioned(
                    child: AutoSizeText(
                      "${graphTitle[index]}",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20),
                      maxLines: 1,
                    ),
                    // child: ElevatedButton(
                    //   // color: Colors.deepOrangeAccent[400]
                    //   onPressed: () {},
                    //   style: ElevatedButton.styleFrom(
                    //       primary: Colors.redAccent[700], onPrimary: Colors.white),
                    //   child: Text(
                    //     "${graphTitle[index]}",
                    //     style: TextStyle(
                    //         color: Colors.white,
                    //         fontWeight: FontWeight.w700,
                    //         fontSize: 15),
                    //   ),
                    // ),
                    // width: size.width / 5,
                    top: 0,
                    right: 30,
                    // right: 0,
                  )
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height / 25,
        ),
        index == -1 && secondIndex == 0
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Spacer(flex: 1),
                  Indicator(
                    // color: Color(0xfff8b250),
                    color: Colors.deepOrangeAccent[100],
                    text: '영양성분 성취도',
                    textColor: Colors.white,
                    fontSize: 12,
                    isSquare: true,
                  ),
                ],
              )
            : index == -1
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    // crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Spacer(flex: 1),
                      Indicator(
                        // color: Color(0xfff8b250),
                        color: Colors.deepOrangeAccent[400],
                        text: '열량 성취도',
                        textColor: Colors.white,
                        fontSize: 12,
                        isSquare: true,
                      )
                    ],
                  )
                : Container()
      ],
    );
  }

  double myRounder(num a) {
    return a.toString().length < 4
        ? a.toDouble()
        : double.parse(a.toString().substring(0, 4));
  }

  LineChartData mainData({int index}) {
    List<double> maxInfo = [];
    // print(index);
    if (index == 0) {
      maxInfo = maxWeigt;
    } else if (index == 1) {
      maxInfo = maxBmi;
    } else {
      maxInfo = maxMuscle;
    }
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          getTextStyles: (value) => const TextStyle(
              color: Color(0xffA5A0A0),
              fontWeight: FontWeight.bold,
              fontSize: 12),
          getTitles: (value) {
            if (value.toInt() < personTimeInfo.length) {
              return personTimeInfo[value.toInt()];
            }
            return "future";
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => const TextStyle(
            color: Color(0xffA5A0A0),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          getTitles: (value) {
            return '${maxInfo.last * value.toInt() / 8}kg';
          },
          reservedSize: 28,
          margin: 15,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: personInfoLength.toDouble(),
      minY: 0,
      maxY: 10,
      lineBarsData: [
        LineChartBarData(
          spots: index == 0
              ? personWeightSpot
              : index == 1
                  ? personBmiSpot
                  : personMuscleSpot,
          isCurved: true,
          colors: gradientColors,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors:
                gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
        LineChartBarData(
          spots: index == 0
              ? personTargetWeightSpot
              : index == 1
                  ? personTargetBmiSpot
                  : personTargetMuscleSpot,
          isCurved: true,
          colors: gradientColors,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors:
                gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
    );
  }

  LineChartData archieveDataKcal() {
    print("here is archie graph");
    print(secondIndex);
    List<FlSpot> myKcalArchieveSpot = [];

    for (var j = 0; j < myKcalArchieve.length; j++) {
      myMaxKcalArchieve.add(myKcalArchieve[j]);
    }
    myMaxKcalArchieve.sort();

    for (var k = 0; k < myKcalArchieve.length; k++) {
      myKcalArchieveSpot.add(FlSpot(k.toDouble(), myKcalArchieve[k] / 10));
    }

    myMaxKcalArchieve = [];
    // setState(() {});
    return LineChartData(
      lineTouchData: LineTouchData(enabled: true),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 10,
          getTextStyles: (value) => const TextStyle(
              color: Color(0xff68737d),
              fontWeight: FontWeight.bold,
              fontSize: 12),
          getTitles: (value) {
            // switch (value.toInt()) {
            //   case 2:
            //     return 'MAR';
            //   case 5:
            //     return 'JUN';
            //   case 8:
            //     return 'SEP';
            // }

            // print(myPersonTimeArchieveInfo[value.toInt()]);
            List title = myPersonTimeArchieveInfo[value.toInt()];

            if (value % (myPersonTimeArchieveInfo.length ~/ 5 + 1) == 0) {
              return title[1].toString() + "/" + title[2].toString();
            }
            return '';
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => const TextStyle(
            color: Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
            }
            // print(value);

            return value == 0
                ? "${value.toInt()}%"
                : value.toInt() >= 11
                    ? ""
                    : "${value.toInt()}0%";
          },
          reservedSize: 28,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: (myKcalArchieveSpot.length.toDouble() - 1) * 1.1,
      minY: 0,
      maxY: 12,
      lineBarsData: [
        LineChartBarData(
          spots: myKcalArchieveSpot,
          isCurved: false,
          colors: gradientColorsKcal,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors: gradientColorsKcal
                .map((color) => color.withOpacity(0.3))
                .toList(),
          ),
        ),
      ],
    );
  }

  LineChartData archieveDataNutri() {
    List<FlSpot> myNutriArchieveSpot = [];

    for (var j = 0; j < myNutriArchieve.length; j++) {
      myMaxNutriArchieve.add(myNutriArchieve[j]);
    }

    myMaxNutriArchieve.sort();

    for (var k = 0; k < myNutriArchieve.length; k++) {
      myNutriArchieveSpot.add(FlSpot(
          k.toDouble(),
          (myNutriArchieve[k] /
              10))); //myKcalMaxArcheive.last가 최대값 => 최대값으로 나누고 *8로 해서 띄워야함

    }
    List<Color> colorYellow = [Colors.yellow[500], Colors.yellow[500]];
    myMaxNutriArchieve = [];
    // setState(() {});
    return LineChartData(
      lineTouchData: LineTouchData(enabled: true),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 10,
          getTextStyles: (value) => const TextStyle(
              color: Color(0xff68737d),
              fontWeight: FontWeight.bold,
              fontSize: 12),
          getTitles: (value) {
            // switch (value.toInt()) {
            //   case 2:
            //     return 'MAR';
            //   case 5:
            //     return 'JUN';
            //   case 8:
            //     return 'SEP';
            // }

            // print(myPersonTimeArchieveInfo[value.toInt()]);
            List title = myPersonTimeArchieveInfo[value.toInt()];

            if (value % (myPersonTimeArchieveInfo.length ~/ 5 + 1) == 0) {
              return title[1].toString() + "/" + title[2].toString();
            }
            return '';
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => const TextStyle(
            color: Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
            }
            // print(value);

            return value == 0
                ? "${value.toInt()}%"
                : value.toInt() >= 11
                    ? ""
                    : "${value.toInt()}0%";
          },
          reservedSize: 28,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: (myNutriArchieveSpot.length.toDouble() - 1) * 1.1,
      minY: 0,
      maxY: 12,
      lineBarsData: [
        LineChartBarData(
          spots: myNutriArchieveSpot,
          isCurved: false,
          colors: colorYellow,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors: colorYellow.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
    );
  }
}
