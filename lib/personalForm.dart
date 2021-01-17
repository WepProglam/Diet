import 'dart:math';

import 'package:flutter/material.dart';
import 'savedDiet.dart';
import 'appBar.dart';
import 'package:intl/intl.dart';
import 'model.dart';
import 'db_helper.dart';

class PersonalForm extends StatefulWidget {
  @override
  _PersonalForm createState() => _PersonalForm();
}

class _PersonalForm extends State<PersonalForm> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _bmiController = TextEditingController();
  final _strengthController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _purposeList = [
    DropdownMenuItem(child: Center(child: Text('다이어트')), value: 1),
    DropdownMenuItem(child: Center(child: Text('벌크업')), value: 2),
    DropdownMenuItem(child: Center(child: Text('린매스업')), value: 3),
    DropdownMenuItem(child: Center(child: Text('빈둥빈둥')), value: 4),
    DropdownMenuItem(child: Center(child: Text('좌식업무')), value: 5),
    DropdownMenuItem(child: Center(child: Text('돌아다니는 업무')), value: 6),
    DropdownMenuItem(child: Center(child: Text('활동적인 업무')), value: 7),
    DropdownMenuItem(child: Center(child: Text('일반 직장인')), value: 8),
    DropdownMenuItem(child: Center(child: Text('휴가 직장인')), value: 9)
  ];
  int _selValue = 1;
  int purpose_index = 1;
  var dbHelper = DBHelperPerson();
  var hint = {};

  // @override
  // void initState() {
  //   getHint();
  //   super.initState();
  // }

  // @override
  // void dispose() {
  //   _heightController.dispose();
  //   _weightController.dispose();
  //   _bmiController.dispose();
  //   _strengthController.dispose();
  //   super.dispose();
  // }

  Future<Map> getHint() async {
    var hint1 = {};

    await dbHelper.getAllPerson().then((value) {
      print(value);
      print(value.last.toMap());
      hint1['height'] = value.isNotEmpty ? value.last.height : null;
      hint1['weight'] = value.isNotEmpty ? value.last.weight : null;
      hint1['bmi'] = value.isNotEmpty ? value.last.bmi : null;
      hint1['time'] = value.isNotEmpty ? value.last.time : null;
      hint1['muscleMass'] = value.isNotEmpty ? value.last.muscleMass : null;
      hint1['purpose'] = value.isNotEmpty ? value.last.purpose : null;
    });
    return hint1;
  }

  void getHintGet() async {
    hint = await getHint();
    if (hint.isNotEmpty) {
      setState(() {
        _bmiController.text = hint['bmi'] == null ? "" : hint['bmi'].toString();
        _weightController.text =
            hint['weight'] == null ? "" : hint['weight'].toString();
        _heightController.text =
            hint['height'] == null ? "" : hint['height'].toString();
        _strengthController.text =
            hint['muscleMass'] == null ? "" : hint['muscleMass'].toString();
      });
    }
  }

  @override
  void didChangeDependencies() {
    getHintGet();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          currentFocus.unfocus();
        },
        child: Scaffold(
          backgroundColor: Color(0xFFFFFEF5),
          resizeToAvoidBottomPadding: false,
          appBar: basicAppBar('Personal Form', context),
          drawer: NavDrawer(),
          body: Center(
              child: Form(
            key: _formKey,
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                // Spacer(
                //   flex: 1,
                // ),

                subBuilderQuestion("키", "CM",
                    controller: _heightController,
                    icon: Icon(Icons.accessibility),
                    hint: hint['height']),
                subBuilderQuestion("몸무게", "KG",
                    controller: _weightController,
                    icon: Icon(Icons.accessibility),
                    hint: hint['weight']),
                subBuilderQuestion("체지방률", "%",
                    controller: _bmiController,
                    icon: Icon(Icons.directions_run),
                    hint: hint['bmi']),
                subBuilderQuestion("골격근량", "KG/%",
                    controller: _strengthController,
                    icon: Icon(Icons.fitness_center),
                    hint: hint['muscleMass']),
                subBuilderPurpose("목표",
                    icon: Icon(Icons.accessibility), hint: hint['purpose']),
                Spacer(
                  flex: 1,
                ),
                Spacer(
                  flex: 2,
                ),
              ],
            ),
          )),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Color(0xFF69C2B0),
            focusColor: Color(0xFF69C2B0),
            child: Icon(Icons.done),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                // dbHelper.deleteAllPerson();
                String time =
                    DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();

                print(_heightController.value.text);

                var person = Person(
                    height: _heightController.value.text,
                    weight: _weightController.value.text,
                    bmi: _bmiController.value.text,
                    muscleMass: _strengthController.value.text,
                    purpose: purpose_index - 1,
                    time: time,
                    achieve: 0);

                dbHelper.createHelper(person);
              }

              //print(_heightController.text);
            },
          ),
        ));
  }

  Widget subBuilderQuestion(var question, var unit,
      {var controller, var icon, var hint}) {
    return Expanded(
        flex: 1,
        child: Center(
            child: Row(
          children: [
            Spacer(
              flex: 1,
            ),
            spacer_icon(icon: icon),
            spacer_question(question),
            Expanded(flex: 6, child: questionForm(controller, hint)),
            spacer_unit(unit),
            Spacer(
              flex: 1,
            ),
          ],
        )));
  }

  Widget subBuilderPurpose(var question, {var icon, var hint}) {
    return Expanded(
        flex: 1,
        child: Center(
            child: Row(
          children: [
            Spacer(
              flex: 1,
            ),
            spacer_icon(icon: icon),
            spacer_question(question),
            Expanded(flex: 8, child: pruposeForm(hint)),
            Spacer(
              flex: 2,
            ),
          ],
        )));
  }

  Widget questionForm(TextEditingController controller, var hint) {
    var hintText = hint.toString();
    return TextFormField(
      autofocus: false,
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(hintText: hint == null ? "" : hintText),
      textAlign: TextAlign.center,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter info';
        }
        return null;
      },
    );
  }

  Widget pruposeForm(var hint) {
    var _selValue = hint == null ? 1 : hint + 1;
    return DropdownButtonFormField(
      value: _selValue,
      items: _purposeList,
      decoration: InputDecoration(hintText: ""),
      validator: (value) {
        if (value > 10) {
          return 'Select Number 1-9';
        }
        return null;
      },
      onChanged: (value) {
        purpose_index = value;
        _selValue = value;
      },
      onSaved: (value) {
        print(purpose_index);
      },
    );
  }

  Widget spacer_icon({var icon}) {
    return Expanded(flex: 1, child: Center(child: icon));
  }

  Widget spacer_question(var question) {
    return Expanded(
        flex: 4,
        child: Center(
          child: Text(
            question,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
          ),
        ));
  }

  Widget spacer_unit(var unit) {
    return Expanded(
        flex: 3,
        child: Center(
          child: Text(
            unit,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
          ),
        ));
  }
}
