import 'dart:async';
import 'dart:convert';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application_1/addDiet.dart';
import 'package:flutter_application_1/dietModelSaver.dart';
import 'package:flutter_application_1/indicator.dart';
import 'package:flutter_application_1/model.dart';
import 'package:flutter_application_1/piChart.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'appBar.dart';
import 'calculate.dart';
import 'db_helper.dart';
import 'lineChart.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

//그래프 표시 버튼 위치 달력 우측 하단
final dbHelperDietHistory = DBHelperDietHistory();
final dbHelperDiet = DBHelperDiet();
final dbHelperPerson = DBHelperPerson();
int calenderWidthFlex = 35;
Color listViewColor = Colors.deepOrangeAccent[700];
Color iconColor = Colors.deepOrangeAccent[400];
// final dbHelper

class MainPage extends StatelessWidget {
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
  var date = 1;
  var mealTime = "false";
  var calender_year = DateTime.now().year; //달력 상 표기 되는 달력
  var calender_month = DateTime.now().month;
  var calender_date = DateTime.now().day;

  num temp_year;
  num temp_month;
  num temp_date;
  String calenderYear;
  String calenderMonth;
  String calenderDate;
  String dateData;
  var daysFirstWeek;
  var daysLastWeek;
  var lastDayDateTime;
  bool isItCalender = true;
  bool switchControl = false;
  DietHistory dietHistory;
  Person person;

  List<num> nutriRatioCopy = [3, 4, 3];

  FocusScopeNode myFocusNode = FocusScopeNode();
  // ScrollController _controller = new ScrollController();
  List<bool> isSelected = [true, false];
  List<List<bool>> dietAdded = [
    [false, false, false, false],
    [false, false, false, false],
    [false, false, false, false],
    [false, false, false, false]
  ];
  List<num> completedDates = [];
  num completedMonth = 0;

  List<bool> dietConfirm = [false, false, false, false];
  List<bool> diet = [false, false, false, false];
  List<bool> dietConfirmConfirm = [false, false, false, false];
  List<DietHistory> monthlyDietHistory = [];
  List<List<num>> monthlyAchieveKcal = [];
  List<List<num>> monthlyAchieveNutri = [];

  void initDateInfo() {
    dietAdded = [
      [false, false, false, false],
      [false, false, false, false],
      [false, false, false, false],
      [false, false, false, false]
    ];
    dietConfirm = [false, false, false, false];
    dietConfirmConfirm = [false, false, false, false];
  }

  // +버튼, adddiet로 가는지, savedDiet로 가는지
  List<Map> todayDietList = List<Map>(4);
  List<Map> anyDietList = List<Map>(4);
  List<Widget> itemList = [];
  List<Widget> itemListPast = [];
  num totalCalorie = 0;

  num targetKcal;
  //이게 계속 실행됨
  void getConfirmedIndex(DietHistory myDietHistory) async {
    try {
      if (myDietHistory.breakFast != "null") {
        Map tempDiet = jsonDecode(myDietHistory.breakFast);
        Diet myDiet;
        // print(tempDiet);
        // print(tempDiet['dietName']);
        await dbHelperDiet.getDiet(tempDiet['dietName']).then((val) {
          myDiet = val;
          // print(val);
          if (dietConfirmConfirm[0]) {
            dietAdded[0] = [true, true, true, true];
            dietConfirm[0] = true;
          } else {
            dietAdded[0] = [true, true, true, false];
            dietConfirm[0] = false;
          }

          todayDietList[0] = {};
          todayDietList[0]['foodInfo'] = jsonDecode(myDiet.foodInfo);
          todayDietList[0]['dietName'] = myDiet.dietName;

          todayDietList[0]["kcal"] = num.parse(tempDiet["kcal"]);

          for (var i = 0;
              i < todayDietList[0]['foodInfo']['foods'].length;
              i++) {
            todayDietList[0]['foodInfo']['foods'][i] =
                todayDietList[0]['foodInfo']['foods'][i].values.toList();
          }
        }, onError: (e) {
          // print(e);
        });
      }
      if (myDietHistory.lunch != "null") {
        Map tempDiet = jsonDecode(myDietHistory.lunch);
        Diet myDiet;
        await dbHelperDiet.getDiet(tempDiet['dietName']).then((val) {
          myDiet = val;
          todayDietList[1] = {};
          todayDietList[1]["foodInfo"] = jsonDecode(myDiet.foodInfo);
          todayDietList[1]['dietName'] = myDiet.dietName;
          todayDietList[1]["kcal"] = num.parse(tempDiet["kcal"]);
          for (var i = 0;
              i < todayDietList[1]['foodInfo']['foods'].length;
              i++) {
            todayDietList[1]['foodInfo']['foods'][i] =
                todayDietList[1]['foodInfo']['foods'][i].values.toList();
            if (dietConfirmConfirm[1]) {
              dietAdded[1] = [true, true, true, true];
              dietConfirm[1] = true;
            } else {
              dietAdded[1] = [true, true, true, false];
              dietConfirm[1] = false;
            }
          }
        }, onError: (e) {
          // print(e);
        });
      }
      if (myDietHistory.dinner != "null") {
        todayDietList[2] = {};

        Map tempDiet = jsonDecode(myDietHistory.dinner);
        Diet myDiet;
        await dbHelperDiet.getDiet(tempDiet['dietName']).then((val) {
          myDiet = val;
          todayDietList[2]['foodInfo'] = jsonDecode(myDiet.foodInfo);
          todayDietList[2]['dietName'] = myDiet.dietName;
          todayDietList[2]["kcal"] = num.parse(tempDiet["kcal"]);

          for (var i = 0;
              i < todayDietList[2]['foodInfo']['foods'].length;
              i++) {
            todayDietList[2]['foodInfo']['foods'][i] =
                todayDietList[2]['foodInfo']['foods'][i].values.toList();
          }
          if (dietConfirmConfirm[2]) {
            dietAdded[2] = [true, true, true, true];
            dietConfirm[2] = true;
          } else {
            dietAdded[2] = [true, true, true, false];
            dietConfirm[2] = false;
          }
        }, onError: (e) {
          // print(e);
        });
      }
      if (myDietHistory.snack != "null") {
        todayDietList[3] = {};

        Map tempDiet = jsonDecode(myDietHistory.snack);
        Diet myDiet;
        await dbHelperDiet.getDiet(tempDiet['dietName']).then((val) {
          myDiet = val;
          todayDietList[3]['foodInfo'] = jsonDecode(myDiet.foodInfo);
          todayDietList[3]['dietName'] = myDiet.dietName;
          todayDietList[3]["kcal"] = num.parse(tempDiet["kcal"]);

          for (var i = 0;
              i < todayDietList[3]['foodInfo']['foods'].length;
              i++) {
            todayDietList[3]['foodInfo']['foods'][i] =
                todayDietList[3]['foodInfo']['foods'][i].values.toList();
          }
          if (dietConfirmConfirm[3]) {
            dietAdded[3] = [true, true, true, true];
            dietConfirm[3] = true;
          } else {
            dietAdded[3] = [true, true, true, false];
            dietConfirm[3] = false;
          }
        }, onError: (e) {
          // print(e);
        });
      }
    } catch (e) {
      // print(e);
    }
    // print("/");
    // print("/");

    setState(() {});
  }

  void getInfo() async {
    // print("12312312");
    // String dateData = '${DateTime.now().toString().substring(0, 10)}';

    await dbHelperDietHistory.getDietHistory(dateData).then((val) {
      dietHistory = val;
    });
    await dbHelperDietHistory
        .getMonthlyDietHistory(month: calender_month)
        .then((val) {
      monthlyDietHistory = val;
    });

    try {
      await checkConfirmDB();
      await dbHelperPerson.getLastPerson().then((val) {
        person = val;
      });
      await getConfirmedIndex(dietHistory);

      await calculatekcalAchieve();
    } catch (e) {}

    // setState(() {});
  }

  void changeIntToString() {
    calenderYear = calender_year.toString();
    calenderMonth = calender_month < 10
        ? "0" + calender_month.toString()
        : calender_month.toString();
    calenderDate = calender_date < 10
        ? "0" + calender_date.toString()
        : calender_date.toString();
    dateData = calenderYear + '-' + calenderMonth + '-' + calenderDate;
    // setState(() {
    //   // getInfo();
    // });
  }

  @override
  void didChangeDependencies() async {
    changeIntToString();
    initDateInfo();
    getToday();
    getInfo();
    getCompleteDate();
    getTodayCalroie();
    await dbHelperPerson.getLastPerson().then((value) => setState(() {
          targetKcal = value.metabolism;
          // person = value;
        }));
    super.didChangeDependencies();
  }

  void calculatekcalAchieve() {
    monthlyAchieveKcal = [];
    monthlyAchieveNutri = [];
    for (var item in monthlyDietHistory) {
      num totalCal = 0;
      num car = 0;
      num pro = 0;
      num fat = 0;
      if (item != null) {
        for (var i = 0; i < 4; i++) {
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
            nutriRatio = [3, 4, 3];
            nutriRatioCopy = [3, 4, 3];
            break;
          case 1: //벌크업
            nutriRatio = [4, 4, 2];
            nutriRatioCopy = [4, 4, 2];

            break;
          case 2: //릴매스업
            nutriRatio = [5, 3, 2];
            nutriRatioCopy = [5, 3, 2];
            break;
          default:
        }
        // print([item.date, nutriRatio, car, pro, fat]);
        num correctNutri = correctness(nutriRatio, [car, pro, fat]);
        num correct =
            (1 - ((person.metabolism - totalCal) / person.metabolism).abs()) *
                100;
        monthlyAchieveKcal.add([num.parse(item.date.split('-')[2]), correct]);
        monthlyAchieveNutri
            .add([num.parse(item.date.split('-')[2]), correctNutri]);
      } else {
        monthlyAchieveKcal.add([num.parse(item.date.split('-')[2]), 0]);
        monthlyAchieveNutri.add([num.parse(item.date.split('-')[2]), 0]);
      }
    }
    // print(monthlyAchieveKcal);
  }

  num _myOpacity = 0.0;
  void _changeOpacity() {
    setState(() => _myOpacity = 1.0);
  }

  void makeItemList(int index, {List<num> dateInfo}) async {
    //날짜 정보
    // await getConfirmedIndex();
    // print(dietConfirm);
    // print(dietAdded);
    var tempList = todayDietList[index] != null
        ? new List.from(todayDietList[index]['foodInfo']['foods'])
        : null;
    var tempNutriRate = todayDietList[index] != null
        ? todayDietList[index]['foodInfo']['nutri'].split(':')
        : null;
    // num tempCorrectness = todayDietList[index] != null
    //     ? correctness(todayDietList[index]['foodInfo']['nutri'].split(':'),await DBHelperPerson().getPerson().)
    //     : null;

    if (dietConfirm[index]) {
      itemList = [
        FractionallySizedBox(
            widthFactor: 1.0,
            heightFactor: 1.0,
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: listViewColor, width: 2)),
              child: Center(
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // for (var item in todayDietList[index]['foodInfo']['foods'])
                      //   AutoSizeText("${item[1]}  ${item[2]}g"),

                      //item[0] : 코드
                      //item[1] : 음식 이름
                      //item[2] : 음식 무게
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 12,
                        child: ListView.builder(
                            itemCount: tempList.length,
                            itemBuilder: (context, int i) {
                              return Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Spacer(),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 3,
                                    alignment: Alignment.centerLeft,
                                    child: AutoSizeText(
                                      tempList[i][1],
                                      maxLines: 1,
                                    ),
                                  ),
                                  // Spacer(),

                                  Container(
                                      width:
                                          MediaQuery.of(context).size.width / 4,
                                      alignment: Alignment.centerRight,
                                      child: AutoSizeText(
                                        (tempList[i][2] *
                                                    todayDietList[index]
                                                        ['kcal'] /
                                                    targetKcal)
                                                .toStringAsFixed(2) +
                                            ' g',
                                        maxLines: 1,
                                      )),
                                  // Spacer(),
                                ],
                              );
                            }),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      AutoSizeText(
                        "탄:단:지 = ${tempNutriRate[0]} : ${tempNutriRate[1]} : ${tempNutriRate[2]}",
                        maxLines: 1,
                      ),

                      AutoSizeText(
                          "총 칼로리 = ${(todayDietList[index]['kcal']).toStringAsFixed(2)} kcal",
                          maxLines: 1),
                      SizedBox(
                        height: 10,
                      ),
                    ]),
              ),
            ))
      ];
    } else {
      itemList = [
        dietAdded[index][0]
            ? AnimatedOpacity(
                opacity: dietAdded[index][0] ? 1.0 : 0.0,
                duration: Duration(seconds: 10),
                child: Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: GestureDetector(
                            child: FractionallySizedBox(
                              widthFactor: 1,
                              heightFactor: 1,
                              child: Container(
                                  child: Center(
                                      child: AutoSizeText(
                                    "새로운 식단 추가하기",
                                    maxLines: 1,
                                  )),
                                  decoration: BoxDecoration(
                                      // color: Colors.red,
                                      border: Border.all(
                                          color: listViewColor, width: 5))),
                            ),
                            onTap: () async {
                              Navigator.pushNamed(context, '/addDiet',
                                  arguments: <String, Map>{
                                    "pre": {
                                      "pre": "mainPage",
                                      "index": index,
                                      "dateTime":
                                          "$calender_year-$calender_month-$calender_date"
                                    }
                                  }).then((val) async {
                                todayDietList[index] = val;

                                todayDietList[index]['foodInfo'] = jsonDecode(
                                    todayDietList[index]['foodInfo']);
                                double percent = todayDietList[index]["rate"] /
                                    100; //80 => 0.8

                                print(percent);

                                todayDietList[index]['foodInfo']['kcal'] =
                                    person.metabolism * percent;

                                print(todayDietList[index]['foodInfo']['kcal']);

                                todayDietList[index]["kcal"] =
                                    todayDietList[index]['foodInfo']['kcal'];

                                todayDietList[index]["nutri"] =
                                    todayDietList[index]['foodInfo']['nutri'];
                                // print(val);

                                // print((todayDietList[index]['foodInfo']
                                //         ['kcal'] *
                                //     percent));

                                for (var i = 0;
                                    i <
                                        todayDietList[index]['foodInfo']
                                                ['foods']
                                            .length;
                                    i++) {
                                  todayDietList[index]['foodInfo']['foods'][i] =
                                      todayDietList[index]['foodInfo']['foods']
                                              [i]
                                          .values
                                          .toList();
                                }

                                await formatDietHistory(
                                        dietName: todayDietList[index]
                                            ['dietName'],
                                        flag: index,
                                        kcal: todayDietList[index]['foodInfo']
                                                ['kcal']
                                            .toString(),
                                        nutri: todayDietList[index]['foodInfo']
                                            ['nutri'],
                                        dateTime: dateData,
                                        isItConfirm: "false")
                                    .then((diet) {});
                                setState(() {
                                  dietAdded[index][2] =
                                      val == null ? false : true;
                                });
                              });
                            })),
                    Expanded(
                        flex: 1,
                        child: GestureDetector(
                            child: FractionallySizedBox(
                              widthFactor: 1,
                              heightFactor: 1,
                              child: Container(
                                  child: Center(
                                      child: AutoSizeText("저장된 식단 불러오기")),
                                  decoration: BoxDecoration(
                                      // color: Colors.red,
                                      border: Border(
                                          bottom: BorderSide(
                                              color: listViewColor, width: 5),
                                          top: BorderSide(
                                              color: listViewColor, width: 5),
                                          right: BorderSide(
                                              color: listViewColor,
                                              width: 5)))),
                            ),
                            onTap: () async {
                              await Navigator.pushNamed(context, '/searchDiet',
                                  arguments: <String, Map>{
                                    "pre": {
                                      "pre": "mainPage",
                                      "index": index,
                                      "dateTime":
                                          "$calender_year-$calender_month-$calender_date"
                                    }
                                  }).then((val) async {
                                todayDietList[index] = val;

                                todayDietList[index]['foodInfo'] = jsonDecode(
                                    todayDietList[index]['foodInfo']);
                                double percent = todayDietList[index]["rate"] /
                                    100; //80 => 0.8

                                todayDietList[index]['foodInfo']['kcal'] =
                                    person.metabolism * percent;

                                todayDietList[index]["kcal"] =
                                    todayDietList[index]['foodInfo']['kcal'];

                                todayDietList[index]["nutri"] =
                                    todayDietList[index]['foodInfo']['nutri'];
                                // print(val);

                                // print((todayDietList[index]['foodInfo']
                                //         ['kcal'] *
                                //     percent));

                                for (var i = 0;
                                    i <
                                        todayDietList[index]['foodInfo']
                                                ['foods']
                                            .length;
                                    i++) {
                                  todayDietList[index]['foodInfo']['foods'][i] =
                                      todayDietList[index]['foodInfo']['foods']
                                              [i]
                                          .values
                                          .toList();
                                }

                                await formatDietHistory(
                                        dietName: todayDietList[index]
                                            ['dietName'],
                                        flag: index,
                                        kcal: todayDietList[index]['foodInfo']
                                                ['kcal']
                                            .toString(),
                                        nutri: todayDietList[index]['foodInfo']
                                            ['nutri'],
                                        dateTime: dateData,
                                        isItConfirm: "false")
                                    .then((diet) {});
                                setState(() {
                                  dietAdded[index][2] =
                                      val == null ? false : true;
                                });
                              });
                            })),
                  ],
                ),
              )
            : GestureDetector(
                //border: Border.all(color: listViewColor, width: 2)
                child: FractionallySizedBox(
                  child: Container(
                    decoration: BoxDecoration(
                        // borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: listViewColor, width: 2)),
                    child: Center(
                        child: Icon(
                      Icons.add_circle_outline,
                      color: Colors.white70,
                      size: 40,
                    )),
                  ),
                  widthFactor: 1,
                  heightFactor: 1,
                ),
                onTap: () {
                  setState(() {
                    _changeOpacity();
                    dietAdded[index][0] = !dietAdded[index][0];
                  });
                },
              ),
        dietAdded[index][2] //
            ? GestureDetector(
                child: FractionallySizedBox(
                    widthFactor: 1.0,
                    heightFactor: 1.0,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.black),
                      child: Center(
                        child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height / 12,
                                child: ListView.builder(
                                    itemCount: tempList.length,
                                    itemBuilder: (context, int i) {
                                      return Row(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Spacer(),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                3,
                                            alignment: Alignment.centerLeft,
                                            child: AutoSizeText(
                                              tempList[i][1],
                                              style: TextStyle(
                                                  color: Colors
                                                      .deepOrangeAccent[700]),
                                              maxLines: 1,
                                            ),
                                          ),
                                          // Spacer(),
                                          Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  4,
                                              alignment: Alignment.centerRight,
                                              child: AutoSizeText(
                                                (tempList[i][2] *
                                                            todayDietList[index]
                                                                ['kcal'] /
                                                            targetKcal)
                                                        .toStringAsFixed(2) +
                                                    ' g',
                                                style: TextStyle(
                                                    color: Colors
                                                        .deepOrangeAccent[700]),
                                                maxLines: 1,
                                              )),
                                          // Spacer(),
                                        ],
                                      );
                                    }),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              AutoSizeText(
                                "탄 : 단 : 지 = ${tempNutriRate[0]} : ${tempNutriRate[1]} : ${tempNutriRate[2]}",
                                style: TextStyle(
                                    color: Colors.deepOrangeAccent[700]),
                                maxLines: 1,
                              ),

                              AutoSizeText(
                                  "총 칼로리 = ${todayDietList[index]['kcal'].toStringAsFixed(2)} kcal",
                                  style: TextStyle(
                                      color: Colors.deepOrangeAccent[700]),
                                  maxLines: 1),
                              SizedBox(
                                height: 10,
                              ),
                              // for (var item in todayDietList[index]['foodInfo']
                              //     ['foods'])
                              //   //item[0] : 코드
                              //   //item[1] : 음식 이름
                              //   //item[2] : 음식 무게
                              //   AnimatedDefaultTextStyle(
                              //       duration: const Duration(milliseconds: 300),
                              //       style: TextStyle(
                              //         fontSize: 20.0,
                              //         color: dietConfirm[index]
                              //             ? Colors.red
                              //             : Colors.blueAccent,
                              //         fontWeight: dietConfirm[index]
                              //             ? FontWeight.w100
                              //             : FontWeight.bold,
                              //       ),
                              //       child: Text("${item[1]}  ${item[2]}g")),
                              // AnimatedDefaultTextStyle(
                              //   duration: const Duration(milliseconds: 300),
                              //   style: TextStyle(
                              //     fontSize: 20.0,
                              //     color: dietConfirm[index]
                              //         ? Colors.red
                              //         : Colors.blueAccent,
                              //     fontWeight: dietConfirm[index]
                              //         ? FontWeight.w100
                              //         : FontWeight.bold,
                              //   ),
                              //   child: Text(
                              //       "영양성분 비율 : ${todayDietList[index]['foodInfo']['nutri']}"),
                              // ),
                              // AnimatedDefaultTextStyle(
                              //   duration: const Duration(milliseconds: 300),
                              //   style: TextStyle(
                              //     fontSize: 20.0,
                              //     color: dietConfirm[index]
                              //         ? Colors.red
                              //         : Colors.blueAccent,
                              //     fontWeight: dietConfirm[index]
                              //         ? FontWeight.w100
                              //         : FontWeight.bold,
                              //   ),
                              //   child:
                              //       Text("총 칼로리 : ${todayDietList[index]['kcal']}"),
                              // ),
                            ]),
                      ),
                    )),
                onTap: () {
                  // print(todayDietList[index]);
                  setState(() {
                    dietAdded[index][3] = !dietAdded[index][3];
                  });
                },
              )
            : Container(),
        dietAdded[index][3] //dietConfirm
            ? FractionallySizedBox(
                widthFactor: 1,
                heightFactor: 1,
                child: Container(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Spacer(flex: 1),
                        Expanded(
                          flex: 1,
                          child: RaisedButton(
                            child: Text("먹었"),
                            onPressed: () async {
                              print(todayDietList[index]['foodInfo']);
                              await formatDietHistory(
                                      dietName: todayDietList[index]
                                          ['dietName'],
                                      flag: index,
                                      kcal: todayDietList[index]['foodInfo']
                                              ['kcal']
                                          .toString(),
                                      nutri: todayDietList[index]['foodInfo']
                                          ['nutri'],
                                      dateTime: dateData,
                                      isItConfirm: "true")
                                  .then((diet) {});
                              getInfo();
                              getToday();
                              getCompleteDate();
                              print("wait finish");
                              setState(() {
                                //확정

                                dietConfirm[index] = true;
                                dietAdded[index][3] = false;
                              });
                              // print(todayDietList[index]);
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: RaisedButton(
                            child: Text("안먹었"),
                            onPressed: () {
                              setState(() {
                                dietConfirm[index] = false;
                                dietAdded[index] = [true, false, false, false];
                              });
                            },
                          ),
                        ),
                        Spacer(flex: 1),
                      ]),
                ))
            : Container(),
        dietAdded[index][0]
            ? Positioned(
                left: 10,
                child: GestureDetector(
                  child: Icon(
                    Icons.undo,
                    size: 35,
                  ),
                  onTap: () {
                    // print("123213123");
                    setState(() {
                      dietAdded[index] = dietAdded[index][2] == true
                          ? [true, false, false, false]
                          : [false, false, false, false];
                    });
                    print("뒤로가기");
                  },
                ),
              )
            : Container()
      ];
    }
  }

  @override
  void initState() {
    temp_year = calender_year;
    temp_month = calender_month;
    temp_date = calender_date;
    changeIntToString();
    getInfo();
    getToday();
    getCompleteDate();
    super.initState();
  }

  void getToday() async {
    await getTodayCalroie();
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // getInfo();
    var dateTime = DateTime(calender_year, calender_month, 1);
    var dayFirst =
        DateFormat('EEEE').format(DateTime(calender_year, calender_month, 1));
    lastDayDateTime = (dateTime.month < 12)
        ? new DateTime(dateTime.year, dateTime.month + 1, 0)
        : new DateTime(dateTime.year + 1, 1, 0);

    var dayLast = DateFormat('EEEE').format(lastDayDateTime);

    daysLastWeek = 7 - dayToDate(dayLast); //마지막 주에 몇일 있는지
    daysFirstWeek = 7 - dayToDate(dayFirst) + 1; //첫 주에 몇일 있는지
    int curIndex = 0;
    // SwiperController swiperController = new SwiperController();
    List<String> mealList = [
      "$temp_month월$temp_date일 아침",
      "$temp_month월$temp_date일 점심",
      "$temp_month월$temp_date일 저녁",
      "$temp_month월$temp_date일 간식"
    ];

    return Scaffold(
        // backgroundColor: Color(0xFFD7FFF1),
        appBar: basicAppBar(
            "$calender_year년 $calender_month월$calender_date일", context),
        drawer: NavDrawer(),
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              // Spacer(flex: 1),
              Expanded(
                  flex: 20,
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: PageView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: 2,
                          // onPageChanged: (page) {
                          //   if (page == 0) {
                          //     calender_year = DateTime.now().year;
                          //     calender_month = DateTime.now().month;
                          //     calender_date = DateTime.now().day;
                          //     changeIntToString();
                          //     getInfo();
                          //   }
                          // },
                          itemBuilder: (BuildContext context, int index) {
                            return index == 1
                                ? Column(
                                    children: [
                                      //page 1

                                      // Expanded(
                                      //   flex: 13,
                                      // ),
                                      Spacer(
                                        flex: 2,
                                      ),

                                      Expanded(
                                        flex: 7,
                                        child: SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Swiper(
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return FractionallySizedBox(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: listViewColor,
                                                          width: 2)),
                                                  child: Center(
                                                      child: Text(
                                                          "추천 식단이 들어갈 자리")),
                                                ),
                                                widthFactor: 1,
                                                heightFactor: 1,
                                              );
                                            },
                                            itemCount: 10,
                                            pagination: new SwiperPagination(),
                                            // control: new SwiperControl(),
                                          ),
                                        ),
                                      ),
                                      Spacer(flex: 2),
                                      Expanded(
                                          flex: 13,
                                          child: PieChartSample2(
                                              carbohydrate: todayCar,
                                              protein: todayPro,
                                              fat: todayFat,
                                              totalCalorie: todaykcal,
                                              correct: correct == null ||
                                                      (correct == 0)
                                                  ? 0.0
                                                  : correct.toDouble())
                                          // child:
                                          ),
                                      Spacer(
                                        flex: 1,
                                      ),
                                      // diet(date.toString()),
                                      // dietBox(mealTime, date),
                                      Expanded(
                                          flex: 10,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  flex: 1,
                                                  child: FractionallySizedBox(
                                                    child: Container(
                                                      // child: Text(),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  listViewColor,
                                                              width: 2)),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: person == null
                                                            ? [
                                                                SizedBox(
                                                                    height: 10),
                                                                AutoSizeText(
                                                                    "키"),
                                                                SizedBox(
                                                                    height: 10),
                                                                AutoSizeText(
                                                                    "몸무게"),
                                                                SizedBox(
                                                                    height: 10),
                                                                AutoSizeText(
                                                                    "체지방률"),
                                                                SizedBox(
                                                                    height: 10),
                                                                AutoSizeText(
                                                                    "골격근량"),
                                                                SizedBox(
                                                                    height: 10),
                                                              ]
                                                            : [
                                                                AutoSizeText(
                                                                    "키    ${person.height}"),
                                                                SizedBox(
                                                                    height: 10),
                                                                AutoSizeText(
                                                                    "몸무게    ${person.weight}"),
                                                                SizedBox(
                                                                    height: 10),
                                                                AutoSizeText(
                                                                    "체지방률    ${person.bmi}"),
                                                                SizedBox(
                                                                    height: 10),
                                                                AutoSizeText(
                                                                    "골격근량    ${person.muscleMass}"),
                                                                SizedBox(
                                                                    height: 10),
                                                              ],
                                                      ),
                                                      // decoration: BoxDecoration(
                                                      //     color: Colors.red),
                                                    ),
                                                    widthFactor: 1,
                                                    heightFactor: 1,
                                                  )),
                                              Expanded(
                                                  flex: 1,
                                                  child: FractionallySizedBox(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  listViewColor,
                                                              width: 2)),

                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: person == null
                                                            ? [
                                                                SizedBox(
                                                                    height: 10),
                                                                AutoSizeText(
                                                                    "목표 몸무게"),
                                                                SizedBox(
                                                                    height: 10),
                                                                AutoSizeText(
                                                                    "목표 체지방률"),
                                                                SizedBox(
                                                                    height: 10),
                                                                AutoSizeText(
                                                                    "목표 골격근량"),
                                                                SizedBox(
                                                                    height: 10),
                                                                AutoSizeText(
                                                                    "목표"),
                                                                SizedBox(
                                                                    height: 10),
                                                              ]
                                                            : [
                                                                SizedBox(
                                                                    height: 10),
                                                                Container(
                                                                  child: AutoSizeText(
                                                                      "목표 몸무게   ${person.weightTarget}"),
                                                                ),
                                                                SizedBox(
                                                                    height: 10),
                                                                AutoSizeText(
                                                                    "목표 체지방률    ${person.bmiTarget}"),
                                                                SizedBox(
                                                                    height: 10),
                                                                AutoSizeText(
                                                                    "목표 골격근량   ${person.muscleTarget}"),
                                                                SizedBox(
                                                                    height: 10),
                                                                AutoSizeText(
                                                                  "목표    ${nutriRatioCopy[0]} : ${nutriRatioCopy[1]} : ${nutriRatioCopy[2]}",
                                                                  maxLines: 1,
                                                                ),
                                                                SizedBox(
                                                                    height: 10),
                                                              ],
                                                      ),
                                                      // decoration: BoxDecoration(
                                                      //     color: Colors.blue),
                                                    ),
                                                    widthFactor: 1,
                                                    heightFactor: 1,
                                                  ))
                                            ],
                                          )),
                                      Spacer(
                                        flex: 2,
                                      ),
                                    ],
                                  )
                                :
                                //page 2
                                GestureDetector(
                                    // onVerticalDragUpdate: (details) {
                                    //   print(details);
                                    // },
                                    child: Column(
                                    children: [
                                      // Spacer(
                                      //   flex: 1,
                                      // ),

                                      //달력
                                      calenderMonthChange(),
                                      Expanded(
                                        flex: calenderWidthFlex,
                                        child: Container(
                                            decoration: BoxDecoration(
                                              // color: Color(0x774E0D0D),
                                              border: Border.all(
                                                  // color: Color(0xFF4E0D0D),
                                                  width: 5),
                                            ),
                                            child: isSelected[0]
                                                ? returnCalender()
                                                : returnGraph()),
                                      ),
                                      // Spacer(
                                      //   flex: 1,
                                      // ),

                                      //식단
                                      Expanded(
                                        flex: 16,
                                        child: SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Swiper(
                                            duration: 1500,
                                            itemBuilder: (BuildContext context,
                                                int listIndex) {
                                              makeItemList(listIndex);
                                              return Container(
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
                                                          mealList[listIndex],
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700),
                                                        )),
                                                      ),
                                                    ),
                                                    Expanded(
                                                        flex: 5,
                                                        child: Container(
                                                          child: Center(
                                                              child: Stack(
                                                            children: itemList,
                                                          )),
                                                          // decoration:
                                                          //     BoxDecoration(
                                                          //         color: Colors
                                                          //             .white),
                                                        ))
                                                  ],
                                                ),
                                                // decoration: BoxDecoration(
                                                //     color: Colors.white),
                                              );
                                            },
                                            itemCount: 4,
                                            pagination: new SwiperPagination(),
                                          ),
                                        ),
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
                                  ));
                          }))),
              // Spacer(
              //   flex: 1,
              // )
            ],
          ),
        ));
  }

  num todayCar;
  num todayPro;
  num todayFat;
  num todaykcal;
  num correct;

  void getTodayCalroie() async {
    // print("strat" * 100);
    String now = DateTime.now().toString().substring(0, 10);
    Map todayDietInfo = {};
    // todayCar = 0.0;
    // todayPro = 0.0;
    // todayFat = 0.0;
    // todaykcal = 0.0;
    // print(todayDietInfo);
    // print(todaykcal);
    // print("$todayCar $todayPro $todayFat");
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

    List<num> targetNutri = [3, 4, 3];
    //디폴트(다이어트)
    if (person != null) {
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

    // print(todayDietInfo);
    // print(todaykcal);
    // print("$todayCar $todayPro $todayFat");
    // print(todayCar + todayPro + todayFat);
  }

  Widget returnCalender() {
    return Column(
      children: [
        //이걸로 달력 윗부분 조절
        SizedBox(
          height: 10,
        ),
        calenderDayRow(), //요일
        calenderRow(1, tag: "first"),
        calenderRow(1 + daysFirstWeek), //첫주 다 채우고 새로운 주의 첫 일 ( ex) 1월 3일)
        calenderRow(8 + daysFirstWeek),
        calenderRow(15 + daysFirstWeek),
        calenderRow(22 + daysFirstWeek),
        calenderRow(29 + daysFirstWeek, tag: "end"),
      ],
    );
  }

  Widget returnGraph() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          return Stack(
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
                    index: index,
                  ),
                  // Spacer(
                  //   flex: 2,
                  // ),
                ],
              ),
            ],
          );
        },
        itemCount: 3,
        pagination: new SwiperPagination(),
        control: new SwiperControl(),
      ),
    );
  }

  int dayToDate(String day) {
    //첫, 마지막 주에 몇일 있는지 계산하기 위해 만든 함수
    int date;
    switch (day) {
      case 'Sunday':
        date = 1;
        break;
      case 'Monday':
        date = 2;
        break;
      case 'Tuesday':
        date = 3;
        break;
      case 'Wednesday':
        date = 4;
        break;
      case 'Thursday':
        date = 5;
        break;
      case 'Friday':
        date = 6;
        break;
      case 'Saturday':
        date = 7;
        break;
    }
    return date;
  }

  Widget calenderMonthChange() {
    //월 이동 함수
    return Expanded(flex: 3, child: calender());
  }

  void getCompleteDate() async {
    completedDates = [];
    await dbHelperDietHistory
        .getCompleteDietHistory(month: calender_month, year: calender_year)
        .then((val) {
      print(val);
      indicateCompleteDate(val);
    });
  }

  List<num> indicateCompleteDate(List<dynamic> dates) {
    // print(dates);
    for (var item in dates) {
      completedDates.add(num.parse(item.split('-').last));
    }
    // print(completedDates);
  }

  Widget calender() {
    return isItCalender
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(
                flex: 1,
              ),
              Expanded(
                flex: calenderWidthFlex,
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,

                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: InkWell(
                        child: Ink(
                            child:
                                Icon(Icons.arrow_back_ios_outlined, size: 25)),
                        onTap: () {
                          if (calender_month == 1) {
                            calender_year -= 1;
                            calender_month = 12;
                          } else {
                            calender_month -= 1;
                          }
                          getCompleteDate();
                          setState(() {});
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: InkWell(
                        child: Ink(
                            child: Icon(
                          Icons.arrow_forward_ios_outlined,
                          size: 25,
                        )),
                        onTap: () {
                          if (calender_month == 12) {
                            calender_year += 1;
                            calender_month = 1;
                          } else {
                            calender_month += 1;
                          }
                          getCompleteDate();
                          setState(() {});
                        },
                      ),
                    ),
                    // Spacer(
                    //   flex: 1,
                    // ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: AutoSizeText(
                        "$calender_year년 $calender_month월",
                        style: TextStyle(fontSize: 25),
                        maxLines: 1,
                      ),
                    ),
                    Spacer(),
                    calenderSwitch(),
                    // Spacer(
                    //   flex: 5,
                    // ),
                  ],
                ),
              ),
              Spacer(
                flex: 1,
              )
            ],
          )
        : Row(
            children: [
              Spacer(
                flex: 1,
              ),
              Expanded(
                flex: calenderWidthFlex,
                child: Row(
                  children: [
                    Spacer(flex: 10),
                    calenderSwitch(),
                  ],
                ),
              ),
              Spacer(
                flex: 1,
              )
            ],
          );
  }

  void toggleSwitch(bool value) {
    if (switchControl == false) {
      setState(() {
        switchControl = true;
        isItCalender = false;
      });
    } else {
      setState(() {
        switchControl = false;
        isItCalender = true;
      });
    }
  }

  var calenderIconColor = Colors.deepOrangeAccent[700];
  var graphIconColor = Colors.white;

  Widget calenderSwitch() {
    return Container(
      // decoration: BoxDecoration(color: Colors.yellow),
      child: Padding(
        padding: const EdgeInsets.only(top: 3.0, right: 0),
        child: ToggleButtons(
          // hoverColor: Colors.white,
          // highlightColor: Colors.black,
          // disabledColor: Colors.white,
          selectedColor: Colors.black,
          fillColor: Colors.black,

          children: <Widget>[
            Icon(
              Icons.date_range,
              color: calenderIconColor,
              size: 25,
            ),
            Icon(
              Icons.stacked_line_chart,
              size: 25,
              color: graphIconColor,
            ),
          ],
          onPressed: (int index) {
            setState(() {
              for (int buttonIndex = 0;
                  buttonIndex < isSelected.length;
                  buttonIndex++) {
                if (buttonIndex == index) {
                  isItCalender = false;
                  isSelected[buttonIndex] = true;
                  calenderIconColor = Colors.white;
                  graphIconColor = Colors.deepOrangeAccent[700];
                } else {
                  isItCalender = true;
                  isSelected[buttonIndex] = false;
                  calenderIconColor = Colors.deepOrangeAccent[700];
                  graphIconColor = Colors.white;
                }
              }
            });
          },
          isSelected: isSelected,
        ),
      ),
    );
  }

  Widget calenderDayRow() {
    //일월화수목금토
    return Expanded(
        flex: 2,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Spacer(
            //   flex: 1,
            // ),
            calenderBlock(
                dayText('일'), true, 0), //true면 border 없이, flase면 border 있이
            calenderBlock(dayText('월'), true, 0),
            calenderBlock(dayText('화'), true, 0),
            calenderBlock(dayText('수'), true, 0),
            calenderBlock(dayText('목'), true, 0),
            calenderBlock(dayText('금'), true, 0),
            calenderBlock(dayText('토'), true, 0),
            // Spacer(
            //   flex: 1,
            // ),
          ],
        ));
  }

  Widget dayText(String day) {
    return AutoSizeText(
      day,
      style: TextStyle(fontSize: 15),
      maxLines: 1,
    );
  }

  num fontSize = 15.0;

  Widget dateText(String date) {
    var targetDay =
        new DateTime(calender_year, calender_month, int.parse(date));
    var day = DateFormat('EEEE').format(targetDay).toString();

    if (date == DateTime.now().day.toString() &&
        calender_month == DateTime.now().month) {
      return AutoSizeText(
        date,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.green,
          fontWeight: FontWeight.w900,
        ),
        maxLines: 1,
      );
    } else if (day == "Sunday") {
      return AutoSizeText(
        date,
        style: TextStyle(fontSize: fontSize, color: Colors.red),
        maxLines: 1,
      );
    } else if (day == "Saturday") {
      return AutoSizeText(
        date,
        style: TextStyle(fontSize: fontSize, color: Colors.blue),
        maxLines: 1,
      );
    } else {
      return AutoSizeText(
        date,
        style: TextStyle(fontSize: fontSize),
        maxLines: 1,
      );
    }
  }

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

  Widget calenderRow(int date, {String tag = null}) {
    /*한 줄 단위로 표시 (주 X) 
    ex) 금 토
        일 월 화 수 목 금 토
        ...
        일 월 화
    */
    var children;
    int datesFirst = daysFirstWeek;
    int datesEnd = daysLastWeek;
    var totalDays = lastDayDateTime.day;
    int weekTotalDays = 7;

    if (date > totalDays) {
      children = Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [colorIndicator()],
      );
    } else if (date + 7 > totalDays) {
      children = returnWeek(date, tag: "end");
    } else {
      children = returnWeek(date, tag: tag);
    }

    return Expanded(flex: 2, child: children);
  }

  Widget returnWeek(int date, {String tag = null}) {
    var children = <Widget>[];

    // children.add(Spacer(
    //   flex: 1,
    // ));
    int datesFirst = daysFirstWeek;
    int datesEnd = daysLastWeek;
    var totalDays = lastDayDateTime.day; //해당 월의 최대 날짜(31일, 30일 등)
    int weekTotalDays = 7; //1주에 총 7일 존재

    var dt = date;
    if (tag == "first") {
      for (var i = 0; i < weekTotalDays; i++) {
        if (i >= weekTotalDays - datesFirst) {
          children.add(calenderBlock(dateText(dt.toString()), false, dt));
          dt += 1;
        } else {
          children.add(Spacer(
            flex: 3,
          ));
        }
      }
    } else if (tag == "end" && date > 29) {
      for (var i = 0; i < weekTotalDays; i++) {
        if (i < weekTotalDays - datesEnd) {
          children.add(calenderBlock(dateText(dt.toString()), false, dt));
          dt += 1;
        } else if (i == 6) {
          if (weekTotalDays - datesEnd == 1) {
            children.add(Expanded(
                flex: 18,
                child: Row(
                  children: [
                    Spacer(),
                    colorIndicator(),
                  ],
                )));
          } else {
            children.add(Expanded(
                flex: 15,
                child: Row(
                  children: [
                    Spacer(),
                    colorIndicator(),
                  ],
                )));
          }
        } else {
          // children.add(Spacer(
          //   flex: 3,
          // ));
        }
      }
    } else if (tag == "end") {
      for (var i = 0; i < weekTotalDays; i++) {
        if (i < weekTotalDays - datesEnd) {
          children.add(calenderBlock(dateText(dt.toString()), false, dt));
          dt += 1;
        } else {
          children.add(Spacer(
            flex: 3,
          ));
        }
      }
    } else {
      for (var i = 0; i < weekTotalDays; i++) {
        var dt = date + i;
        children.add(calenderBlock(dateText(dt.toString()), false, dt));
      }
    }

    // children.add(Spacer(
    //   flex: 1,
    // ));
    return new Row(
      children: children,
    );
  }

  Widget calenderBlock(AutoSizeText title, bool isitDay, int date) {
    bool dateSelected = false;
    num kcalArchieve = 0;
    num nutriArchieve = 0;
    for (var item in monthlyAchieveKcal) {
      if (date == item[0]) {
        kcalArchieve = item[1];
      }
    }
    for (var item in monthlyAchieveNutri) {
      if (date == item[0]) {
        nutriArchieve = item[1];
      }
    }
    return Expanded(
        flex: 3,
        child: GestureDetector(
          //다 적은날은 띄우기 완료
          child: Stack(
            children: [
              Container(
                alignment: isitDay ? null : Alignment(-1.0, -1.0),
                // margin: EdgeInsets.only(top: 5.0),
                child: isitDay
                    ? Center(child: title)
                    : Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                            title,
                            // Spacer(flex: 5),
                            Container(
                              alignment: Alignment.bottomCenter,
                              padding: const EdgeInsets.only(top: 4.0),
                              child: AutoSizeText(
                                kcalArchieve != 0
                                    ? '${kcalArchieve.toStringAsFixed(1)}%'
                                    : '', //칼로리 성취율
                                style: TextStyle(
                                  color: Colors.deepOrangeAccent[400],
                                  fontSize: 7,
                                ),
                                maxLines: 1,
                              ),
                            ), //성취도
                            Container(
                              alignment: Alignment.bottomCenter,
                              // padding: const EdgeInsets.only(right: 5),
                              child: AutoSizeText(
                                nutriArchieve != 0
                                    ? '${nutriArchieve.toStringAsFixed(1)}%'
                                    : '', //비율 성취율
                                style: TextStyle(
                                  color: Colors.deepOrangeAccent,
                                  fontSize: 7,
                                ),
                                maxLines: 1,
                              ),
                            ),
                            // Spacer(flex: 1),
                          ]),
              ),
              completedDates.contains(date)
                  ? Positioned(
                      top: 0,
                      right: 0,
                      child: DotsIndicator(
                        dotsCount: 1,
                        decorator: DotsDecorator(
                          size: Size.fromRadius(0),
                          // color: Colors.black87, // Inactive color
                          activeColor: Colors.green,
                        ),
                        // position: currentIndexPage
                      ))
                  : Container()
            ],
          ),
          onTap: () async {
            if (!isitDay) {
              todayDietList = List<Map>(4);
              initDateInfo();
              String dateTime;
              date = int.parse(title.data);
              calender_date = date;
              temp_year = calender_year;
              temp_month = calender_month;
              temp_date = calender_date;
              if (calender_month.toString().length == 1 &&
                  calender_date.toString().length == 1) {
                dateTime = "$calender_year-0$calender_month-0$date";
              } else if (calender_month.toString().length != 1 &&
                  calender_date.toString().length == 1) {
                dateTime = "$calender_year-$calender_month-0$date";
              } else if (calender_month.toString().length == 1 &&
                  calender_date.toString().length != 1) {
                dateTime = "$calender_year-0$calender_month-$date";
              } else {
                dateTime = "$calender_year-$calender_month-$date";
              }

              // print(dateTime);
              // await dbHelperDietHistory.getAllMyDietHistory().then((val) {
              //   for (var item in val) {
              //     print(item.date);
              //     print(item.breakFast);
              //     print(item.lunch);
              //     print(item.dinner);
              //   }
              // });

              await dbHelperDietHistory.getDietHistory(dateTime).then((value) {
                // print(value.breakFast);

                dietHistory = value;
                // print("%" * 100);
                // print(dietHistory.breakFast);
                // print("%" * 100);
              });

              changeIntToString();
              initDateInfo();
              checkConfirmDB();

              // print(dietHistory.breakFast);

              await getConfirmedIndex(dietHistory);

              // print(dietConfirmConfirm);
              // print("&" * 100);
              // print("&" * 100);
              // print(dietAdded);
              setState(() {
                dateSelected = !dateSelected;
              });
            }
            // setState(() {});
          },
        ));
  }

  void checkConfirmDB() {
    if (dietHistory != null) {
      for (var i = 0; i < 4; i++) {
        switch (i) {
          case 0:
            Map breakfast = jsonDecode(dietHistory.breakFast);
            if (breakfast != null) {
              if (breakfast['isItConfirm'] == "true") {
                dietConfirmConfirm[0] = true;
              }
            }
            // print(dietConfirmConfirm);

            break;
          case 1:
            Map lunch = jsonDecode(dietHistory.lunch);
            if (lunch != null) {
              if (lunch['isItConfirm'] == "true") {
                dietConfirmConfirm[1] = true;
              }
            }

            break;
          case 2:
            Map dinner = jsonDecode(dietHistory.dinner);
            if (dinner != null) {
              if (dinner['isItConfirm'] == "true") {
                dietConfirmConfirm[2] = true;
              }
            }

            break;
          case 3:
            Map snack = jsonDecode(dietHistory.snack);
            if (snack != null) {
              if (snack['isItConfirm'] == "true") {
                dietConfirmConfirm[3] = true;
              }
            }

            break;

          default:
        }
      }
    }
  }

  // Widget dietDate(String date) {
  //   return Container(
  //       height: 50,
  //       child: Center(
  //         child: AutoSizeText(
  //           "$date일",
  //           style: TextStyle(fontSize: 30),
  //           maxLines: 1,
  //         ),
  //       ));
  // }

  // void makeItemListPast(int index) async {
  //   //날짜 정보
  //   // await getConfirmedIndex();
  //   if (pastDietHistory != null) {
  //     itemListPast = [
  //       FractionallySizedBox(
  //           widthFactor: 1.0,
  //           heightFactor: 1.0,
  //           child: Container(
  //             // decoration: BoxDecoration(color: Colors.yellow),
  //             child: Center(
  //               child: Column(children: [
  //                 for (var item in todayDietList[index]['foodInfo']['foods'])
  //                   //item[0] : 코드
  //                   //item[1] : 음식 이름
  //                   //item[2] : 음식 무게
  //                   Text("${item[1]}  ${item[2]}g"),
  //                 Text(
  //                     "영양성분 비율 : ${todayDietList[index]['foodInfo']['nutri']}"),
  //                 Text("총 칼로리 : ${todayDietList[index]['foodInfo']['kcal']}"),
  //               ]),
  //             ),
  //           ))
  //     ];
  //   } else {}
  // }
}
