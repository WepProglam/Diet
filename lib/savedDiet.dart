//To_ToRo
import 'package:flutter/material.dart';
import 'package:flutter_application_1/db_helper.dart';
import 'model.dart';
import 'appBar.dart';

class SavedDiet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFEF5),
      appBar: basicAppBar('Diet List', context),
      drawer: NavDrawer(),
      body: Center(
        child: DietList(),
      ),
      floatingActionButton: TransFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class DietArguments {
  final String dietName;
  final String foodInfo;

  DietArguments(this.dietName, this.foodInfo);
}

class DietList extends StatefulWidget {
  @override
  _DietListState createState() => _DietListState();
}

class _DietListState extends State<DietList> {
  final dbHelperDiet = DBHelperDiet();
  List<Diet> dietNameEX = [];
  bool fromCalcDiet = false;

  void getInfo() async {
    await dbHelperDiet.getAllMyDiet().then((val) {
      dietNameEX = [];
      for (var item in val) {
        dietNameEX.add(item);
      }
      // print(dietNameEX.length);
    });
    setState(() {});
  }

  @override
  void initState() {
    getInfo();
    super.initState();
  }

  void reactWhenCalc(int index) {
    // print(dietNameEX[index].toMap());
    Navigator.pop(context, <String, Map>{"myDiet": dietNameEX[index].toMap()});
  }

  void reactWhenAdd(int index) {
    Navigator.pushNamed(context, '/addDiet',
            arguments: <String, Map>{"myTempoDiet": dietNameEX[index].toMap()})
        .then((_) {
      getInfo();
    });
  }

  void react(int index, bool flag) {
    // print(flag);
    if (flag) {
      reactWhenCalc(index);
    } else {
      reactWhenAdd(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, bool> args = ModalRoute.of(context).settings.arguments;
    //null일 경우를 안해놓냐 슈발
    if (args != null && args['fromCalcDiet']) {
      fromCalcDiet = true;
    } else {
      fromCalcDiet = false;
    }

    return GridView.count(
      padding: EdgeInsets.all(8),
      crossAxisCount: 2,
      //각 항목의 사이즈
      childAspectRatio: 5 / 3,
      children: List.generate(dietNameEX.length, (index) {
        return Card(
          margin: EdgeInsets.all(8),
          child: Column(
            children: [
              Expanded(
                  flex: 2,
                  child: FlatButton(
                    //onPressed에 식단 설정 페이지로 이동하는 함수 넣기
                    onPressed: () async {
                      react(index, fromCalcDiet);
                    },
                    child: Text(
                      '${dietNameEX[index].dietName}',
                      style: TextStyle(fontSize: 30),
                    ),
                  )),
              Expanded(
                flex: 1,
                child: IconButton(
                  iconSize: 20,
                  onPressed: () {
                    setState(() {
                      dbHelperDiet.deleteDiet(dietNameEX[index].dietName);
                      dietNameEX.removeAt(index);
                    });
                  },
                  icon: Icon(Icons.delete),
                ),
              ),
            ],
          ),
          color: Colors.white70,
        );
      }),
    );
  }
}

class TransFAB extends StatefulWidget {
  final Function() onPressed;
  final String tooltip;
  final IconData icon;

  TransFAB({this.onPressed, this.tooltip, this.icon});

  @override
  _TransFABState createState() => _TransFABState();
}

class _TransFABState extends State<TransFAB>
    with SingleTickerProviderStateMixin {
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;

  @override
  initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      //이유는 모르겠지만 핫리로딩이 안 됨 다시 실행해야 적용됨.
      begin: Color(0xFF69C2B0),
      end: Color(0xFF7EE0CC),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget add() {
    return Container(
      child: FloatingActionButton(
        heroTag: null,
        onPressed: () {
          //이거 addDiet로 바꿔야 함
          Navigator.pushNamed(context, '/addDiet');
        },
        tooltip: 'Add',
        child: Icon(Icons.add, size: 30),
        backgroundColor: Color(0xFF7EE0CC),
      ),
    );
  }

  Widget search() {
    return Container(
      child: FloatingActionButton(
        heroTag: null,
        onPressed: () {
          Navigator.pushNamed(context, '/searchDiet');
        },
        tooltip: 'Search',
        child: Icon(Icons.search, size: 30),
        backgroundColor: Color(0xFF7EE0CC),
      ),
    );
  }

  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        heroTag: null,
        backgroundColor: _buttonColor.value,
        onPressed: animate,
        tooltip: 'Toggle',
        child: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: _animateIcon,
          size: 30,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 2.0,
            0.0,
          ),
          child: search(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value,
            0.0,
          ),
          child: add(),
        ),
        toggle(),
      ],
    );
  }
}
