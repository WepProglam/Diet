import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'appBar.dart';
import 'package:intl/intl.dart';
import 'model.dart';
import 'db_helper.dart';
import 'activityPage.dart';
import 'package:auto_size_text/auto_size_text.dart';

class PersonalForm extends StatefulWidget {
  @override
  _PersonalForm createState() => _PersonalForm();
}

class _PersonalForm extends State<PersonalForm> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _bmiController = TextEditingController();
  final _strengthController = TextEditingController();
  final _sexController = TextEditingController();
  final _ageController = TextEditingController();

  final _weightTargetController = TextEditingController();
  final _bmiTargetController = TextEditingController();
  final _muscleTargetController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _purposeList = [
    DropdownMenuItem(child: Center(child: Text('다이어트')), value: 0),
    DropdownMenuItem(child: Center(child: Text('벌크업')), value: 1),
    DropdownMenuItem(child: Center(child: Text('린매스업')), value: 2),
    // DropdownMenuItem(child: Center(child: Text('빈둥빈둥')), value: 4),
    // DropdownMenuItem(child: Center(child: Text('좌식업무')), value: 5),
    // DropdownMenuItem(child: Center(child: Text('돌아다니는 업무')), value: 6),
    // DropdownMenuItem(child: Center(child: Text('활동적인 업무')), value: 7),
    // DropdownMenuItem(child: Center(child: Text('일반 직장인')), value: 8),
    // DropdownMenuItem(child: Center(child: Text('휴가 직장인')), value: 9)
  ];
  int _selValue = 0;
  int _sexValue = 0;
  // int purpose_index = 1;
  var dbHelper = DBHelperPerson();
  var hint = {};
  bool typeStart = false;
  int curIndex = 0;
  SwiperController swiperController = new SwiperController();

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
      hint1['height'] = value.isNotEmpty ? value.last.height : null;
      hint1['weight'] = value.isNotEmpty ? value.last.weight : null;
      hint1['bmi'] = value.isNotEmpty ? value.last.bmi : null;
      hint1['time'] = value.isNotEmpty ? value.last.time : null;
      hint1['muscleMass'] = value.isNotEmpty ? value.last.muscleMass : null;
      hint1['purpose'] = value.isNotEmpty ? value.last.purpose : null;
      hint1['metabolism'] = value.isNotEmpty
          ? resetMetabolism(value.last.metabolism, value.last.purpose)
          : null;
      hint1['activity'] = value.isNotEmpty ? value.last.activity : null;
      hint1['weightTarget'] = value.isNotEmpty ? value.last.weightTarget : null;
      hint1['bmiTarget'] = value.isNotEmpty ? value.last.bmiTarget : null;
      hint1['muscleTarget'] = value.isNotEmpty ? value.last.muscleTarget : null;
      hint1['sex'] = value.isNotEmpty ? value.last.sex : null;
      hint1['age'] = value.isNotEmpty ? value.last.age : null;
    }, onError: (e) {
      hint1['height'] = null;
      hint1['weight'] = null;
      hint1['bmi'] = null;
      hint1['time'] = null;
      hint1['muscleMass'] = null;
      hint1['purpose'] = null;
      hint1['weightTarget'] = null;
      hint1['bmiTarget'] = null;
      hint1['muscleTarget'] = null;
      hint1['sex'] = null;
      hint1['metabolism'] = null;
      hint1['age'] = null;
    });
    return hint1;
  }

  num resetMetabolism(num metabolism, int purpose) {
    if (metabolism != null) {
      switch (purpose) {
        case 0: //다이어트
          metabolism += 500;
          break;
        case 1: //벌크업
          metabolism -= 500;
          break;
        case 2: //린매스업(일반)
          break;
        default:
      }
    }

    return metabolism;
  }

  num setMetabolism(num metabolism, int purpose) {
    // print(purpose);
    // print("hi");
    switch (purpose) {
      case 0:
        metabolism -= 500;
        break;
      case 1:
        metabolism += 500;
        break;
      case 2:
        break;
      default:
    }
    return metabolism;
  }

  void getHintGet() async {
    hint = await getHint();
    if (hint['time'] != null && !typeStart) {
      setState(() {
        _selValue = hint['purpose'];
        _bmiController.text = hint['bmi'] == null ? "" : hint['bmi'].toString();
        _weightController.text =
            hint['weight'] == null ? "" : hint['weight'].toString();
        _heightController.text =
            hint['height'] == null ? "" : hint['height'].toString();
        _strengthController.text =
            hint['muscleMass'] == null ? "" : hint['muscleMass'].toString();
        _weightTargetController.text =
            hint['weightTarget'] == null ? "" : hint['weightTarget'].toString();
        _bmiTargetController.text =
            hint['bmiTarget'] == null ? "" : hint['bmiTarget'].toString();
        _muscleTargetController.text =
            hint['muscleTarget'] == null ? "" : hint['muscleTarget'].toString();

        _sexController.text = hint['sex'] == null ? "" : hint['sex'].toString();
        _ageController.text = hint['age'] == null ? "" : hint['age'].toString();
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
          // FocusScopeNode currentFocus = FocusScope.of(context);
          // currentFocus.unfocus();
          // print('curIndex $curIndex');
          if (_formKey.currentState.validate()) {
            if (curIndex == 0) {
              swiperController.next(animation: true);
            }
          }
        },
        child: Scaffold(
          // backgroundColor: Color(0xFFFFFEF5),
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
              centerTitle: true, title: Text("신체 정보"), actions: <Widget>[]),
          body: Center(
            child: Form(
              key: _formKey,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Swiper(
                  duration: 1500,
                  controller: swiperController,
                  scrollDirection: Axis.vertical,
                  onIndexChanged: (index) {
                    curIndex = index;
                  },
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: index == 0
                              ? [
                                  subBuilderQuestion("나이", "",
                                      controller: _ageController,
                                      hint: hint['age']),
                                  Expanded(
                                      flex: 1,
                                      child: Center(
                                          child: Row(
                                        children: [
                                          Spacer(
                                            flex: 2,
                                          ),
                                          spacer_question('성별'),
                                          Expanded(
                                            flex: 8,
                                            child: DropdownButtonFormField(
                                              value: _sexValue,
                                              items: [
                                                DropdownMenuItem(
                                                  child:
                                                      Center(child: Text('남성')),
                                                  value: 0,
                                                ),
                                                DropdownMenuItem(
                                                  child:
                                                      Center(child: Text('여성')),
                                                  value: 1,
                                                ),
                                              ],
                                              decoration:
                                                  InputDecoration(hintText: ""),
                                              validator: (value) {
                                                if (value > 1) {
                                                  return 'Select Number 1-2';
                                                }
                                                return null;
                                              },
                                              onChanged: (value) {
                                                setState(() {
                                                  // typeStart = true;
                                                  // purpose_index = value;

                                                  _sexValue = value;
                                                  print(_sexValue);
                                                });
                                              },
                                              // onSaved: (value) {
                                              //   // print(purpose_index);
                                              // },
                                            ),
                                          ),
                                          Spacer(
                                            flex: 3,
                                          ),
                                        ],
                                      ))),
                                  subBuilderQuestion("키", "cm",
                                      controller: _heightController,
                                      hint: hint['height']),
                                  subBuilderQuestion("몸무게", "kg",
                                      controller: _weightController,
                                      hint: hint['weight']),
                                  subBuilderQuestion("체지방률", "%",
                                      controller: _bmiController,
                                      hint: hint['bmi']),
                                  subBuilderQuestion("골격근량", "kg",
                                      controller: _strengthController,
                                      hint: hint['muscleMass']),
                                  Spacer(
                                    flex: 1,
                                  ),
                                  Spacer(
                                    flex: 2,
                                  ),
                                ]
                              : index == 1
                                  ? [
                                      subBuilderQuestion("목표 몸무게", "kg",
                                          controller: _weightTargetController,
                                          hint: hint['weightTarget']),
                                      subBuilderQuestion("목표 bmi", "",
                                          controller: _bmiTargetController,
                                          hint: hint['bmiTarget']),
                                      subBuilderQuestion("목표 골격근량", "kg",
                                          controller: _muscleTargetController,
                                          hint: hint['muscleTarget']),
                                      Expanded(
                                          flex: 1,
                                          child: Center(
                                              child: Row(
                                            children: [
                                              Spacer(
                                                flex: 2,
                                              ),
                                              spacer_question('목표'),
                                              Expanded(
                                                flex: 8,
                                                child: DropdownButtonFormField(
                                                  value: _selValue,
                                                  items: [
                                                    DropdownMenuItem(
                                                      child: Center(
                                                          child: Text('다이어트')),
                                                      value: 0,
                                                    ),
                                                    DropdownMenuItem(
                                                      child: Center(
                                                          child: Text('벌크업')),
                                                      value: 1,
                                                    ),
                                                    DropdownMenuItem(
                                                      child: Center(
                                                          child: Text('린매스업')),
                                                      value: 2,
                                                    ),
                                                  ],
                                                  decoration: InputDecoration(
                                                      hintText: ""),
                                                  validator: (value) {
                                                    if (value > 2) {
                                                      return 'Select Number 0-2';
                                                    }
                                                    return null;
                                                  },
                                                  onChanged: (value) {
                                                    setState(() {
                                                      // typeStart = true;
                                                      // purpose_index = value;
                                                      _selValue = value;
                                                      print(_selValue);
                                                    });
                                                  },
                                                  // onSaved: (value) {
                                                  //   // print(purpose_index);
                                                  // },
                                                ),
                                              ),
                                              Spacer(
                                                flex: 3,
                                              ),
                                            ],
                                          ))),
                                      Spacer(),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                10,
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                          ),
                                          color: Colors.deepOrangeAccent[700],
                                          child: InkWell(
                                            splashColor: Colors.white,
                                            child: Ink(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Spacer(),
                                                  Container(
                                                    child: Icon(Icons.save),
                                                  ),
                                                  Spacer(),
                                                  AutoSizeText("저장",
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                          fontSize: 20)),
                                                  Spacer(),
                                                ],
                                              ),
                                            ),
                                            onTap: () async {
                                              if (_formKey.currentState
                                                  .validate()) {
                                                // dbHelper.deleteAllPerson();
                                                String time =
                                                    DateFormat('yyyy-MM-dd')
                                                        .format(DateTime.now())
                                                        .toString();

                                                var person = Person(
                                                    height: double.parse(
                                                        _heightController
                                                            .value.text),
                                                    weight: double.parse(
                                                        _weightController
                                                            .value.text),
                                                    bmi: double.parse(
                                                        _bmiController
                                                            .value.text),
                                                    muscleMass: double.parse(
                                                        _strengthController
                                                            .value.text),
                                                    purpose: _selValue,
                                                    sex: _sexValue,
                                                    time: time,
                                                    achieve: 0.0,
                                                    metabolism:
                                                        hint['metabolism'] != null
                                                            ? setMetabolism(hint['metabolism'], _selValue)
                                                            : null,
                                                    activity: hint['activity'] != null ? hint['activity'] : 1,
                                                    weightTarget: double.parse(_weightTargetController.value.text),
                                                    bmiTarget: double.parse(_bmiTargetController.value.text),
                                                    muscleTarget: double.parse(_muscleTargetController.value.text),
                                                    age: double.parse(_ageController.value.text));

                                                await dbHelper
                                                    .createHelper(person);
                                                Navigator.pushNamed(
                                                    context, '/activityPage',
                                                    arguments: <String, Person>{
                                                      'person': person
                                                    });
                                              }

                                              //print(_heightController.text);
                                            },
                                          ),
                                        ),
                                      ),
                                      Spacer(
                                        flex: 1,
                                      ),
                                    ]
                                  : [ActivityPage()]),
                      // decoration: BoxDecoration(color: Colors.white),
                    );
                  },
                  itemCount: 2,
                  // viewportFraction: 0.8,

                  // scale: 0.9,
                  pagination: new SwiperPagination(),
                  // control:
                  //     new SwiperControl(iconNext: null, iconPrevious: null),
                ),
              ),
            ),
          ),
          // floatingActionButton: FloatingActionButton(
          //   // backgroundColor: Color(0xFF69C2B0),
          //   // focusColor: Color(0xFF69C2B0),
          //   child: Icon(Icons.done),
          //   onPressed: () async {
          //     if (_formKey.currentState.validate()) {
          //       // dbHelper.deleteAllPerson();
          //       String time =
          //           DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();

          //       var person = Person(
          //           height: double.parse(_heightController.value.text),
          //           weight: double.parse(_weightController.value.text),
          //           bmi: double.parse(_bmiController.value.text),
          //           muscleMass: double.parse(_strengthController.value.text),
          //           purpose: _selValue,
          //           time: time,
          //           achieve: 0.0,
          //           metabolism: hint['metabolism'],
          //           activity: hint['activity'],
          //           nutriRate: hint['nutriRate'],
          //           weightTarget:
          //               double.parse(_weightTargetController.value.text),
          //           bmiTarget: double.parse(_bmiTargetController.value.text),
          //           muscleTarget:
          //               double.parse(_muscleTargetController.value.text));

          //       await dbHelper.createHelper(person);
          //       Navigator.pushNamed(context, '/activityPage',
          //           arguments: <String, Person>{'person': person});
          //     }

          //     //print(_heightController.text);
          //   },
          // ),
        ));
  }

  Widget subBuilderQuestion(var question, var unit,
      {var controller, var hint}) {
    return Expanded(
        flex: 1,
        child: Center(
            child: Row(
          children: [
            Spacer(
              flex: 2,
            ),
            spacer_question(question),
            Expanded(flex: 6, child: questionForm(controller, hint)),
            spacer_unit(unit),
            Spacer(
              flex: 1,
            ),
          ],
        )));
  }

  /* Widget subBuilderPurpose(var question, {var hint}) {
    return Expanded(
        flex: 1,
        child: Center(
            child: Row(
          children: [
            Spacer(
              flex: 2,
            ),
            spacer_question(question),
            Expanded(flex: 8, child: pruposeForm(hint)),
            Spacer(
              flex: 3,
            ),
          ],
        )));
  } */

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
        } else {
          try {
            if (num.parse(value) >= 0) {
              return null;
            } else {
              return "Please enter positive number";
            }
          } catch (e) {
            return 'Please enter number';
          }
        }
      },
      onChanged: (text) {
        setState(() {
          typeStart = true;
        });
      },
    );
  }

  /* Widget pruposeForm(var hint) {
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
        setState(() {
          typeStart = true;
          purpose_index = value;
          _selValue = value;
        });
      },
      onSaved: (value) {
        // print(purpose_index);
      },
    );
  } */

  Widget spacer_icon({var icon}) {
    return Expanded(flex: 1, child: Center(child: icon));
  }

  Widget spacer_question(var question) {
    return Expanded(
        flex: 4,
        child: Center(
          child: AutoSizeText(
            question,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
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
