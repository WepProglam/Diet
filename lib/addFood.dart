import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/savedFood.dart';
import 'appBar.dart';
import 'db_helper.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'dart:async';
import 'model.dart';
import 'mainStream.dart' as mainStream;
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';
import 'dart:convert';

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

// StreamController<Map> streamController = StreamController<Map>.broadcast();
// StreamController<bool> streamControllerBool =
//     StreamController<bool>.broadcast();
StreamController<Map> streamController = mainStream.streamController;
StreamController<bool> streamControllerBool = mainStream.streamControllerBool;

class AddFood extends StatefulWidget {
  final Stream<Map> stream;
  AddFood({this.stream});
  @override
  _AddFoodState createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          currentFocus.unfocus();
        },
        child: AddFoodSub(
          streamMap: streamController.stream,
          streamBool: streamControllerBool.stream,
        ));
  }
}

class AddFoodSub extends StatefulWidget {
  final Stream<Map> streamMap;
  final Stream<bool> streamBool;
  AddFoodSub({this.streamMap, this.streamBool});
  @override
  _AddFoodSub createState() => _AddFoodSub();
}

class _AddFoodSub extends State<AddFoodSub> {
  final _carboController = TextEditingController();
  final _proController = TextEditingController();
  final _fatController = TextEditingController();
  final _ulController = TextEditingController();
  final _foodNameController = TextEditingController();
  final dbHelper = DBHelperFood();
  final dBHelperMyTempoFood = DBHelperMyTempoFood();
  var foodList = <Widget>[];
  final FocusNode _focusNode = FocusNode();
  var foodInfo = {};
  OverlayEntry _overLayEntry;
  bool isDisposed = true;
  Map foodTempInfo = {};
  bool tempo = false;

  @override
  void dispose() {
    _carboController.dispose();
    _proController.dispose();
    _fatController.dispose();
    _ulController.dispose();
    //_purposeController.dispose();
    super.dispose();
    isDisposed = true;
  }

  @override
  Widget build(BuildContext context) {
    getInfo();
    return Scaffold(
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
              searchBar(),
              Spacer(
                flex: 1,
              ),
              subBuilderQuestion("탄수화물", "g",
                  controller: _carboController, icon: Icon(Icons.favorite)),
              subBuilderQuestion("단백질", "g",
                  controller: _proController,
                  icon: Icon(Icons.restaurant_menu_outlined)),
              subBuilderQuestion("지방", "g",
                  controller: _fatController,
                  icon: Icon(Icons.restaurant_outlined)),
              subBuilderQuestion("열량", "kcal",
                  controller: _ulController,
                  icon: Icon(Icons.restaurant_menu_sharp)),
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
        floatingActionButton: TransFoodFAB(
          stream: widget.streamMap,
        ));
  }

  void getInfo() async {
    //여기 문제 있음
    await dBHelperMyTempoFood.getAllFood().then((value) {
      print("get info");
      print(value.length > 0);
      if (value.length > 0) {
        foodInfo = value[0].toMap();
        tempo = true;
        dBHelperMyTempoFood.deleteAllFood();
        setState(() {
          _carboController.text = myRounder(foodInfo['carbohydrate']);
          _fatController.text = myRounder(foodInfo['fat']);
          _proController.text = myRounder(foodInfo['protein']);
          _ulController.text = myRounder(foodInfo['kcal']);
          _foodNameController.text = foodInfo['foodName'];
        });
      } else {
        tempo = false;
      }
    });
  }

  @override
  void initState() {
    widget.streamMap.listen((info) {
      print(info.containsKey('fat'));
      if (info.containsKey('fat') == false) {
        info['carbohydrate'] = 0.0;
        info['fat'] = 0.0;
        info['protein'] = 0.0;
        info['kcal'] = 0.0;
      }
      foodInfo = info;
      mySetState(info);
    });
    widget.streamBool.listen((isItCustom) {
      streamController.add(foodInfo);
    });
    super.initState();
  }

  void mySetState(Map info) {
    setState(() {
      _carboController.text = myRounder(info['carbohydrate']);
      _fatController.text = myRounder(info['fat']);
      _proController.text = myRounder(info['protein']);
      _ulController.text = myRounder(info['kcal']);
    });
    foodInfo = info;
  }

  String myRounder(num a) {
    return a.toString().length < 5
        ? a.toString()
        : a.toString().substring(0, 5);
  }

  Widget searchBar() {
    return Center(
        child: Row(
      children: [
        Spacer(
          flex: 1,
        ),
        Expanded(
            flex: 2,
            child: TypeFoodName(
              controller: _foodNameController,
              streamBool: widget.streamBool,
            )),
        Spacer(
          flex: 1,
        )
      ],
    ));
  }

  Widget subBuilderQuestion(var question, var unit,
      {var controller, var icon, num value}) {
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
            Expanded(flex: 6, child: questionForm(controller, value, question)),
            spacer_unit(unit),
            Spacer(
              flex: 1,
            ),
          ],
        )));
  }

  String koreanQusetionToEnglish(String question) {
    String returnValue;
    switch (question) {
      case "탄수화물":
        returnValue = "carbohydrate";
        break;
      case "단백질":
        returnValue = "protein";
        break;
      case "지방":
        returnValue = "fat";
        break;
      case "열량":
        returnValue = "kcal";
        break;
      default:
    }
    return returnValue;
  }

  Widget questionForm(
      TextEditingController controller, num value, String question) {
    print(foodInfo);
    String fieldName = koreanQusetionToEnglish(question);
    return TextFormField(
      autofocus: false,
      controller: controller,
      // focusNode: _focusNode,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(hintText: ''),
      textAlign: TextAlign.center,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter info';
        }
        return null;
      },
      onChanged: (text) {
        foodInfo[fieldName] = double.parse(text);
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

class TypeFoodName extends StatefulWidget {
  var controller;
  final Stream<bool> streamBool;

  TypeFoodName({this.controller, this.streamBool});
  @override
  _TypeFoodName createState() => _TypeFoodName(controller: controller);
}

class _TypeFoodName extends State<TypeFoodName> {
  final FocusNode _focusNode = FocusNode();
  final dbHelper = DBHelperFood();
  var foodList = <Widget>[];
  var controller;
  OverlayEntry _overlayEntry;
  _TypeFoodName({this.controller});
  bool isItCutom = false;
  bool isItSelected = false;

  @override
  void initState() {
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        this._overlayEntry.remove();
      }
    });
    widget.streamBool.listen((isItCustom) {
      setState(() {
        isItCutom = isItCustom;
        isItSelected = false;
      });
    });

    super.initState();
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject();
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

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
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        // autofocus: false,
        enabled: !isItSelected,
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
          if (isItCutom) {
            //작동 X
          } else {
            if (this._overlayEntry != null) {
              this._overlayEntry = null;
            }
            //text = 바뀐 글
            if (text != "") {
              await dbHelper.filterFoods(text.toString()).then((value) async {
                foodList = [];
                var i = 0;
                for (var item in value) {
                  if (i < 5) {
                    foodList.add(ListTile(
                      title: Text(item.foodName),
                      subtitle: Text("${item.kcal}Kcal  ${item.isItMine}"),
                      onTap: () {
                        Map foodInfo = {};
                        controller.text = item.foodName;
                        foodInfo = item.toMap();
                        setState(() {
                          isItSelected = true;
                        });

                        streamController.add(foodInfo);
                        _focusNode.unfocus();
                        foodList = [];
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

              foodList.add(ListTile(
                title: Text("나만의 음식 추가"),
                onTap: () {
                  _focusNode.unfocus();
                  foodList = [];
                  Map foodInfo = {};
                  foodInfo['foodName'] = controller.text;
                  streamController.add(foodInfo);
                  setState(() {
                    isItCutom = true;
                    isItSelected = true;
                  });
                },
              ));
              this._overlayEntry = _createOverlayEntry();
              Overlay.of(context).insert(this._overlayEntry);
            }
          }
        });
  }
}

class TransFoodFAB extends StatefulWidget {
  final Function() onPressed;
  final String tooltip;
  final IconData icon;
  final Stream<Map> stream;

  TransFoodFAB({this.onPressed, this.tooltip, this.icon, this.stream});

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
  final dbHelperFood = DBHelperFood();
  double _fabHeight = 56.0;
  Map myFoodInfo = {};
  bool isItCutom = false;

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

    widget.stream.listen((foodInfo) {
      myFoodInfo = foodInfo;
    });

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
          await dbHelper.deleteAllFood();
          var excel = Excel.decodeBytes(bytes);
          print("start");
          for (var table in excel.tables.keys) {
            for (var row in excel.tables[table].rows) {
              // print(row);
              var food = Food(
                  code: row[0],
                  dbArmy: row[1],
                  foodName: row[2],
                  foodKinds: row[3],
                  kcal: row[4],
                  protein: row[5],
                  carbohydrate: row[6],
                  fat: row[7],
                  isItMine: 'F',
                  selected: 0);

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
        onPressed: () async {
          print("myfoodinfo = $myFoodInfo");
          if (_formKey.currentState.validate()) {
            showAlertDialog(context);
          }
        },
        tooltip: 'Search',
        child: Icon(Icons.search, size: 30),
        backgroundColor: Colors.black45,
      ),
    );
  }

  duplicateAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = FlatButton(
        child: Text("OK"),
        onPressed: () {
          Navigator.pop(context);
        });

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("음식 수정 시에는 저장된 음식을 수정해주세요"),
      content: Text(""),
      actions: [okButton],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = FlatButton(
        child: Text("OK"),
        onPressed: () async {
          await dbHelperFood.getFood(myFoodInfo['code']).then((value) async {
            Food dbFoodClass = value;
            dbFoodClass.selected += 1;
            Food foodClass = Food(
                code: myFoodInfo['code'],
                dbArmy: myFoodInfo['dbArmy'],
                foodName: myFoodInfo['foodName'],
                foodKinds: myFoodInfo['foodKinds'],
                kcal: myFoodInfo['kcal'],
                protein: myFoodInfo['protein'],
                carbohydrate: myFoodInfo['carbohydrate'],
                fat: myFoodInfo['fat'],
                isItMine: 'T',
                selected: myFoodInfo['selected'] + 1); //select 1회 증가

            dbHelperFood.deleteFood(myFoodInfo['code']);

            if (myFoodInfo['isItMine'] == 'T') {
              await dbHelperFood
                  .createData(foodClass); //myFoodInfo에 저장된 데이터로 새로 저장
              Navigator.pop(context);
            } else {
              var bytes = utf8.encode(myFoodInfo['foodName']);
              String codeName = "MY" + md5.convert(bytes).toString();
              print(codeName); //코드네임 암호화
              await dbHelperFood
                  .createData(dbFoodClass); //기존 db 데이터 저장(선택횟수만 변경)
              await dbHelperFood.getFood(codeName).then((value) async {
                if (value is Food) {
                  Navigator.pop(context);
                  duplicateAlertDialog(context);
                } else {
                  foodClass.code = codeName;
                  dbHelperFood.createData(foodClass); //새로 저장하는 myfood 데이터
                  Navigator.pop(context);
                }
              });
            }
            streamControllerBool.add(isItCutom);
          });
        });

    Widget noButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("음식 저장"),
      content: Text("저장하시겠습니까?"),
      actions: [okButton, noButton],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
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
