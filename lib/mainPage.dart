import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_application_1/dietModelSaver.dart';
import 'package:flutter_application_1/model.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'appBar.dart';
import 'db_helper.dart';
import 'mainStream.dart' as mainStream;
import 'lineChart.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

//그래프 표시 버튼 위치 달력 우측 하단
final dbHelperDietHistory = DBHelperDietHistory();
final dbHelperDiet = DBHelperDiet();
final dbHelperPerson = DBHelperPerson();
final int calenderWidthFlex = 22;

// final dbHelper
StreamController<bool> streamControllerMainPage =
    mainStream.streamControllerMainPage;

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
  DietHistory pastDietHistory;
  Person person;

  FocusScopeNode myFocusNode = FocusScopeNode();
  // ScrollController _controller = new ScrollController();
  List<bool> isSelected = [true, false];
  List<List<bool>> dietAdded = [
    [false, false, false, false],
    [false, false, false, false],
    [false, false, false, false],
    [false, false, false, false]
  ];
  List<bool> dietConfirm = [false, false, false, false];

  void initDateInfo() {
    dietAdded = [
      [false, false, false, false],
      [false, false, false, false],
      [false, false, false, false],
      [false, false, false, false]
    ];
    dietConfirm = [false, false, false, false];
  }

  // +버튼, adddiet로 가는지, savedDiet로 가는지
  List<Map> todayDietList = List<Map>(4);
  List<Widget> itemList = [];
  List<Widget> itemListPast = [];
  num totalCalorie = 0;

  void getConfirmedIndex(DietHistory myDietHistory) async {
    try {
      if (myDietHistory.breakFast != "null") {
        dietAdded[0] = [true, true, true, true];
        dietConfirm[0] = true;

        Map tempDiet = jsonDecode(myDietHistory.breakFast);
        Diet myDiet;
        await dbHelperDiet.getDiet(tempDiet['dietName']).then((val) {
          myDiet = val;
        });
        todayDietList[0] = {};
        todayDietList[0]['foodInfo'] = jsonDecode(myDiet.foodInfo);

        for (var i = 0; i < todayDietList[0]['foodInfo']['foods'].length; i++) {
          todayDietList[0]['foodInfo']['foods'][i] =
              todayDietList[0]['foodInfo']['foods'][i].values.toList();
        }
      }
      if (myDietHistory.lunch != "null") {
        dietAdded[1] = [true, true, true, true];
        dietConfirm[1] = true;

        Map tempDiet = jsonDecode(myDietHistory.lunch);
        Diet myDiet;
        await dbHelperDiet.getDiet(tempDiet['dietName']).then((val) {
          myDiet = val;
        });
        todayDietList[1] = {};
        todayDietList[1]["foodInfo"] = jsonDecode(myDiet.foodInfo);

        for (var i = 0; i < todayDietList[1]['foodInfo']['foods'].length; i++) {
          todayDietList[1]['foodInfo']['foods'][i] =
              todayDietList[1]['foodInfo']['foods'][i].values.toList();
        }
      }
      if (myDietHistory.dinner != "null") {
        dietAdded[2] = [true, true, true, true];
        dietConfirm[2] = true;

        todayDietList[2] = {};

        Map tempDiet = jsonDecode(myDietHistory.dinner);
        Diet myDiet;
        await dbHelperDiet.getDiet(tempDiet['dietName']).then((val) {
          myDiet = val;
        });

        todayDietList[2]['foodInfo'] = jsonDecode(myDiet.foodInfo);

        for (var i = 0; i < todayDietList[2]['foodInfo']['foods'].length; i++) {
          todayDietList[2]['foodInfo']['foods'][i] =
              todayDietList[2]['foodInfo']['foods'][i].values.toList();
        }
      }
      if (myDietHistory.snack != "null") {
        dietAdded[3] = [true, true, true, true];
        dietConfirm[3] = true;
        todayDietList[3] = {};

        Map tempDiet = jsonDecode(myDietHistory.snack);
        Diet myDiet;
        await dbHelperDiet.getDiet(tempDiet['dietName']).then((val) {
          myDiet = val;
        });

        todayDietList[3]['foodInfo'] = jsonDecode(myDiet.foodInfo);

        for (var i = 0; i < todayDietList[3]['foodInfo']['foods'].length; i++) {
          todayDietList[3]['foodInfo']['foods'][i] =
              todayDietList[3]['foodInfo']['foods'][i].values.toList();
        }
      }
    } catch (e) {
      print(e);
    }
    print("/");
    print(todayDietList);
    print("/");

    setState(() {});
  }

  void getInfo() async {
    // print("12312312");
    // String dateData = '${DateTime.now().toString().substring(0, 10)}';

    await dbHelperDietHistory.getDietHistory(dateData).then((val) {
      dietHistory = val;
    });

    await dbHelperPerson.getLastPerson().then((val) {
      person = val;
    });
    await getConfirmedIndex(dietHistory);
    setState(() {});
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

    getInfo();
    super.didChangeDependencies();
  }

  void makeItemList(int index) async {
    //날짜 정보
    // await getConfirmedIndex();

    if (dietConfirm[index]) {
      itemList = [
        FractionallySizedBox(
            widthFactor: 1.0,
            heightFactor: 1.0,
            child: Container(
              decoration: BoxDecoration(color: Colors.yellow),
              child: Center(
                child: Column(children: [
                  for (var item in todayDietList[index]['foodInfo']['foods'])
                    //item[0] : 코드
                    //item[1] : 음식 이름
                    //item[2] : 음식 무게
                    Text("${item[1]}  ${item[2]}g"),
                  Text(
                      "영양성분 비율 : ${todayDietList[index]['foodInfo']['nutri']}"),
                  Text("총 칼로리 : ${todayDietList[index]['foodInfo']['kcal']}"),
                ]),
              ),
            ))
      ];
    } else {
      itemList = [
        GestureDetector(
          child: Center(
              child: Icon(
            Icons.add_circle_outline,
            color: Colors.black,
            size: 40,
          )),
          onTap: () {
            setState(() {
              dietAdded[index][0] = !dietAdded[index][0];
            });
          },
        ),
        dietAdded[index][0]
            ? Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: GestureDetector(
                          child: FractionallySizedBox(
                            widthFactor: 1,
                            heightFactor: 1,
                            child: Container(
                                child: Center(child: Text("식단 추가하기")),
                                decoration: BoxDecoration(color: Colors.red)),
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, '/addDiet',
                                arguments: <String, Map>{
                                  "pre": {"pre": "mainPage", "index": index}
                                }).then((val) {
                              setState(() {
                                dietAdded[index][2] =
                                    val == null ? false : true;
                                todayDietList[index] = val;
                              });
                              todayDietList[index]['foodInfo'] =
                                  jsonDecode(todayDietList[index]['foodInfo']);

                              for (var i = 0;
                                  i <
                                      todayDietList[index]['foodInfo']['foods']
                                          .length;
                                  i++) {
                                todayDietList[index]['foodInfo']['foods'][i] =
                                    todayDietList[index]['foodInfo']['foods'][i]
                                        .values
                                        .toList();
                              }
                            });
                          })),
                  Expanded(
                      flex: 1,
                      child: GestureDetector(
                          child: FractionallySizedBox(
                            widthFactor: 1,
                            heightFactor: 1,
                            child: Container(
                                child: Center(child: Text("저장된 식단 불러오기")),
                                decoration: BoxDecoration(color: Colors.blue)),
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, '/searchDiet',
                                arguments: <String, String>{
                                  "pre": "mainPage"
                                }).then((val) {
                              setState(() {
                                dietAdded[index][2] =
                                    val == null ? false : true;
                                todayDietList[index] = val;
                              });
                              todayDietList[index]['foodInfo'] =
                                  jsonDecode(todayDietList[index]['foodInfo']);

                              for (var i = 0;
                                  i <
                                      todayDietList[index]['foodInfo']['foods']
                                          .length;
                                  i++) {
                                todayDietList[index]['foodInfo']['foods'][i] =
                                    todayDietList[index]['foodInfo']['foods'][i]
                                        .values
                                        .toList();
                              }
                            });
                          })),
                ],
              )
            : Container(),
        dietAdded[index][2] //
            ? GestureDetector(
                child: FractionallySizedBox(
                    widthFactor: 1.0,
                    heightFactor: 1.0,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.yellow),
                      child: Center(
                        child: Column(children: [
                          for (var item in todayDietList[index]['foodInfo']
                              ['foods'])
                            //item[0] : 코드
                            //item[1] : 음식 이름
                            //item[2] : 음식 무게
                            AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: dietConfirm[index]
                                      ? Colors.red
                                      : Colors.blueAccent,
                                  fontWeight: dietConfirm[index]
                                      ? FontWeight.w100
                                      : FontWeight.bold,
                                ),
                                child: Text("${item[1]}  ${item[2]}g")),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              fontSize: 20.0,
                              color: dietConfirm[index]
                                  ? Colors.red
                                  : Colors.blueAccent,
                              fontWeight: dietConfirm[index]
                                  ? FontWeight.w100
                                  : FontWeight.bold,
                            ),
                            child: Text(
                                "영양성분 비율 : ${todayDietList[index]['foodInfo']['nutri']}"),
                          ),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              fontSize: 20.0,
                              color: dietConfirm[index]
                                  ? Colors.red
                                  : Colors.blueAccent,
                              fontWeight: dietConfirm[index]
                                  ? FontWeight.w100
                                  : FontWeight.bold,
                            ),
                            child: Text(
                                "총 칼로리 : ${todayDietList[index]['foodInfo']['kcal']}"),
                          ),
                        ]),
                      ),
                    )),
                onTap: () {
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
                            onPressed: () {
                              print(todayDietList[index]);
                              formatDietHistory(
                                      dietName: todayDietList[index]
                                          ['dietName'],
                                      flag: index,
                                      kcal: todayDietList[index]['foodInfo']
                                              ['kcal']
                                          .toString(),
                                      nutri: todayDietList[index]['foodInfo']
                                          ['nutri'],
                                      dateTime: dateData)
                                  .then((_) {
                                setState(() {
                                  //확정
                                  dietConfirm[index] = true;
                                  dietAdded[index][3] = false;
                                });
                              });
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: RaisedButton(
                            child: Text("안먹었"),
                            onPressed: () {
                              setState(() {
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
                left: 0,
                child: GestureDetector(
                  child: Icon(
                    Icons.keyboard_backspace,
                    size: 20,
                  ),
                  onTap: () {
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
    changeIntToString();
    getInfo();

    super.initState();
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
    List<String> mealList = ["아침", "점심", "저녁", "간식"];

    return Scaffold(
        backgroundColor: Color(0xFFD7FFF1),
        appBar: basicAppBar('Main Page', context),
        drawer: NavDrawer(),
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              Spacer(flex: 1),
              Expanded(
                  flex: 20,
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: PageView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: 2,
                          onPageChanged: (page) {
                            if (page == 0) {
                              calender_year = DateTime.now().year;
                              calender_month = DateTime.now().month;
                              calender_date = DateTime.now().day;
                              changeIntToString();
                              getInfo();
                            }
                          },
                          itemBuilder: (BuildContext context, int index) {
                            return index == 0
                                ? Column(
                                    children: [
                                      //page 1
                                      Spacer(
                                        flex: 2,
                                      ),
                                      Expanded(
                                        flex: 10,
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
                                                        decoration:
                                                            BoxDecoration(
                                                                color: Colors
                                                                    .black),
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
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: Colors
                                                                      .white),
                                                        ))
                                                  ],
                                                ),
                                                decoration: BoxDecoration(
                                                    color: Colors.white),
                                              );
                                            },
                                            itemCount: 4,
                                            pagination: new SwiperPagination(),
                                          ),
                                        ),
                                      ),
                                      Spacer(
                                        flex: 2,
                                      ),
                                      Expanded(
                                        flex: 10,
                                        child: SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Swiper(
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return Container(
                                                child: Text("추천 식단이 들어갈 자리"),
                                                decoration: BoxDecoration(
                                                    color: Colors.white),
                                              );
                                            },
                                            itemCount: 10,
                                            pagination: new SwiperPagination(),
                                            // control: new SwiperControl(),
                                          ),
                                        ),
                                      ),
                                      Spacer(flex: 2),
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
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: person == null
                                                            ? [
                                                                Text("키"),
                                                                Text("몸무게"),
                                                                Text("체지방률"),
                                                                Text("골격근량"),
                                                              ]
                                                            : [
                                                                Text(
                                                                    "키    ${person.height}"),
                                                                Text(
                                                                    "몸무게    ${person.weight}"),
                                                                Text(
                                                                    "체지방률    ${person.bmi}"),
                                                                Text(
                                                                    "골격근량    ${person.muscleMass}"),
                                                              ],
                                                      ),
                                                      decoration: BoxDecoration(
                                                          color: Colors.red),
                                                    ),
                                                    widthFactor: 1,
                                                    heightFactor: 1,
                                                  )),
                                              Expanded(
                                                  flex: 1,
                                                  child: FractionallySizedBox(
                                                    child: Container(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: person == null
                                                            ? [
                                                                Text("목표 몸무게"),
                                                                Text("목표 체지방률"),
                                                                Text("목표 골격근량"),
                                                                Text("목표"),
                                                              ]
                                                            : [
                                                                Text(
                                                                    "목표 몸무게   ${person.weightTarget}"),
                                                                Text(
                                                                    "목표 체지방률    ${person.bmiTarget}"),
                                                                Text(
                                                                    "목표 골격근량   ${person.muscleTarget}"),
                                                                Text(
                                                                    "목표    ${person.purpose}"),
                                                              ],
                                                      ),
                                                      decoration: BoxDecoration(
                                                          color: Colors.blue),
                                                    ),
                                                    widthFactor: 1,
                                                    heightFactor: 1,
                                                  ))
                                            ],
                                          )),
                                      Spacer(
                                        flex: 2,
                                      )
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
                                      Spacer(
                                        flex: 2,
                                      ),
                                      //달력
                                      calenderMonthChange(),
                                      Expanded(
                                        flex: calenderWidthFlex,
                                        child: Container(
                                            decoration: BoxDecoration(
                                                color: Color(0x7077AAAD)),
                                            child: isSelected[0]
                                                ? returnCalender()
                                                : returnGraph()),
                                      ),
                                      Spacer(
                                        flex: 2,
                                      ),
                                      Expanded(
                                        flex: 10,
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
                                                        decoration:
                                                            BoxDecoration(
                                                                color: Colors
                                                                    .black),
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
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: Colors
                                                                      .white),
                                                        ))
                                                  ],
                                                ),
                                                decoration: BoxDecoration(
                                                    color: Colors.white),
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
              Spacer(
                flex: 1,
              )
            ],
          ),
        ));
  }

  Widget returnCalender() {
    return Column(
      children: [
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
          return Column(
            children: [
              Spacer(
                flex: 1,
              ),
              LineChartSample2(
                index: index,
              ),
              Spacer(
                flex: 2,
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
    return Expanded(flex: 2, child: calender());
  }

  Widget calender() {
    return isItCalender
        ? Row(
            children: [
              Spacer(
                flex: 1,
              ),
              Expanded(
                flex: calenderWidthFlex,
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: () {
                          if (calender_month == 1) {
                            setState(() {
                              calender_year -= 1;
                              calender_month = 12;
                            });
                          } else {
                            setState(() {
                              calender_month -= 1;
                            });
                          }
                        },
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                        onPressed: () {
                          if (calender_month == 12) {
                            setState(() {
                              calender_year += 1;
                              calender_month = 1;
                            });
                          } else {
                            setState(() {
                              calender_month += 1;
                            });
                          }
                        },
                      ),
                    ),
                    Spacer(
                      flex: 1,
                    ),
                    Expanded(
                      flex: 6,
                      child: Text(
                        "$calender_year년 $calender_month월",
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                    Spacer(
                      flex: 4,
                    ),
                    calenderSwitch(),
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
                    Spacer(
                      flex: 13,
                    ),
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
        streamControllerMainPage.add(isItCalender);
      });
    } else {
      setState(() {
        switchControl = false;
        isItCalender = true;
        streamControllerMainPage.add(isItCalender);
      });
    }
  }

  Widget calenderSwitch() {
    return Expanded(
      flex: 5,
      child: ToggleButtons(
        children: <Widget>[
          Icon(Icons.ac_unit),
          Icon(Icons.call),
        ],
        onPressed: (int index) {
          setState(() {
            for (int buttonIndex = 0;
                buttonIndex < isSelected.length;
                buttonIndex++) {
              if (buttonIndex == index) {
                isSelected[buttonIndex] = true;
              } else {
                isSelected[buttonIndex] = false;
              }
            }
          });
        },
        isSelected: isSelected,
      ),
    );
  }

  Widget calenderDayRow() {
    //일월화수목금토
    return Expanded(
        flex: 2,
        child: Row(
          children: [
            // Spacer(
            //   flex: 1,
            // ),
            calenderBlock(
                dayText('일'), true), //true면 border 없이, flase면 border 있이
            calenderBlock(dayText('월'), true),
            calenderBlock(dayText('화'), true),
            calenderBlock(dayText('수'), true),
            calenderBlock(dayText('목'), true),
            calenderBlock(dayText('금'), true),
            calenderBlock(dayText('토'), true),
            // Spacer(
            //   flex: 1,
            // ),
          ],
        ));
  }

  Widget dayText(String day) {
    return Text(
      day,
      style: TextStyle(fontSize: 15),
    );
  }

  Widget dateText(String date) {
    var targetDay =
        new DateTime(calender_year, calender_month, int.parse(date));
    var day = DateFormat('EEEE').format(targetDay).toString();

    if (date == DateTime.now().day.toString() &&
        calender_month == DateTime.now().month) {
      return Text(
        date,
        style: TextStyle(
          fontSize: 15,
          color: Colors.green,
          fontWeight: FontWeight.w900,
        ),
        maxLines: 1,
      );
    } else if (day == "Sunday") {
      return Text(
        date,
        style: TextStyle(fontSize: 15, color: Colors.red),
        maxLines: 1,
      );
    } else if (day == "Saturday") {
      return Text(
        date,
        style: TextStyle(fontSize: 15, color: Colors.blue),
        maxLines: 1,
      );
    } else {
      return Text(
        date,
        style: TextStyle(fontSize: 15),
        maxLines: 1,
      );
    }
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
      return Spacer(
        flex: 2,
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
          children.add(calenderBlock(dateText(dt.toString()), false));
          dt += 1;
        } else {
          children.add(Spacer(
            flex: 3,
          ));
        }
      }
    } else if (tag == "end") {
      for (var i = 0; i < weekTotalDays; i++) {
        if (i < weekTotalDays - datesEnd) {
          children.add(calenderBlock(dateText(dt.toString()), false));
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
        children.add(calenderBlock(dateText(dt.toString()), false));
      }
    }

    // children.add(Spacer(
    //   flex: 1,
    // ));
    return new Row(
      children: children,
    );
  }

  Widget calenderBlock(Text title, bool isitDay) {
    bool dateSelected = false;
    return Expanded(
        flex: 3,
        child: FlatButton(
          shape: isitDay
              ? null
              : Border(top: BorderSide(color: Colors.blueAccent, width: 1)),
          child: Container(
            alignment: isitDay ? null : Alignment(-1.0, -1.0),
            margin: EdgeInsets.only(top: 5.0),
            decoration: BoxDecoration(),
            child: isitDay
                ? title
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                        title,
                        Spacer(flex: 2),
                        Text(
                          '100%',
                          style: TextStyle(
                            fontSize: 7,
                          ),
                          maxLines: 1,
                        ), //성취도
                        Spacer(flex: 1),
                      ]),
          ),
          onPressed: () async {
            if (!isitDay) {
              todayDietList = List<Map>(4);
              initDateInfo();
              String dateTime;
              date = int.parse(title.data);
              calender_date = date;
              if (calender_month.toString().length == 1) {
                dateTime = "$calender_year-0$calender_month-$date";
              } else {
                dateTime = "$calender_year-$calender_month-$date";
              }
              await dbHelperDietHistory.getDietHistory(dateTime).then((value) {
                pastDietHistory = value;
                print(value);
              });

              changeIntToString();

              initDateInfo();
              getConfirmedIndex(pastDietHistory);

              setState(() {
                dateSelected = !dateSelected;
              });
            }
          },
        ));
  }

  Widget dietDate(String date) {
    return Container(
        height: 50,
        child: Center(
          child: Text(
            "$date일",
            style: TextStyle(fontSize: 30),
          ),
        ));
  }

  void makeItemListPast(int index) async {
    //날짜 정보
    // await getConfirmedIndex();
    if (pastDietHistory != null) {
      itemListPast = [
        FractionallySizedBox(
            widthFactor: 1.0,
            heightFactor: 1.0,
            child: Container(
              decoration: BoxDecoration(color: Colors.yellow),
              child: Center(
                child: Column(children: [
                  for (var item in todayDietList[index]['foodInfo']['foods'])
                    //item[0] : 코드
                    //item[1] : 음식 이름
                    //item[2] : 음식 무게
                    Text("${item[1]}  ${item[2]}g"),
                  Text(
                      "영양성분 비율 : ${todayDietList[index]['foodInfo']['nutri']}"),
                  Text("총 칼로리 : ${todayDietList[index]['foodInfo']['kcal']}"),
                ]),
              ),
            ))
      ];
    } else {}
  }
}
