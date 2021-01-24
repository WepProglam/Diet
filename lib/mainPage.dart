import 'dart:async';

import 'package:draw_graph/models/feature.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'package:intl/intl.dart' show DateFormat;
import 'appBar.dart';
import 'package:draw_graph/draw_graph.dart';
import 'db_helper.dart';
import 'model.dart';
import 'mainStream.dart' as mainStream;
import 'lineChart.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

//그래프 표시 버튼 위치 달력 우측 하단

final dbHelperPerson = DBHelperPerson();
final int calenderWidthFlex = 20;

StreamController<bool> streamControllerMainPage =
    mainStream.streamControllerMainPage;

// class MyScreen extends StatefulWidget {
//   final Stream<bool> stream = streamControllerMainPage.stream;
//   @override
//   _MyScreenState createState() => _MyScreenState();
// }

// class _MyScreenState extends State<MyScreen> {
//   Map listHistory = {"체중": <double>[], "체지방량": <double>[], "근육량": <double>[]};
//   List<String> labelX = [];
//   List<String> labelY = [];
//   List<Feature> features = [];

//   @override
//   void didChangeDependencies() {
//     getInfo();
//     super.didChangeDependencies();
//   }

//   @override
//   void initState() {
//     super.initState();
//     // widget.stream.listen((isItCalender) {
//     //   if (!isItCalender) {
//     //       getInfo();
//     //   }
//     // });
//   }

//   void getInfo() async {
//     listHistory["체중"] = <double>[];
//     listHistory["체지방량"] = <double>[];
//     listHistory["근육량"] = <double>[];
//     await dbHelperPerson.getAllPerson().then((value) {
//       print(value);
//       for (var item in value) {
//         listHistory["체중"].add(item.weight / 5);
//         listHistory["체지방량"].add(item.bmi / 5);
//         listHistory["근육량"].add(item.muscleMass / 5);
//         String time = item.time.split("-")[1] + "/" + item.time.split("-")[2];
//         labelX.add(time);
//         labelY.add("");
//       }
//       print(listHistory);
//       features = [
//         Feature(
//           title: "체중",
//           color: Colors.blue,
//           data: listHistory["체중"],
//         ),
//         Feature(
//           title: "체지방량",
//           color: Colors.pink,
//           data: listHistory["체지방량"],
//         ),
//         Feature(
//           title: "근육량",
//           color: Colors.cyan,
//           data: listHistory["근육량"],
//         ),
//       ];
//     });
//     if (this.mounted) {
//       setState(() {});
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Expanded(
//         flex: 1,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: <Widget>[
//             Container(),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 64.0),
//               child: Text(
//                 "신체 기록",
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 2,
//                 ),
//               ),
//             ),
//             LineGraph(
//               features: features,
//               size: Size(size.width, size.height / 3.5),
//               labelX: labelX,
//               labelY: labelY,
//               showDescription: true,
//               graphColor: Colors.black,
//             ),
//             SizedBox(
//               height: 50,
//             )
//           ],
//         ));
//   }
// }

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
  var daysFirstWeek;
  var daysLastWeek;
  var lastDayDateTime;
  bool isItCalender = true;
  bool switchControl = false;
  FocusScopeNode myFocusNode = FocusScopeNode();
  ScrollController _controller = new ScrollController();

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var dateTime = DateTime(calender_year, calender_month, 1);
    var dayFirst =
        DateFormat('EEEE').format(DateTime(calender_year, calender_month, 1));
    lastDayDateTime = (dateTime.month < 12)
        ? new DateTime(dateTime.year, dateTime.month + 1, 0)
        : new DateTime(dateTime.year + 1, 1, 0);

    var dayLast = DateFormat('EEEE').format(lastDayDateTime);

    daysLastWeek = 7 - dayToDate(dayLast); //마지막 주에 몇일 있는지
    daysFirstWeek = 7 - dayToDate(dayFirst) + 1; //첫 주에 몇일 있는지

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
                  child: SingleChildScrollView(
                      controller: _controller,
                      child: SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            children: [
                              Spacer(
                                flex: 1,
                              ),
                              calenderMonthChange(),
                              Expanded(
                                flex: calenderWidthFlex,
                                child: Container(
                                    decoration:
                                        BoxDecoration(color: Color(0x7077AAAD)),
                                    child: isItCalender
                                        ? returnCalender()
                                        : returnGraph()),
                              ),
                              Spacer(
                                flex: 1,
                              ),
                              Expanded(
                                flex: 5,
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: Swiper(
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Container(
                                        child: Text("추천 식단이 들어갈 자리"),
                                        decoration:
                                            BoxDecoration(color: Colors.white),
                                      );
                                    },
                                    itemCount: 3,
                                    pagination: new SwiperPagination(),
                                    control: new SwiperControl(),
                                  ),
                                ),
                              ),
                              Spacer(flex: 1),
                              diet(date.toString()),
                              dietBox(mealTime, date),
                            ],
                          )))),
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
    return Column(
      children: [
        Spacer(
          flex: 1,
        ),
        LineChartSample1(),
        Spacer(
          flex: 2,
        ),
      ],
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
        flex: 2,
        child: Transform.scale(
            scale: 1.5,
            child: Switch(
              onChanged: toggleSwitch,
              value: switchControl,
              activeColor: Colors.red,
              activeTrackColor: Colors.blue,
              inactiveThumbColor: Colors.red,
              inactiveTrackColor: Colors.grey,
            )));
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
                          style: TextStyle(fontSize: 7),
                          maxLines: 1,
                        ), //성취도
                        Spacer(flex: 1),
                      ]),
          ),
          onPressed: () {
            if (!isitDay) {
              setState(() {
                date = int.parse(title.data);
                calender_date = date;
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

  Widget diet(String data) {
    //아침 점심 저녁 표시
    return Expanded(
      flex: 1,
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: FlatButton(
                color: Color(0xff58C9B9),
                child: Container(
                  child: Center(
                      child: Text(
                    '아침',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18),
                  )),
                ),
                onPressed: () {
                  int index = mealTime == "아침" ? 0 : 4;
                  _goToElement(index);
                  setState(() {
                    mealTime = mealTime == "아침" ? "false" : "아침";
                  });
                },
              )),
          Expanded(
              flex: 1,
              child: FlatButton(
                color: Color(0xff58C9B9),
                child: Container(
                  // decoration: BoxDecoration(color: Colors.white10),
                  // border: Border(bottom: BorderSide(color: Colors.blue))),
                  child: Center(
                      child: Text(
                    '점심',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18),
                  )),
                ),
                onPressed: () {
                  int index = mealTime == "점심" ? 0 : 4;
                  _goToElement(index);
                  setState(() {
                    mealTime = mealTime == "점심" ? "false" : "점심";
                  });
                },
              )),
          Expanded(
              flex: 1,
              child: FlatButton(
                color: Color(0xff58C9B9),
                child: Container(
                  child: Center(
                      child: Text(
                    '저녁',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18),
                  )),
                ),
                onPressed: () {
                  int index = mealTime == "저녁" ? 0 : 4;
                  _goToElement(index);
                  setState(() {
                    mealTime = mealTime == "저녁" ? "false" : "저녁";
                  });
                },
              ))
        ],
      ),
    );
  }

  Widget dietBox(String day, int date) {
    //추후 아침 점심 저녁에 따라 표시 정보 달라질 예정 / 임시로 색깔만 바꿈

    return mealTime != "false"
        ? Expanded(
            flex: 7,
            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Container(
                  decoration: BoxDecoration(
                      color: day == "아침"
                          ? Color(0xff58C9B9) //Colors.red
                          : day == "점심"
                              ? Color(0xff58C9B9)
                              : Color(0xff58C9B9)),
                )),
          )
        : Spacer(
            flex: 7,
          );
  }

  void _goToElement(int index) {
    _controller.animateTo(
        (30.0 *
            index), // 100 is the height of container and index of 6th element is 5
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut);
  }
}
