import 'package:flutter/material.dart';
import 'appBar.dart';

class CalcDiet extends StatefulWidget {
  @override
  _CalcDietState createState() => _CalcDietState();
}

class _CalcDietState extends State<CalcDiet> {
  List<bool> isItVisible = [false, false, false, false];
  List<String> meal = ["아침", "점심", "저녁", "간식"];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: basicAppBar('calcDiet', context),
        drawer: NavDrawer(),
        body: Container(
          child: Column(
            children: [
              returnDietButton(0),
              returnDietButton(1),
              returnDietButton(2),
              returnDietButton(3),
            ],
          ),
        ));
  }

  Widget returnDietButton(int index) {
    return Expanded(
      flex: 1,
      child: Row(
        children: [diet(index), addDiet(index)],
      ),
    );
  }

  Widget diet(int index) {
    return FlatButton(
        onPressed: () {
          setState(() {
            isItVisible[index] = !isItVisible[index];
          });
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
          ),
          child: Text(
            meal[index],
            style: TextStyle(fontSize: 50),
          ),
        ));
  }

  Widget addDiet(int index) {
    return Visibility(
        visible: isItVisible[index],
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
          ),
          child: Text(meal[index]),
        ));
  }
}
