import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'model.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;

class TransFoodFAB extends StatefulWidget {
  final Function() onPressed;
  final String tooltip;
  final IconData icon;

  TransFoodFAB({this.onPressed, this.tooltip, this.icon});

  @override
  _TransFoodFABState createState() => _TransFoodFABState();
}

class _TransFoodFABState extends State<TransFoodFAB>
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
      begin: Colors.black45,
      end: Colors.orange[300],
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
        onPressed: () async {
          final dbHelper = DBHelperFood();
          ByteData data = await rootBundle.load("assets/foodNutriData.xlsx");
          List<int> bytes =
              data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
          dbHelper.deleteAllFood();
          print("start");
          var excel = Excel.decodeBytes(bytes);
          for (var table in excel.tables.keys) {
            for (var row in excel.tables[table].rows) {
              var food = Food(
                  code: row[0],
                  dbArmy: row[1],
                  foodName: row[2],
                  foodKinds: row[3],
                  kcal: row[4],
                  protein: row[5],
                  carbohydrate: row[6],
                  fat: row[7]);

              await dbHelper.createData(food);
            }
          }
          print("finish");
        },
        tooltip: 'Add',
        child: Icon(Icons.add, size: 30),
        backgroundColor: Colors.black45,
      ),
    );
  }

  Widget search() {
    return Container(
      child: FloatingActionButton(
        heroTag: null,
        onPressed: () {},
        tooltip: 'Search',
        child: Icon(Icons.search, size: 30),
        backgroundColor: Colors.black45,
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
