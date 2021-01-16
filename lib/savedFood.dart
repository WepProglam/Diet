//To_ToRo
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/db_helper.dart';
import 'package:flutter_application_1/model.dart';
import 'appBar.dart';
import 'mainStream.dart' as mainStream;

// StreamController<Map> streamController = StreamController<Map>.broadcast();
StreamController<Map> streamController = mainStream.streamController;

class SavedFood extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFEF5),
      appBar: basicAppBar('Food List', context),
      drawer: NavDrawer(),
      body: Center(
        child: FoodList(),
      ),
      floatingActionButton: TransFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class FoodList extends StatefulWidget {
  @override
  _FoodListState createState() => _FoodListState();
}

class _FoodListState extends State<FoodList> {
  final dbHelperFood = DBHelperFood();
  List<Food> foodNameEX = [];
  final dBHelperMyTempoFood = DBHelperMyTempoFood();

  void getInfo() async {
    await dbHelperFood.getAllMyFood().then((val) {
      print(val.length);
      for (var item in val) {
        foodNameEX.add(item);
      }
      print(foodNameEX.length);
    });
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getInfo();
  }

  @override
  Widget build(BuildContext context) {
    //실제로는 db에서 얻어와야 함

    return GridView.count(
      padding: EdgeInsets.all(8),
      crossAxisCount: 2,
      //각 항목의 사이즈
      childAspectRatio: 5 / 3,
      children: List.generate(
        foodNameEX.length,
        (index) {
          return Card(
            margin: EdgeInsets.all(8),
            child: FlatButton(
              //onPressed에 식단 설정 페이지로 이동하는 함수 넣기
              onPressed: () async {
                print(foodNameEX[index].toMap());
                await dBHelperMyTempoFood.createData(foodNameEX[index]);
                Navigator.pushNamed(context, '/addFood');
                print(foodNameEX[index].toMap());
              },

              child: ListTile(
                title: Text(foodNameEX[index].foodName.toString()),
                subtitle: Text(foodNameEX[index].kcal.toString() + "kcal"),
                trailing: FlatButton(
                  child: Icon(Icons.delete),
                  onPressed: () {
                    print(foodNameEX[index].code);
                    setState(() {
                      dbHelperFood.deleteFood(foodNameEX[index].code);
                      foodNameEX.removeAt(index);
                    });
                  },
                ),
              ),
              // Text(
              //   '${foodNameEX[index].foodName}',
              //   style: TextStyle(fontSize: 30),
              // ),
            ),
            color: Colors.white70,
          );
        },
      ),
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
      //이유는 모르겠지만 핫리로딩이 안됨 다시 실행해야 적용됨.
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

  // @override
  // dispose() {
  //   _animationController.dispose();
  //   super.dispose();
  // }

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
          Navigator.pushNamed(context, '/addFood');
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
          Navigator.pushNamed(context, '/searchFood');
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
