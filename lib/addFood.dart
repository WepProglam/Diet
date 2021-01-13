import 'package:flutter/material.dart';
import 'package:flutter_application_1/savedFood.dart';
import 'appBar.dart';
import 'db_helper.dart';
import 'model.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:overlay_container/overlay_container.dart';

class AddFood extends StatefulWidget {
  @override
  _AddFood createState() => _AddFood();
}

class _AddFood extends State<AddFood> {
  final _massController = TextEditingController();
  final _carboController = TextEditingController();
  final _proController = TextEditingController();
  final _fatController = TextEditingController();
  final _ulController = TextEditingController();
  final _foodNameController = TextEditingController();
  final dbHelper = DBHelperFood();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var foodList = <Widget>[];
  final FocusNode _focusNode = FocusNode();
  OverlayEntry _overLayEntry;
  var foodInfo = {};

  @override
  void dispose() {
    _carboController.dispose();
    _proController.dispose();
    _fatController.dispose();
    _ulController.dispose();
    //_purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("setstate");
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          currentFocus.unfocus();
        },
        child: Scaffold(
            resizeToAvoidBottomPadding: false,
            appBar: basicAppBar('Add Food', context),
            drawer: NavDrawer(),
            body: Center(
                child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(
                    flex: 2,
                  ),
                  searchBar(foodInfo),
                  Spacer(
                    flex: 1,
                  ),
                  subBuilderQuestion("탄수화물", "g",
                      controller: _carboController,
                      icon: Icon(Icons.favorite),
                      value: foodInfo['carbohydrate']),
                  subBuilderQuestion("단백질", "g",
                      controller: _proController,
                      icon: Icon(Icons.restaurant_menu_outlined),
                      value: foodInfo['protein']),
                  subBuilderQuestion("지방", "g",
                      controller: _fatController,
                      icon: Icon(Icons.restaurant_outlined),
                      value: foodInfo['fat']),
                  subBuilderQuestion("열량", "kcal",
                      controller: _ulController,
                      icon: Icon(Icons.restaurant_menu_sharp),
                      value: foodInfo['kcal']),
                  Spacer(
                    flex: 1,
                  ),
                  Row(
                    children: foodList,
                  ),
                  Spacer(
                    flex: 3,
                  ),
                ],
              ),
            )),
            floatingActionButton: TransFAB()));
  }

  Widget searchBar(var foodInfo) {
    return Center(
        child: Row(
      children: [
        Spacer(
          flex: 1,
        ),
        Expanded(
            flex: 2,
            child: TypeFoodName(
                controller: _foodNameController, foodInfo: foodInfo)),
        Spacer(
          flex: 1,
        ),
      ],
    ));
  }

  Widget subBuilderQuestion(var question, var unit,
      {var controller, var icon, num value}) {
    print(value);
    return Expanded(
        flex: 1,
        child: Center(
            child: Row(
          children: [
            Spacer(
              flex: 1,
            ),
            // spacer_icon(icon: icon),
            spacer_question(question),
            Expanded(flex: 6, child: questionForm(controller, value)),
            spacer_unit(unit),
            Spacer(
              flex: 1,
            ),
          ],
        )));
  }

  Widget questionForm(TextEditingController controller, num value) {
    return TextFormField(
      autofocus: false,
      controller: controller,
      // focusNode: _focusNode,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(hintText: "$value"),
      textAlign: TextAlign.center,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter info';
        }
        return null;
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
          child: Text(question),
        ));
  }

  Widget spacer_unit(var unit) {
    return Expanded(
        flex: 3,
        child: Center(
          child: Text(unit),
        ));
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

class TypeFoodName extends StatefulWidget {
  var controller;
  var foodInfo;
  TypeFoodName({this.controller, this.foodInfo});
  @override
  _TypeFoodName createState() => _TypeFoodName(controller: controller);
}

class _TypeFoodName extends State<TypeFoodName> {
  final FocusNode _focusNode = FocusNode();
  final dbHelper = DBHelperFood();
  var foodList = <Widget>[];
  var foodInfo;
  var controller;

  @override
  void initState() {
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && this._overlayEntry != null) {
        this._overlayEntry.remove();
      }
    });
  }

  OverlayEntry _overlayEntry;
  _TypeFoodName({this.controller, this.foodInfo});

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject();
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);
    print(foodList);
    if (foodList.isNotEmpty) {
      return OverlayEntry(
          builder: (context) => Positioned(
                left: offset.dx,
                top: offset.dy + size.height + 5.0,
                width: size.width,
                child: Material(
                  elevation: 1.0,
                  child: ListView(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      children: foodList),
                ),
              ));
    } else {
      return OverlayEntry(
          builder: (context) => Positioned(
                left: offset.dx,
                top: offset.dy + size.height + 5.0,
                child: Material(
                  elevation: 1.0,
                ),
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: false,
      controller: controller,
      focusNode: _focusNode,
      decoration: const InputDecoration(hintText: 'Type Food Name'),
      textAlign: TextAlign.center,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter info';
        }
        return null;
      },
      onChanged: (text) async {
        if (text != "") {
          await dbHelper.filterFoods(text.toString()).then((value) async {
            foodList = [];
            var i = 0;
            for (var item in value) {
              if (i < 5) {
                foodList.add(ListTile(
                  title: Text(item.foodName),
                  onTap: () {
                    dbHelper.getFood(item.foodName).then((value) {
                      Map foodInfo2 = {};
                      foodInfo2["kcal"] = value.kcal;
                      foodInfo2["carbohydrate"] = value.carbohydrate;
                      foodInfo2["protein"] = value.protein;
                      foodInfo2["fat"] = value.fat;
                      setState(() {
                        foodInfo = foodInfo2;
                        print(foodInfo);
                      });
                    });
                  },
                ));
                i += 1;
              } else {
                break;
              }
            }
          }, onError: (e) {
            print(e);
          });
          _overlayEntry = _createOverlayEntry();
          Overlay.of(context).insert(_overlayEntry);
        }
      },
    );
  }
}
