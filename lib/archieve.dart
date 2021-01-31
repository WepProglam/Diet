import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_application_1/indicator.dart';
import 'package:flutter_application_1/model.dart';

import 'appBar.dart';
import 'calculate.dart';
import 'db_helper.dart';
import 'lineChart.dart';

//그래프 표시 버튼 위치 달력 우측 하단
final dbHelperDietHistory = DBHelperDietHistory();
final dbHelperDiet = DBHelperDiet();
final dbHelperPerson = DBHelperPerson();
int calenderWidthFlex = 35;
Color listViewColor = Colors.deepOrangeAccent[700];
Color iconColor = Colors.deepOrangeAccent[400];

List<List<dynamic>> allAchieveKcal = [];
List<List<dynamic>> allAchieveNutri = [];
List<DietHistory> allDietHistory = [];

List<num> sendingArchieveKcal = [];
List<num> sendingAchieveNutri = [];
List<dynamic> sendingArchievedate = [];
// final dbHelper

class Archieve extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyHomePage(title: 'Main Page');
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DietHistory dietHistory;
  Person person;

  //이게 계속 실행됨

  @override
  void didChangeDependencies() async {
    allAchieveKcal = [];
    allAchieveNutri = [];
    sendingAchieveNutri = [];
    sendingArchievedate = [];
    sendingArchieveKcal = [];
    await getInfo();
    super.didChangeDependencies();
  }

  void getAllDietHistory() async {
    allDietHistory = [];
    allAchieveKcal = [];
    allAchieveNutri = [];
    await dbHelperDietHistory.getAllMyDietHistory().then((val) {
      allDietHistory = val;
    });
  }

  void getInfo() async {
    // print("12312312");
    // String dateData = '${DateTime.now().toString().substring(0, 10)}';

    await getAllDietHistory();

    await dbHelperPerson.getLastPerson().then((val) {
      person = val;
    });
    await calculatekcalAchieve();

    setState(() {});
  }

  void calculatekcalAchieve() {
    allAchieveKcal = [];
    allAchieveNutri = [];
    sendingAchieveNutri = [];
    sendingArchievedate = [];
    sendingArchieveKcal = [];
    // print("printing");
    print("here is archi");

    for (var item in allDietHistory) {
      num totalCal = 0;
      num car = 0;
      num pro = 0;
      num fat = 0;
      // print("printing");

      if (item != null) {
        for (var i = 0; i < 4; i++) {
          // print("printing");

          switch (i) {
            case 0:
              Map breakfast = jsonDecode(item.breakFast);
              if (breakfast != "null" && breakfast != null) {
                if (breakfast['isItConfirm'] == "true") {
                  totalCal += num.parse(breakfast['kcal']);
                  num carRatio =
                      num.parse(breakfast["nutri"].split(":")[0]) / 100;
                  num proRatio =
                      num.parse(breakfast["nutri"].split(":")[1]) / 100;
                  num fatRatio =
                      num.parse(breakfast["nutri"].split(":")[2]) / 100;

                  car += carRatio * num.parse(breakfast['kcal']);
                  pro += proRatio * num.parse(breakfast['kcal']);
                  fat += fatRatio * num.parse(breakfast['kcal']);
                }
              }
              // print(dietConfirmConfirm);

              break;
            case 1:
              Map lunch = jsonDecode(item.lunch);
              if (lunch != "null" && lunch != null) {
                if (lunch['isItConfirm'] == "true") {
                  totalCal += num.parse(lunch['kcal']);

                  num carRatio = num.parse(lunch["nutri"].split(":")[0]) / 100;
                  num proRatio = num.parse(lunch["nutri"].split(":")[1]) / 100;
                  num fatRatio = num.parse(lunch["nutri"].split(":")[2]) / 100;

                  car += carRatio * num.parse(lunch['kcal']);
                  pro += proRatio * num.parse(lunch['kcal']);
                  fat += fatRatio * num.parse(lunch['kcal']);
                }
              }

              break;
            case 2:
              Map dinner = jsonDecode(item.dinner);
              if (dinner != "null" && dinner != null) {
                if (dinner['isItConfirm'] == "true") {
                  totalCal += num.parse(dinner['kcal']);

                  num carRatio = num.parse(dinner["nutri"].split(":")[0]) / 100;
                  num proRatio = num.parse(dinner["nutri"].split(":")[1]) / 100;
                  num fatRatio = num.parse(dinner["nutri"].split(":")[2]) / 100;

                  car += carRatio * num.parse(dinner['kcal']);
                  pro += proRatio * num.parse(dinner['kcal']);
                  fat += fatRatio * num.parse(dinner['kcal']);
                }
              }

              break;
            case 3:
              Map snack = jsonDecode(item.snack);
              if (snack != "null" && snack != null) {
                if (snack['isItConfirm'] == "true") {
                  totalCal += num.parse(snack['kcal']);

                  num carRatio = num.parse(snack["nutri"].split(":")[0]) / 100;
                  num proRatio = num.parse(snack["nutri"].split(":")[1]) / 100;
                  num fatRatio = num.parse(snack["nutri"].split(":")[2]) / 100;

                  car += carRatio * num.parse(snack['kcal']);
                  pro += proRatio * num.parse(snack['kcal']);
                  fat += fatRatio * num.parse(snack['kcal']);
                }
              }

              break;

            default:
          }
        }
        List<num> nutriRatio;
        switch (person.purpose) {
          case 0: //다이어트
            nutriRatio = [5, 3, 2];
            break;
          case 1: //벌크업
            nutriRatio = [4, 4, 2];

            break;
          case 2: //릴매스업
            nutriRatio = [3, 4, 3];
            break;
          default:
        }
        // print([item.date, nutriRatio, car, pro, fat]);
        num correctNutri = correctness(nutriRatio, [car, pro, fat]);
        num correct =
            (1 - ((person.metabolism - totalCal) / person.metabolism).abs()) *
                100;
        print([correctNutri, correct, item.date]);
        allAchieveKcal.add([item.date.split('-').sublist(0, 3), correct]);
        allAchieveNutri.add([item.date.split('-').sublist(0, 3), correctNutri]);
      } else {
        allAchieveKcal.add([item.date.split('-').sublist(0, 3), 0]);
        allAchieveNutri.add([item.date.split('-').sublist(0, 3), 0]);
      }
      // print("printing");

      sendingArchieveKcal = [];
      sendingAchieveNutri = [];
      sendingArchievedate = [];

      sortDate();
      sortMonth();
      sortYear();

      for (var i = 0; i < allAchieveKcal.length; i++) {
        sendingArchieveKcal.add(allAchieveKcal[i][1]);
        sendingAchieveNutri.add(allAchieveNutri[i][1]);
        sendingArchievedate.add(allAchieveKcal[i][0]);
      }
      // print(sendingAchieveNutri);
      // print(sendingArchieveKcal);
    }
  }

  void sortMonth() {
    allAchieveKcal.sort((a, b) => a[0][1].compareTo(b[0][1]));
    allAchieveNutri.sort((a, b) => a[0][1].compareTo(b[0][1]));
  }

  void sortDate() {
    allAchieveKcal.sort((a, b) => a[0][2].compareTo(b[0][2]));
    allAchieveNutri.sort((a, b) => a[0][2].compareTo(b[0][2]));
  }

  void sortYear() {
    allAchieveKcal.sort((a, b) => a[0][0].compareTo(b[0][0]));
    allAchieveNutri.sort((a, b) => a[0][0].compareTo(b[0][0]));
  }

  @override
  void initState() {
    allAchieveKcal = [];
    allAchieveNutri = [];
    sendingAchieveNutri = [];
    sendingArchievedate = [];
    sendingArchieveKcal = [];
    getInfo();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // getInfo();
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Row(children: [
          // Spacer(flex: 1),
          Expanded(
              flex: 20,
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: GestureDetector(
                      // onVerticalDragUpdate: (details) {
                      //   print(details);
                      // },
                      child: Column(
                    children: [
                      // Spacer(
                      //   flex: 1,
                      // ),

                      //달력

                      Expanded(
                        flex: calenderWidthFlex,
                        child: Container(
                            decoration: BoxDecoration(
                              // color: Color(0x774E0D0D),
                              border: Border.all(
                                  // color: Color(0xFF4E0D0D),
                                  width: 5),
                            ),
                            child: returnGraph()),
                      ),
                      // Spacer(
                      //   flex: 1,
                      // ),

                      //식단
                      Expanded(
                          flex: 16,
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Container(
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        // decoration:
                                        //     BoxDecoration(
                                        //         color: Colors
                                        //             .black),
                                        child: Center(
                                            child: Text(
                                          "",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700),
                                        )),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 5,
                                        child: Container(
                                          child: Center(
                                              child: Stack(
                                            children: [],
                                          )),
                                          // decoration:
                                          //     BoxDecoration(
                                          //         color: Colors
                                          //             .white),
                                        ))
                                  ],
                                ),
                              ))
                          // decoration: BoxDecoration(
                          //     color: Colors.white),

                          ),
                      // Spacer(
                      //   flex: 2,
                      // ),
                      // Spacer(
                      //   flex: 10,
                      // ),
                      Spacer(
                        flex: 2,
                      ),
                      //달력
                    ],
                  ))))
        ]));
  }

  num todayCar;
  num todayPro;
  num todayFat;
  num todaykcal;
  num correct;
  num targetKcal;
  void getTodayCalroie() async {
    // print("strat" * 100);
    String now = DateTime.now().toString().substring(0, 10);
    Map todayDietInfo = {};

    await dbHelperDietHistory.getDietHistory(now).then((val) {
      if (val != null) {
        todayDietInfo["b"] =
            val.breakFast != "null" ? jsonDecode(val.breakFast) : null;
        todayDietInfo["l"] = val.lunch != "null" ? jsonDecode(val.lunch) : null;
        todayDietInfo["d"] =
            val.dinner != "null" ? jsonDecode(val.dinner) : null;
        todayDietInfo["s"] = val.snack != "null" ? jsonDecode(val.snack) : null;
      }
    });
    var keys = todayDietInfo.keys;
    todayCar = 0.0;
    todayPro = 0.0;
    todayFat = 0.0;
    todaykcal = 0.0;
    for (var item in keys) {
      if (todayDietInfo[item] != null) {
        List<String> nutriString = todayDietInfo[item]["nutri"].split(":");
        List<num> nutri = List(3);

        // print(nutri);
        for (var i = 0; i < 3; i++) {
          nutri[i] = num.parse(nutriString[i]);
        }
        // nutri = [num.parse(nutri[0]), num.parse(nutri[1]), num.parse(nutri[2])];
        num nutriTotal = nutri[0] + nutri[1] + nutri[2];
        todaykcal += num.parse(todayDietInfo[item]["kcal"]);
        todayCar +=
            nutri[0] / nutriTotal * num.parse(todayDietInfo[item]["kcal"]);
        todayPro +=
            nutri[1] / nutriTotal * num.parse(todayDietInfo[item]["kcal"]);
        todayFat +=
            nutri[2] / nutriTotal * num.parse(todayDietInfo[item]["kcal"]);
      }
    }
    List<num> targetNutri = [3, 4, 3]; //디폴트(다이어트)
    if (person != null) {
      targetKcal = person.metabolism;
      switch (person.purpose) {
        case 0:
          targetNutri = [3, 4, 3];
          break;
        case 1:
          targetNutri = [4, 4, 2];

          break;
        case 2:
          targetNutri = [5, 3, 2];
          break;
        default:
          targetNutri = [3, 4, 3];
          break;
      }
    }
    correct = correctness(targetNutri, [todayCar, todayPro, todayFat]);
  }

  Widget returnGraph() {
    // getInfo();
    // print("sendign");
    // print(sendingArchieveKcal);
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Column(
              children: [
                // Spacer(
                //   flex: 1,
                // ),
                SizedBox(
                  height: 20,
                ),
                LineChartSample2(
                  index: -1,
                  kcalArchieve: sendingArchieveKcal,
                  nutriArchieve: sendingAchieveNutri,
                  personTimeArchieveInfo: sendingArchievedate,
                ),
                // Spacer(
                //   flex: 2,
                // ),
              ],
            ),
          ],
        ));
  }

  var graphIconColor = Colors.white;

  Widget colorIndicator() {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Indicator(
            color: Colors.deepOrangeAccent[400],
            isSquare: true,
            size: 10,
            text: '열량 성취도',
          ),
          Indicator(
            color: Colors.deepOrangeAccent,
            isSquare: true,
            size: 10,
            text: '영양성분 성취도',
          ),
        ],
      ),
    );
  }
}
