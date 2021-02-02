import 'dart:convert';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'db_helper.dart';
import 'model.dart';
import 'appBar.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'indicator.dart';

class Activity extends StatelessWidget {
  const Activity({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActivityPage();
  }
}

class ActivityPage extends StatefulWidget {
  ActivityPage({Key key}) : super(key: key);

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  var dbHelperPerson = DBHelperPerson();

  TextEditingController bmrText = TextEditingController();
  TextEditingController amText = TextEditingController();
  TextEditingController carbohydrateText = TextEditingController();
  int _nutriRateValue = 1;
  int _activityValue = 1;
  var readOnlyBool = true;

  static const double barWidth = 22;
  List<int> nutriRate = [5, 3, 2];
  int carbo = 5;
  int carboPro = 8;

  var hint = {};

  num bmr;

  /* Future<Map> getHint() async {
    var hint1 = {};
    await dbHelperPerson.getAllPerson().then((value) {
      // print("*"*100);
      // print(value.length);
      // print(value);
      // print("*"*100);
      hint1['height'] = value.isNotEmpty ? value.last.height : null;
      hint1['weight'] = value.isNotEmpty ? value.last.weight : null;
      hint1['bmi'] = value.isNotEmpty ? value.last.bmi : null;
      hint1['time'] = value.isNotEmpty ? value.last.time : null;
      hint1['muscleMass'] = value.isNotEmpty ? value.last.muscleMass : null;
      hint1['purpose'] = value.isNotEmpty ? value.last.purpose : null;
      hint1['achieve'] = value.isNotEmpty ? value.last.achieve : null;
      hint1['metabolism'] = value.isNotEmpty ? value.last.metabolism : null;
      hint1['activity'] = value.isNotEmpty ? value.last.activity : null;
      hint1['nutriRate'] = value.isNotEmpty ? value.last.nutriRate : null;
      hint1['weightTarget'] = value.isNotEmpty ? value.last.weightTarget : null;
      hint1['bmiTarget'] = value.isNotEmpty ? value.last.bmiTarget : null;
      hint1['muscleTarget'] = value.isNotEmpty ? value.last.muscleTarget : null;
    });
    return hint1;
  } */
  void getNutriRate(int purpose) {
    switch (purpose) {
      case 0:
        setState(() {
          nutriRate = [3, 4, 3];
          carbo = 3;
          carboPro = 7;
        });

        break;
      case 1:
        setState(() {
          nutriRate = [4, 4, 2];
          carbo = 4;
          carboPro = 8;
        });

        break;
      case 2:
        setState(() {
          nutriRate = [5, 3, 2];
          carbo = 5;
          carboPro = 8;
        });

        break;

      default:
    }
  }

  void bmrVal() async {
    final Map<String, Person> args = ModalRoute.of(context).settings.arguments;
    // if (args != null) {
    hint = args['person'].toMap();
    // print(hint);
    // } else {
    //   await getHint().then((value) {
    //     hint = value;
    //   });
    // }
    // print("=" * 100);
    // print(hint);
    //조건: 성별
    getNutriRate(hint['purpose']);
    if (hint['time'] != null) {
      if (hint['sex'] == 0) {
        bmr = (66.5 +
            (13.8 * hint['weight']) +
            (5 * hint['height']) -
            (6.8 * (hint['age'] - 1))); //23 -> person['age'] - 1 (만나이)

        bmrText.text = bmr.toStringAsFixed(1);
        // print(hint['nutriRate']);
        // print(hint['activity']);
        if (hint['metabolism'] != null) {
          if (amTextSetting(hint['activity'], bmr) == bmr) {
            amText.text = hint['metabolism'].toStringAsFixed(1);
          } else {
            amText.text = addOrSubAm(amTextSetting(hint['activity'], bmr))
                .toStringAsFixed(1);
          }
          setState(() {
            _nutriRateValue = hint['nutriRate'];
            _activityValue = hint['activity'];
          });
        } else {
          amText.text = addOrSubAm(amTextSetting(hint['activity'], bmr))
              .toStringAsFixed(1);
        }
        hint['metabolism'] = num.parse(amText.value.text);
      } else {
        bmr = (655.1 +
            (9.6 * hint['weight']) +
            (1.8 * hint['height']) -
            (4.7 * (hint['age'] - 1)));
        bmrText.text = bmr.toStringAsFixed(1);
        if (hint['metabolism'] != null) {
          if (amTextSetting(hint['activity'], bmr) == bmr) {
            amText.text = hint['metabolism'].toStringAsFixed(1);
          } else {
            amText.text = addOrSubAm(amTextSetting(hint['activity'], bmr))
                .toStringAsFixed(1);
          }

          setState(() {
            _nutriRateValue = hint['nutriRate'];
            _activityValue = hint['activity'];
          });
        } else {
          amText.text = (bmr * 1.2).toStringAsFixed(1);
        }
        hint['metabolism'] = num.parse(amText.value.text);
      }
      // print(hint);
      // await savingInformation();
    } else {
      //이거 text 뭐라고 하지
      bmrText.text = '신체 정보 X';
      amText.text = bmrText.text;
    }

    if (hint['activity'] == 6) {
      readOnlyBool = false;
    } else {
      readOnlyBool = true;
    }
  }

  @override
  void didChangeDependencies() async {
    if (_activityValue != 6) {
      Future.delayed(Duration.zero).then((value) => bmrVal());
    }
    getNutriRate(hint['purpose']);

    super.didChangeDependencies();
  }

  // @override
  // initState() {
  //   getNutriRate(hint['purpose']);

  //   super.initState();
  // }

  Widget metabolicRate(String mr, TextEditingController controller) {
    String title = '';
    bool focusBool;
    var fontWeight;
    var fontColor;
    double fontSize;

    if (mr == 'BMR') {
      title = '기초대사량(BMR)';
      focusBool = false;
      fontWeight = FontWeight.normal;
      fontColor = Colors.white;
      fontSize = 30;
    } else if (mr == 'AM') {
      title = '1일 총 에너지 대사량';
      focusBool = true;
      fontWeight = FontWeight.bold;
      fontColor = Colors.deepOrangeAccent[700];
      fontSize = 80;
    }

    return Container(
      padding: EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
          border: Border(top: BorderSide(width: 1, color: Colors.white38))),
      child: Column(
        children: [
          AutoSizeText(
            title,
            style: TextStyle(fontSize: 15),
            maxLines: 1,
          ),
          TextFormField(
            autofocus: focusBool,
            controller: controller,
            style: TextStyle(
              color: fontColor,
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            readOnly: readOnlyBool,
          ),
          AutoSizeText(
            'kcal',
            style: TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }

  /* Widget nutriRate() {
    return Center(
      child: Row(
        children: [
          Spacer(
            flex: 1,
          ),
          Text('탄 : 단 : 지'),
          Spacer(
            flex: 1,
          ),
          DropdownButton(
              value: _nutriRateValue,
              items: [
                DropdownMenuItem(child: Text('다이어트 3 : 4 : 3'), value: 1),
                DropdownMenuItem(child: Text('벌크업 4 : 4 : 2'), value: 2),
                DropdownMenuItem(child: Text('린매스업 5 : 3 : 2'), value: 3),
              ],
              onChanged: (value) {
                setState(() {
                  _nutriRateValue = value;
                });
              }),
          Spacer(
            flex: 1,
          ),
        ],
      ),
    );
  } */

  Widget selActivity() {
    return Center(
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Spacer(
            flex: 1,
          ),
          Center(
            child: DropdownButton(
                value: _activityValue,
                items: [
                  DropdownMenuItem(
                      child: Center(child: AutoSizeText('적은 활동 및 운동 X')),
                      value: 1),
                  DropdownMenuItem(
                      child: Center(child: AutoSizeText('가벼운 활동 및 주 1~3일 운동')),
                      value: 2),
                  DropdownMenuItem(
                      child: Center(child: AutoSizeText('보통 활동 및 주 3~5일 운동')),
                      value: 3),
                  DropdownMenuItem(
                      child: Center(child: AutoSizeText('적극적인 활동 및 주 6~7일 운동')),
                      value: 4),
                  DropdownMenuItem(
                      child: Center(child: AutoSizeText('매우 적극적인 활동 및 선수급 운동')),
                      value: 5),
                  DropdownMenuItem(
                      child: Center(child: AutoSizeText('직접 설정')), value: 6),
                ],
                onChanged: (value) {
                  setState(() {
                    _activityValue = value;
                    readOnlyBool = true;
                    if (_activityValue == 1) {
                      amText.text = addOrSubAm(num.parse(bmrText.text) * 1.2)
                          .toStringAsFixed(1);
                    } else if (_activityValue == 2) {
                      amText.text = addOrSubAm(num.parse(bmrText.text) * 1.375)
                          .toStringAsFixed(1);
                    } else if (_activityValue == 3) {
                      amText.text = addOrSubAm(num.parse(bmrText.text) * 1.555)
                          .toStringAsFixed(1);
                    } else if (_activityValue == 4) {
                      amText.text = addOrSubAm(num.parse(bmrText.text) * 1.725)
                          .toStringAsFixed(1);
                    } else if (_activityValue == 5) {
                      amText.text = addOrSubAm(num.parse(bmrText.text) * 1.9)
                          .toStringAsFixed(1);
                    } else if (_activityValue == 6) {
                      amText.text = '';
                      setState(() {
                        readOnlyBool = false;
                      });
                    }
                    hint['metabolism'] = num.parse(amText.value.text);
                  });
                }),
          ),
          Spacer(
            flex: 1,
          ),
        ],
      ),
    );
  }

  num amTextSetting(int i, num bmr) {
    if (i == 1) {
      return bmr * 1.2;
    } else if (i == 2) {
      return bmr * 1.375;
    } else if (i == 3) {
      return bmr * 1.555;
    } else if (i == 4) {
      return bmr * 1.725;
    } else if (i == 5) {
      return bmr * 1.9;
    } else if (i == 6) {
      return bmr;
    } else {
      return bmr;
    }
  }

  num addOrSubAm(num am) {
    switch (hint['purpose']) {
      case 0:
        am -= 500;
        break;
      case 1:
        am += 500;
        break;
      case 2:
        am = am;
        break;
      default:
        break;
    }
    return am;
  }

  Widget nutriRatioBarChart() {
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
                            return '';
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
                          value == carbo || value == carboPro,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text("METABOLIC RATE"),
          actions: <Widget>[]),
      // drawer: NavDrawer(),
      body: SingleChildScrollView(
        child: SizedBox(
            height: MediaQuery.of(context).size.height * 6 / 7,
            child: Center(
              child: Column(
                children: [
                  // Spacer(
                  //   flex: 1,
                  // ),
                  Container(
                    // color: Colors.yellow,
                    child: metabolicRate('BMR', bmrText),
                  ),

                  Spacer(flex: 3),
                  // BarChartSample5(
                  //   purpose: hint['purpose'],
                  // ),
                  nutriRatioBarChart(),
                  Spacer(
                    flex: 1,
                  ),
                  Container(
                      padding: EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                          border: Border(
                              top:
                                  BorderSide(width: 1, color: Colors.white38))),
                      child: selActivity()),
                  Text('주로 하는 활동을 선택해주세요'),
                  Spacer(
                    flex: 1,
                  ),
                  // nutriRate(),
                  // Text('탄수화물, 단백질, 지방의 열량 비율을 선택해주세요'),
                  Spacer(
                    flex: 1,
                  ),
                  Container(
                    // color: Colors.yellow,
                    child: metabolicRate('AM', amText),
                  ),
                  // Spacer(
                  //   flex: 1,
                  // ),
                  // FloatingActionButton(
                  //     child: Icon(Icons.done),
                  //     // backgroundColor: Color(0xFF7EE0CC),
                  //     onPressed: () async {
                  //       String time = DateFormat('yyyy-MM-dd')
                  //           .format(DateTime.now())
                  //           .toString();
                  //       var person = Person(
                  //         height: hint['height'],
                  //         weight: hint['weight'],
                  //         bmi: hint['bmi'],
                  //         muscleMass: hint['muscleMass'],
                  //         purpose: hint['purpose'],
                  //         time: time,
                  //         achieve: hint['achieve'],
                  //         metabolism: num.parse(amText.value.text),
                  //         activity: _activityValue,
                  //         nutriRate: _nutriRateValue,
                  //         weightTarget: hint['weightTarget'],
                  //         bmiTarget: hint['bmiTarget'],
                  //         muscleTarget: hint['muscleTarget'],
                  //       );
                  //       print(person.metabolism);
                  //       await dbHelperPerson.createHelper(person);
                  //       Navigator.pop(context);
                  //       Navigator.pop(context);
                  //     }),
                  // Spacer(
                  //   flex: 1,
                  // ),
                ],
              ),
            )),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.done),
          // backgroundColor: Color(0xFF7EE0CC),
          onPressed: () async {
            // await savingInformation();
            String time =
                DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();

            var person = Person(
                height: hint['height'],
                weight: hint['weight'],
                bmi: hint['bmi'],
                muscleMass: hint['muscleMass'],
                purpose: hint['purpose'],
                time: time,
                achieve: hint['achieve'],
                metabolism: num.parse(amText.value.text),
                activity: _activityValue,
                weightTarget: hint['weightTarget'],
                bmiTarget: hint['bmiTarget'],
                muscleTarget: hint['muscleTarget'],
                age: hint['age'],
                sex: hint['sex']);
            // print(person.metabolism);
            await dbHelperPerson.createHelper(person);

            // Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.popAndPushNamed(context, '/');
            // Navigator.pushReplacementNamed(context, '/');

            // Navigator.popAndPushNamed(context, '/mainPage');
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // void savingInformation() async {
  //   String time = DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();

  //   var person = Person(
  //     height: hint['height'],
  //     weight: hint['weight'],
  //     bmi: hint['bmi'],
  //     muscleMass: hint['muscleMass'],
  //     purpose: hint['purpose'],
  //     time: time,
  //     achieve: hint['achieve'],
  //     metabolism: num.parse(amText.value.text),
  //     activity: _activityValue,
  //     weightTarget: hint['weightTarget'],
  //     bmiTarget: hint['bmiTarget'],
  //     muscleTarget: hint['muscleTarget'],
  //   );
  //   // print(person.metabolism);
  //   await dbHelperPerson.createHelper(person);
  // }
}
