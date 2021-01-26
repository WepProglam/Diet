import 'dart:convert';

import 'package:flutter/material.dart';
import 'appBar.dart';
import 'db_helper.dart';

final dbHelperDiet = DBHelperDiet();

class CalcDiet extends StatefulWidget {
  @override
  _CalcDietState createState() => _CalcDietState();
}

class _CalcDietState extends State<CalcDiet> {
  Map visibleMeal = {
    "아침": {"visiblity": true, "added": false, "diet": [], "dietName": ""},
    "점심": {"visiblity": true, "added": false, "diet": [], "dietName": ""},
    "저녁": {"visiblity": true, "added": false, "diet": [], "dietName": ""},
    "간식": {"visiblity": true, "added": false, "diet": [], "dietName": ""}
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: basicAppBar('calcDiet', context),
        drawer: NavDrawer(),
        body: Container(
          child: Column(
            children: [
              Spacer(
                flex: 1,
              ),
              addDiet("아침", "점심"),
              addDiet("저녁", "간식"),
              Spacer(
                flex: 1,
              ),
            ],
          ),
        ));
  }

  Widget diet(String key) {
    return Expanded(
        flex: 1,
        child: FlatButton(
            onPressed: () {
              setState(() {
                visibleMeal[key]["visiblity"] = !visibleMeal[key]["visiblity"];
              });
            },
            child: Container(
              decoration: BoxDecoration(
                  // border: Border.all(color: Colors.black),
                  ),
              child: Text(
                key,
                style: TextStyle(fontSize: 30),
              ),
            )));
  }

  Widget addDiet(String key1, String key2) {
    return Expanded(
        flex: 4,
        child: Row(children: [
          Spacer(
            flex: 2,
          ),
          Expanded(
              flex: 12,
              child: Container(
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(color: Color(0xff9DC8C8)
                      // border: Border.all(color: Colors.blueAccent)
                      ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(8, 10, 0, 0),
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              key1,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            ),
                            decoration: BoxDecoration(color: Color(0xFF69C2B0)),
                          ),
                        ],
                      ),
                      Divider(
                        color: Color(0xffD7FFF1),
                      ),
                      Container(
                        child: addOrFix(key1),
                      )
                    ],
                  ))),
          Spacer(
            flex: 1,
          ),
          Expanded(
              flex: 12,
              child: Container(
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(color: Color(0xff9DC8C8)
                      // border: Border.all(color: Colors.blueAccent)
                      ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(8, 10, 0, 0),
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              key2,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            ),
                            decoration: BoxDecoration(color: Color(0xFF69C2B0)),
                          ),
                        ],
                      ),
                      Divider(
                        color: Color(0xffD7FFF1),
                      ),
                      Container(
                        child: addOrFix(key2),
                      )
                    ],
                  ))),
          Spacer(
            flex: 2,
          )
        ]));
  }

  Widget addOrFix(String key) {
    if (visibleMeal[key]['added']) {
      return FlatButton(
          child: Container(
            height: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i in visibleMeal[key]['diet'])
                  Container(
                    child: Center(
                        child: Text(
                      " " + i + "  249 Kcal\n",
                      style: TextStyle(
                          color: Color(0xff285943),
                          fontWeight: FontWeight.w600),
                    )),
                    //   decoration: BoxDecoration(
                    //       border: Border.all(color: Colors.black)),
                  )
              ],
            ),
          ),
          onPressed: () {
            setState(() {
              fetchDiet(key);
            });
          });
    } else {
      return FlatButton(
          child: Container(
              height: 300,
              child: Center(
                  child: Container(
                child: Icon(
                  Icons.add_circle_outline,
                  size: 25,
                ),
                decoration: BoxDecoration(color: Color(0xff9DC8C8)),
              ))),
          onPressed: () {
            fetchDiet(key);
          });
    }
  }

  void fetchDiet(String key) {
    visibleMeal[key]["added"] = true;
    Navigator.pushNamed(context, '/searchDiet',
        arguments: <String, String>{"pre": "/searchDiet"}).then((value) {
      var val = value as Map;
      String dietName = val['myDiet']['dietName'];

      Map foodInfo = jsonDecode(val['myDiet']['foodInfo']);
      foodInfo = foodInfo[dietName];
      var foodNames = [];
      setState(() {
        foodInfo.forEach((key, value) {
          //value안에 foodName, foodMass 존재 key안에는 코드 존재
          foodNames.add(value['foodName']);
        });

        visibleMeal[key]['diet'] = foodNames;
        visibleMeal[key]['dietName'] = dietName;
      });
    });
  }
}
