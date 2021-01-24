import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'db_helper.dart';
import 'model.dart';
import 'appBar.dart';
import 'package:flutter/material.dart';

class Activity extends StatelessWidget {
  const Activity({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: basicAppBar('Activity Page', context),
      drawer: NavDrawer(),
      body: ActivityPage(),
    );
  }
}

class ActivityPage extends StatefulWidget {
  ActivityPage({Key key}) : super(key: key);

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  var dbHelperPerson = DBHelperPerson();

  TextEditingController bmrText = TextEditingController();
  TextEditingController amText = TextEditingController();
  TextEditingController carbohydrateText = TextEditingController();
  int _nutriRateValue = 1;
  int _activityValue = 1;

  var hint = {};

  num bmr;

  Future<Map> getHint() async {
    var hint1 = {};
    await dbHelperPerson.getAllPerson().then((value) {
      hint1['height'] = value.isNotEmpty ? value.last.height : null;
      hint1['weight'] = value.isNotEmpty ? value.last.weight : null;
      hint1['bmi'] = value.isNotEmpty ? value.last.bmi : null;
      hint1['time'] = value.isNotEmpty ? value.last.time : null;
      hint1['muscleMass'] = value.isNotEmpty ? value.last.muscleMass : null;
      hint1['purpose'] = value.isNotEmpty ? value.last.purpose : null;
      hint1['achieve'] = value.isNotEmpty ? value.last.purpose : null;
    });
    return hint1;
  }

  void bmrVal() async {
    hint = await getHint();
    //조건: 성별
    if (hint.isNotEmpty) {
      if (true) {
        bmr = (66.5 +
            (13.8 * hint['weight']) +
            (5 * hint['height']) -
            (6.8 * 22)); //23 -> person['age'] - 1 (만나이)
        bmrText.text = bmr.toStringAsFixed(1);
        amText.text = (bmr * 1.2).toStringAsFixed(1);
      } else {
        bmr = (655.1 +
            (9.6 * hint['weight']) +
            (1.8 * hint['height']) -
            (4.7 * 22));
        bmrText.text = bmr.toStringAsFixed(1);
        amText.text = (bmr * 1.2).toStringAsFixed(1);
      }
    } else {
      bmrText.text = '신체 정보가 비어있습니다.';
      amText.text = bmrText.text;
    }
  }

  @override
  void didChangeDependencies() {
    bmrVal();
    super.didChangeDependencies();
  }

  Widget metabolicRate(String mr, TextEditingController controller) {
    String title = '';

    if (mr == 'BMR') {
      title = '기초대사량(BMR)';
    } else if (mr == 'AM') {
      title = '1일 총 에너지 대사량';
    }

    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 15),
        ),
        TextFormField(
            autofocus: false,
            controller: controller,
            style: TextStyle(
              fontSize: 40,
            ),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            readOnly: (mr == 'AM' && _activityValue == 6) ? false : true),
        Text(
          'kcal',
          style: TextStyle(fontSize: 15),
        ),
      ],
    );
  }

  Widget nutriRate() {
    return Center(
      child: Row(
        children: [
          Spacer(
            flex: 1,
          ),
          Text('탄 : 단 : 지'),
          Spacer(
            flex: 1,
          ),
          DropdownButton(
              value: _nutriRateValue,
              items: [
                DropdownMenuItem(child: Text('다이어트 3 : 4 : 3'), value: 1),
                DropdownMenuItem(child: Text('벌크업 4 : 4 : 2'), value: 2),
                DropdownMenuItem(child: Text('린매스업 5 : 3 : 2'), value: 3),
              ],
              onChanged: (value) {
                setState(() {
                  _nutriRateValue = value;
                });
              }),
          Spacer(
            flex: 1,
          ),
        ],
      ),
    );
  }

  Widget selActivity() {
    return Center(
      child: Row(
        children: [
          Spacer(
            flex: 1,
          ),
          DropdownButton(
              value: _activityValue,
              items: [
                DropdownMenuItem(child: Text('적은 활동 및 운동 X'), value: 1),
                DropdownMenuItem(child: Text('가벼운 활동 및 주 1~3일 운동'), value: 2),
                DropdownMenuItem(child: Text('보통 활동 및 주 3~5일 운동'), value: 3),
                DropdownMenuItem(child: Text('적극적인 활동 및 주 6~7일 운동'), value: 4),
                DropdownMenuItem(child: Text('매우 적극적인 활동 및 선수급 운동'), value: 5),
                DropdownMenuItem(child: Text('직접 설정'), value: 6),
              ],
              onChanged: (value) {
                setState(() {
                  _activityValue = value;
                  if (_activityValue == 1) {
                    amText.text =
                        (num.parse(bmrText.text) * 1.2).toStringAsFixed(1);
                  } else if (_activityValue == 2) {
                    amText.text =
                        (num.parse(bmrText.text) * 1.375).toStringAsFixed(1);
                  } else if (_activityValue == 3) {
                    amText.text =
                        (num.parse(bmrText.text) * 1.555).toStringAsFixed(1);
                  } else if (_activityValue == 4) {
                    amText.text =
                        (num.parse(bmrText.text) * 1.725).toStringAsFixed(1);
                  } else if (_activityValue == 5) {
                    amText.text =
                        (num.parse(bmrText.text) * 1.9).toStringAsFixed(1);
                  } else if (_activityValue == 6) {
                    amText.text = '';
                  }
                });
              }),
          Spacer(
            flex: 1,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
      child: Column(
        children: [
          // Spacer(
          //   flex: 1,
          // ),
          Container(
            // color: Colors.yellow,
            child: metabolicRate('BMR', bmrText),
          ),
          Spacer(
            flex: 1,
          ),
          selActivity(),
          Text('주로 하는 활동을 선택해주세요'),
          Spacer(
            flex: 1,
          ),
          nutriRate(),
          Text('탄수화물, 단백질, 지방의 열량 비율을 선택해주세요'),
          Spacer(
            flex: 1,
          ),
          Container(
            // color: Colors.yellow,
            child: metabolicRate('AM', amText),
          ),
          Spacer(
            flex: 1,
          ),
          FloatingActionButton(
              child: Icon(Icons.done),
              backgroundColor: Color(0xFF7EE0CC),
              onPressed: () {
                String time =
                    DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
                var person = Person(
                  height: hint['height'],
                  weight: hint['weight'],
                  bmi: hint['bmi'],
                  muscleMass: hint['muscleMass'],
                  purpose: hint['purpose'],
                  time: time,
                  achieve: hint['achieve'],
                  metabolism: num.parse(amText.value.text),
                  nutriRate: _nutriRateValue,
                );
                // print(person.purpose);
                dbHelperPerson.createHelper(person);
              }),
          Spacer(
            flex: 1,
          ),
        ],
      ),
    ));
  }
}
