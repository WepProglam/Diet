import 'package:flutter/material.dart';
import 'appBar.dart';

class CalcDiet extends StatefulWidget {
  @override
  _CalcDietState createState() => _CalcDietState();
}

class _CalcDietState extends State<CalcDiet> {
  Map visibleMeal = {
    "아침": {"visiblity": false, "added": false},
    "점심": {"visiblity": false, "added": false},
    "저녁": {"visiblity": false, "added": false},
    "간식": {"visiblity": false, "added": false}
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
              returnDietButton("아침"),
              returnDietButton("점심"),
              returnDietButton("저녁"),
              returnDietButton("간식"),
            ],
          ),
        ));
  }

  Widget returnDietButton(String key) {
    return Expanded(
      flex: 1,
      child: Row(
        children: [diet(key), addDiet(key)],
      ),
    );
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
        flex: 4,
        child: AnimatedOpacity(
            // If the widget is visible, animate to 0.0 (invisible).
            // If the widget is hidden, animate to 1.0 (fully visible).
            opacity: visibleMeal[key]["visiblity"] ? 1.0 : 0.0,
            duration: Duration(milliseconds: 300),
            // The green box must be a child of the AnimatedOpacity widget.
            child: Container(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FlatButton(
                  child: Center(
                    child: Text(
                      visibleMeal[key]["added"] ? "수정하기" : "추가하기",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                  ),
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
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.black)),
                  ),
              ],
            ))));
  }
}
