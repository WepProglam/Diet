import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'appBar.dart';

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
  var mealTime = "아침";
  var calender_year = DateTime.now().year;
  var calender_month = DateTime.now().month;
  var daysFirstWeek;
  var daysLastWeek;
  var lastDayDateTime;
  @override
  Widget build(BuildContext context) {
    var dateTime = DateTime(calender_year, calender_month, 1);
    var dayFirst =
        DateFormat('EEEE').format(DateTime(calender_year, calender_month, 1));
    lastDayDateTime = (dateTime.month < 12)
        ? new DateTime(dateTime.year, dateTime.month + 1, 0)
        : new DateTime(dateTime.year + 1, 1, 0);

    var dayLast = DateFormat('EEEE').format(lastDayDateTime);

    daysLastWeek = 7 - dayToDate(dayLast);
    print(dayLast);
    print(dayToDate(dayLast));
    daysFirstWeek = 7 - dayToDate(dayFirst) + 1;
    print("datsFirstWEEK $daysFirstWeek");

    // var daysFirstWeek = 7 - dayToDate[dayFirst] + 1; //첫 주 요일 개수
    print(daysFirstWeek);
    return Scaffold(
        appBar: basicAppBar('Main Page', context),
        drawer: NavDrawer(),
        body: Column(
          children: [
            Spacer(
              flex: 1,
            ),
            calenderMonthChange(),
            calenderDayRow(), //요일
            calenderRow(1, tag: "first"), //날짜 => 추후 정확한 정보 기입
            calenderRow(1 + daysFirstWeek),
            calenderRow(8 + daysFirstWeek),
            calenderRow(15 + daysFirstWeek),
            calenderRow(22 + daysFirstWeek),
            calenderRow(29 + daysFirstWeek, tag: "end"),
            // calenderRow(36), //익월 날짜 포함 가능위해 임시적으로 만든 자리(1월 달력에서 2월 날짜 보이는거)
            dietDate(date.toString()),
            diet(date.toString()),
            dietBox(mealTime, date),
            Spacer(
              flex: 2,
            ),
          ],
        ));
  }

  int dayToDate(String day) {
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
    return Expanded(
      flex: 1,
      child: Row(
        children: [
          Spacer(
            flex: 1,
          ),
          // Expanded(flex: 5, child: Text("2021년 1월")),
          Expanded(
              flex: 20,
              child: Row(
                children: [
                  FlatButton(
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
                    child: Icon(Icons.arrow_back_ios),
                  ),
                  Text(
                    "$calender_year년 $calender_month월",
                    style: TextStyle(fontSize: 20),
                  ),
                  FlatButton(
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
                    child: Icon(Icons.arrow_forward_ios),
                  ),
                ],
              )),
          Spacer(
            flex: 1,
          )
        ],
      ),
    );
  }

  Widget calenderDayRow() {
    return Expanded(
        flex: 2,
        child: Row(
          children: [
            Spacer(
              flex: 1,
            ),
            calenderBlock(
                dateText('일'), true), //true면 border 없이, flase면 border 있이
            calenderBlock(dateText('월'), true),
            calenderBlock(dateText('화'), true),
            calenderBlock(dateText('수'), true),
            calenderBlock(dateText('목'), true),
            calenderBlock(dateText('금'), true),
            calenderBlock(dateText('토'), true),
            Spacer(
              flex: 1,
            ),
          ],
        ));
  }

  Widget dateText(String date) {
    return Text(
      date,
      style: TextStyle(fontSize: 15),
    );
  }

  Widget calenderRow(int date, {String tag = null}) {
    //추후 year,month 받고 달력 달라지는 기능 추가

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

    children.add(Spacer(
      flex: 1,
    ));
    int datesFirst = daysFirstWeek;
    int datesEnd = daysLastWeek;
    var totalDays = lastDayDateTime.day;
    print("daysLastweek $daysLastWeek");

    int weekTotalDays = 7;

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

    children.add(Spacer(
      flex: 1,
    ));

    // print(children);

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
            decoration: BoxDecoration(
                // color: Colors.white,
                // border: isitDay
                //     ? null
                //     : Border(
                //         top: BorderSide(color: Colors.blue),
                //       )
                ),
            child: isitDay
                ? title
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                        title,
                        Text('\n100%', style: TextStyle(fontSize: 10)) //성취도
                      ]),
          ),
          onPressed: () {
            if (!isitDay) {
              setState(() {
                date = int.parse(title.data);
              });
            }
          },
        ));
  }

  Widget dietDate(String date) {
    return Expanded(
        flex: 1,
        child: Center(
          child: Text("$date일"),
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
                color: Colors.red,
                child: Container(
                  // decoration: BoxDecoration(color: Colors.white10),
                  // border: Border(bottom: BorderSide(color: Colors.blue))),
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
                  setState(() {
                    mealTime = "아침";
                  });
                },
              )),
          Expanded(
              flex: 1,
              child: FlatButton(
                color: Colors.green,
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
                  setState(() {
                    mealTime = '점심';
                  });
                },
              )),
          Expanded(
              flex: 1,
              child: FlatButton(
                color: Colors.blue,
                child: Container(
                  // decoration: BoxDecoration(color: Colors.white10),
                  // border: Border(bottom: BorderSide(color: Colors.blue))),
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
                  setState(() {
                    mealTime = "저녁";
                  });
                },
              ))
        ],
      ),
    );
  }

  Widget dietBox(String day, int date) {
    //추후 아침 점심 저녁에 따라 표시 정보 달라질 예정 / 임시로 색깔만 바꿈
    return Expanded(
        flex: 7,
        child: Container(
          decoration: BoxDecoration(
              color: day == "아침"
                  ? Colors.red
                  : day == "점심"
                      ? Colors.green
                      : Colors.blue),
        ));
  }
}
// 받아온 달력 주석 처리함
// class _MyHomePageState extends State<MyHomePage> {
//   DateTime _currentDate = DateTime(2021, 1, 8);
//   DateTime _currentDate2 = DateTime(2021, 1, 8);
//   String _currentMonth = DateFormat.yMMM().format(DateTime(2019, 2, 3));
//   DateTime _targetDateTime = DateTime(2021, 1, 8);
// //  List<DateTime> _markedDate = [DateTime(2018, 9, 20), DateTime(2018, 10, 11)];
//   static Widget _eventIcon = new Container(
//     decoration: new BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.all(Radius.circular(1000)),
//         border: Border.all(color: Colors.blue, width: 2.0)),
//     child: new Icon(
//       Icons.person,
//       color: Colors.amber,
//     ),
//   );

//   EventList<Event> _markedDateMap = new EventList<Event>(
//     events: {
//       new DateTime(2019, 2, 10): [
//         new Event(
//           date: new DateTime(2019, 2, 10),
//           title: 'Event 1',
//           icon: _eventIcon,
//           dot: Container(
//             margin: EdgeInsets.symmetric(horizontal: 1.0),
//             color: Colors.red,
//             height: 5.0,
//             width: 5.0,
//           ),
//         ),
//         new Event(
//           date: new DateTime(2019, 2, 10),
//           title: 'Event 2',
//           icon: _eventIcon,
//         ),
//         new Event(
//           date: new DateTime(2019, 2, 10),
//           title: 'Event 3',
//           icon: _eventIcon,
//         ),
//       ],
//     },
//   );

//   CalendarCarousel _calendarCarousel, _calendarCarouselNoHeader;

//   @override
//   void initState() {
//     /// Add more events to _markedDateMap EventList
//     _markedDateMap.add(
//         new DateTime(2019, 2, 25),
//         new Event(
//           date: new DateTime(2019, 2, 25),
//           title: 'Event 5',
//           icon: _eventIcon,
//         ));

//     _markedDateMap.add(
//         new DateTime(2019, 2, 10),
//         new Event(
//           date: new DateTime(2019, 2, 10),
//           title: 'Event 4',
//           icon: _eventIcon,
//         ));

//     _markedDateMap.addAll(new DateTime(2019, 2, 11), [
//       new Event(
//         date: new DateTime(2019, 2, 11),
//         title: 'Event 1',
//         icon: _eventIcon,
//       ),
//       new Event(
//         date: new DateTime(2019, 2, 11),
//         title: 'Event 2',
//         icon: _eventIcon,
//       ),
//       new Event(
//         date: new DateTime(2019, 2, 11),
//         title: 'Event 3',
//         icon: _eventIcon,
//       ),
//     ]);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     /// Example with custom icon
//     _calendarCarousel = CalendarCarousel<Event>(
//       onDayPressed: (DateTime date, List<Event> events) {
//         this.setState(() => _currentDate = date);
//         events.forEach((event) => print(event.title));
//       },
//       weekendTextStyle: TextStyle(
//         color: Colors.red,
//       ),
//       thisMonthDayBorderColor: Colors.grey,
// //          weekDays: null, /// for pass null when you do not want to render weekDays
//       headerText: 'Custom Header',
//       weekFormat: true,
//       markedDatesMap: _markedDateMap,
//       height: 200.0,
//       selectedDateTime: _currentDate2,
//       showIconBehindDayText: true,
// //          daysHaveCircularBorder: false, /// null for not rendering any border, true for circular border, false for rectangular border
//       customGridViewPhysics: NeverScrollableScrollPhysics(),
//       markedDateShowIcon: true,
//       markedDateIconMaxShown: 2,
//       selectedDayTextStyle: TextStyle(
//         color: Colors.yellow,
//       ),
//       todayTextStyle: TextStyle(
//         color: Colors.blue,
//       ),
//       markedDateIconBuilder: (event) {
//         return event.icon;
//       },
//       minSelectedDate: _currentDate.subtract(Duration(days: 360)),
//       maxSelectedDate: _currentDate.add(Duration(days: 360)),
//       todayButtonColor: Colors.transparent,
//       todayBorderColor: Colors.green,
//       markedDateMoreShowTotal:
//           true, // null for not showing hidden events indicator
// //          markedDateIconMargin: 9,
// //          markedDateIconOffset: 3,
//     );

//     /// Example Calendar Carousel without header and custom prev & next button
//     _calendarCarouselNoHeader = CalendarCarousel<Event>(
//       todayBorderColor: Colors.green,
//       onDayPressed: (DateTime date, List<Event> events) {
//         this.setState(() => _currentDate2 = date);
//         events.forEach((event) => print(event.title));
//       },
//       daysHaveCircularBorder: true,
//       showOnlyCurrentMonthDate: false,
//       weekendTextStyle: TextStyle(
//         color: Colors.red,
//       ),
//       thisMonthDayBorderColor: Colors.grey,
//       weekFormat: false,
// //      firstDayOfWeek: 4,
//       markedDatesMap: _markedDateMap,
//       height: 420.0,
//       selectedDateTime: _currentDate2,
//       targetDateTime: _targetDateTime,
//       customGridViewPhysics: NeverScrollableScrollPhysics(),
//       markedDateCustomShapeBorder:
//           CircleBorder(side: BorderSide(color: Colors.yellow)),
//       markedDateCustomTextStyle: TextStyle(
//         fontSize: 18,
//         color: Colors.blue,
//       ),
//       showHeader: false,
//       todayTextStyle: TextStyle(
//         color: Colors.blue,
//       ),
//       // markedDateShowIcon: true,
//       // markedDateIconMaxShown: 2,
//       // markedDateIconBuilder: (event) {
//       //   return event.icon;
//       // },
//       // markedDateMoreShowTotal:
//       //     true,
//       todayButtonColor: Colors.yellow,
//       selectedDayTextStyle: TextStyle(
//         color: Colors.yellow,
//       ),
//       minSelectedDate: _currentDate.subtract(Duration(days: 360)),
//       maxSelectedDate: _currentDate.add(Duration(days: 360)),
//       prevDaysTextStyle: TextStyle(
//         fontSize: 16,
//         color: Colors.pinkAccent,
//       ),
//       inactiveDaysTextStyle: TextStyle(
//         color: Colors.tealAccent,
//         fontSize: 16,
//       ),
//       onCalendarChanged: (DateTime date) {
//         this.setState(() {
//           _targetDateTime = date;
//           _currentMonth = DateFormat.yMMM().format(_targetDateTime);
//         });
//       },
//       onDayLongPressed: (DateTime date) {
//         print('long pressed date $date');
//       },
//     );

//     return GestureDetector(
//         onTap: () {
//           // Navigator.pushNamed(context, '/personalForm');
//         },
//         child: Scaffold(
//             appBar: basicAppBar(widget.title, context),
//             drawer: NavDrawer(),
//             body: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: <Widget>[
//                   //custom icon
//                   Container(
//                     margin: EdgeInsets.symmetric(horizontal: 16.0),
//                     child: _calendarCarousel,
//                   ), // This trailing comma makes auto-formatting nicer for build methods.
//                   //custom icon without header
//                   Container(
//                     margin: EdgeInsets.only(
//                       top: 30.0,
//                       bottom: 16.0,
//                       left: 16.0,
//                       right: 16.0,
//                     ),
//                     child: new Row(
//                       children: <Widget>[
//                         Expanded(
//                             child: Text(
//                           _currentMonth,
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 24.0,
//                           ),
//                         )),
//                         FlatButton(
//                           child: Text('PREV'),
//                           onPressed: () {
//                             setState(() {
//                               _targetDateTime = DateTime(_targetDateTime.year,
//                                   _targetDateTime.month - 1);
//                               _currentMonth =
//                                   DateFormat.yMMM().format(_targetDateTime);
//                             });
//                           },
//                         ),
//                         FlatButton(
//                           child: Text('NEXT'),
//                           onPressed: () {
//                             setState(() {
//                               _targetDateTime = DateTime(_targetDateTime.year,
//                                   _targetDateTime.month + 1);
//                               _currentMonth =
//                                   DateFormat.yMMM().format(_targetDateTime);
//                             });
//                           },
//                         )
//                       ],
//                     ),
//                   ),
//                   Container(
//                     margin: EdgeInsets.symmetric(horizontal: 16.0),
//                     child: _calendarCarouselNoHeader,
//                   ), //
//                 ],
//               ),
//             )));
//   }
// }
