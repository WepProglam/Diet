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
  var hint = {};
  num bmr;

  void getHint() async {
    var hint1 = {};
    await dbHelperPerson.getAllPerson().then((value) {
      hint1['height'] = value.isNotEmpty ? value.last.height : null;
      hint1['weight'] = value.isNotEmpty ? value.last.weight : null;
      hint1['bmi'] = value.isNotEmpty ? value.last.bmi : null;
      hint1['time'] = value.isNotEmpty ? value.last.time : null;
      hint1['muscleMass'] = value.isNotEmpty ? value.last.muscleMass : null;
      hint1['purpose'] = value.isNotEmpty ? value.last.purpose : null;
    });
    hint = hint1;
  }

  @override
  Widget build(BuildContext context) {
    getHint();

    //조건: 성별 + hint에 값이 있는지
    if (true) {
      bmr = (66.5 +
          (13.8 * hint['weight']) +
          (5 * hint['height']) -
          (6.8 * 23)); //23 -> person['age']
    } else {
      bmr = (655.1 +
          (9.6 * hint['weight']) +
          (1.8 * hint['height']) -
          (4.7 * 23));
    }

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
                  '기초대사량(kcal)',
                  style: TextStyle(fontSize: 15),
                ),
                Text('$bmr', style: TextStyle(fontSize: 40)),
              ],
            ),
          ),
          Spacer(
            flex: 1,
          ),
        ],
      ),
    ));
  }
}
