import 'package:flutter/material.dart';
import 'appBar.dart';

class CalcDiet extends StatefulWidget {
  @override
  _CalcDietState createState() => _CalcDietState();
}

class _CalcDietState extends State<CalcDiet> {
  Map visibleMeal = {
    "아침": {"visiblity": true, "added": false},
    "점심": {"visiblity": true, "added": false},
    "저녁": {"visiblity": true, "added": false},
    "간식": {"visiblity": true, "added": false}
  };

  List<String> foods = ["현미밥", "닭가슴살", "감자"];
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
              addDiet("아침"),
              addDiet("점심"),
              addDiet("저녁"),
              addDiet("간식"),
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

  Widget addDiet(String key) {
    return Expanded(
        flex: 3,
        child: Row(children: [
          Spacer(
            flex: 1,
          ),
          Expanded(
              flex: 8,
              child: Container(
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      FlatButton(
                        child: ListTile(
                            leading: Text(key),
                            trailing: Text(
                              visibleMeal[key]["added"] ? "수정하기" : "추가하기",
                            )),
                        onPressed: () {
                          setState(() {
                            visibleMeal[key]["added"] = true;
                          });

                          Navigator.pushNamed(context, '/savedDiet');
                        },
                      ),
                      for (var i in foods)
                        Container(
                          child: Center(child: Text(" " + i + "  249 Kcal\n")),
                          //   decoration: BoxDecoration(
                          //       border: Border.all(color: Colors.black)),
                          // ),
                        )
                    ],
                  ))),
          Spacer(
            flex: 1,
          )
        ]));
  }
}
