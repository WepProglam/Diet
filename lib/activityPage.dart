import 'dart:math';

import 'package:flutter/material.dart';
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
  TextEditingController carbohydrateText = TextEditingController();

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
      } else {
        bmr = (655.1 +
            (9.6 * hint['weight']) +
            (1.8 * hint['height']) -
            (4.7 * 22));
        bmrText.text = bmr.toStringAsFixed(1);
      }
    } else {
      bmrText.text = '신체 정보가 비어있습니다.';
    }
  }

  @override
  void didChangeDependencies() {
    bmrVal();
    super.didChangeDependencies();
  }

  Widget carbohydrateRate(TextEditingController controller) {
    return Center(
      child: Row(
        children: [
          Spacer(
            flex: 1,
          ),
          Expanded(flex: 4, child: Text('탄수화물 비율:')),
          Expanded(
            flex: 8,
            child: TextFormField(
                autofocus: false,
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center),
          ),
          Text('%'),
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
          Spacer(
            flex: 1,
          ),
          Container(
            //사이즈 확인용
            color: Colors.yellow,
            child: Column(
              children: [
                Text(
                  '기초대사량(BMR)',
                  style: TextStyle(fontSize: 15),
                ),
                TextFormField(
                  controller: bmrText,
                  style: TextStyle(
                    fontSize: 40,
                  ),
                  textAlign: TextAlign.center,
                  readOnly: true,
                ),
                Text(
                  'kcal',
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
          Spacer(
            flex: 1,
          ),
          carbohydrateRate(carbohydrateText),
          Spacer(
            flex: 1,
          ),
        ],
      ),
    ));
  }
}
