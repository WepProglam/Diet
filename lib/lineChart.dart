import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'db_helper.dart';
import 'model.dart';

final dbHelperPerson = DBHelperPerson();

class LineChartSample2 extends StatefulWidget {
  int index = 0;
  LineChartSample2({this.index});
  @override
  _LineChartSample2State createState() => _LineChartSample2State(index: index);
}

class _LineChartSample2State extends State<LineChartSample2> {
  int index = 0;
  _LineChartSample2State({this.index});

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

    print(personTargetBmiSpot);
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.1,
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
                  child: personWeightSpot.isEmpty
                      ? null
                      : LineChart(mainData(index: index)),
                ),
              )),
        ),
        Positioned(
          child: AutoSizeText(
            "${graphTitle[index]}",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20),
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
    );
  }

  double myRounder(num a) {
    return a.toString().length < 4
        ? a.toDouble()
        : double.parse(a.toString().substring(0, 4));
  }

  LineChartData mainData({int index}) {
    List<double> maxInfo = [];
    print(index);
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

  LineChartData avgData() {
    return LineChartData(
      lineTouchData: LineTouchData(enabled: false),
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
          reservedSize: 22,
          getTextStyles: (value) => const TextStyle(
              color: Color(0xff68737d),
              fontWeight: FontWeight.bold,
              fontSize: 16),
          getTitles: (value) {
            switch (value.toInt()) {
              case 2:
                return 'MAR';
              case 5:
                return 'JUN';
              case 8:
                return 'SEP';
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
            fontSize: 15,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return '10k';
              case 3:
                return '30k';
              case 5:
                return '50k';
            }
            return '';
          },
          reservedSize: 28,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(0, 3.44),
            FlSpot(2.6, 3.44),
            FlSpot(4.9, 3.44),
            FlSpot(6.8, 3.44),
            FlSpot(8, 3.44),
            FlSpot(9.5, 3.44),
            FlSpot(11, 3.44),
          ],
          isCurved: true,
          colors: [
            ColorTween(begin: gradientColors[0], end: gradientColors[1])
                .lerp(0.2),
            ColorTween(begin: gradientColors[0], end: gradientColors[1])
                .lerp(0.2),
          ],
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(show: true, colors: [
            ColorTween(begin: gradientColors[0], end: gradientColors[1])
                .lerp(0.2)
                .withOpacity(0.1),
            ColorTween(begin: gradientColors[0], end: gradientColors[1])
                .lerp(0.2)
                .withOpacity(0.1),
          ]),
        ),
      ],
    );
  }
}
