// import 'package:excel/excel.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
// import 'package:flutter_application_1/addDiet.dart';
// import 'package:flutter_application_1/calculate.dart';
// import 'package:flutter_application_1/savedFood.dart';
import 'appBar.dart';
import 'db_helper.dart';
// import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'dart:async';
import 'model.dart';
import 'mainStream.dart' as mainStream;
import 'package:crypto/crypto.dart';
// import 'package:convert/convert.dart';
import 'dart:convert';
// import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';

GlobalKey<FormState> _formKey = GlobalKey<FormState>();

// StreamController<Map> streamController = StreamController<Map>.broadcast();
// StreamController<bool> streamControllerBool =
//     StreamController<bool>.broadcast();
StreamController<Map> streamController = mainStream.streamController;
StreamController<bool> streamControllerBool = mainStream.streamControllerBool;
bool tempo = false;

class AddFood extends StatefulWidget {
  final Stream<Map> stream;
  Map myTempoFood;
  AddFood({this.stream});

  @override
  _AddFoodState createState() => _AddFoodState();
}

ScrollController _controller;

class _AddFoodState extends State<AddFood> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          currentFocus.unfocus();
          Future.delayed(Duration.zero, () {
            _controller.animateTo(0.0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.fastOutSlowIn);
          });
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
  final _servingController = TextEditingController();
  final _proController = TextEditingController();
  final _fatController = TextEditingController();
  final _ulController = TextEditingController();
  final _foodNameController = TextEditingController();
  final dbHelper = DBHelperFood();
  var foodList = <Widget>[];
  final FocusNode _focusNode = FocusNode();
  var foodInfo = {};
  OverlayEntry _overLayEntry;
  bool isDisposed = true;
  Map foodTempInfo = {};
  String whereFrom;

  @override
  void dispose() {
    _carboController.dispose();
    _proController.dispose();
    _fatController.dispose();
    _ulController.dispose();
    _servingController.dispose();
    _foodNameController.dispose();

    //_purposeController.dispose();
    super.dispose();
    isDisposed = true;
  }

  @override
  Widget build(BuildContext context) {
    // getInfo();
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      // appBar: AppBar(
      //     centerTitle: true, title: Text("ADD FOOD"), actions: <Widget>[]),
      body: Center(
          child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _controller,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 1.1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(
                  flex: 1,
                ),
                searchBar(),
                Spacer(
                  flex: 1,
                ),
                subBuilderQuestion("음식명", " ", controller: _foodNameController),
                subBuilderQuestion("1회 제공량", "g",
                    controller: _servingController),
                subBuilderQuestion("탄수화물", "g", controller: _carboController),
                subBuilderQuestion(
                  "단백질",
                  "g",
                  controller: _proController,
                ),
                subBuilderQuestion("지방", "g",
                    controller: _fatController,
                    icon: Icon(Icons.restaurant_outlined)),
                subBuilderQuestion(
                  "열량",
                  "kcal",
                  controller: _ulController,
                ),
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
          ),
        ),
      )),
      floatingActionButton: add(),
      // floatingActionButton: TransFoodFAB(
      //   stream: widget.streamMap,
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // TransFoodFAB(
      //   stream: widget.streamMap,
      // ),
    );
  }

  void getInfo() async {
    final Map<String, Map> args = ModalRoute.of(context).settings.arguments;

    // print(args['myTempoFood']['servingSize']);
    if (args != null) {
      //searchFood에서 넘겼을때
      whereFrom = "searchFood";
      print("form search food");
      foodInfo = args["myTempoFood"];

      setState(() {
        tempo = true;
        _carboController.text =
            myRounder(foodInfo['servingSize'] * foodInfo['carbohydrate']);
        _fatController.text =
            myRounder(foodInfo['servingSize'] * foodInfo['fat']);
        _proController.text =
            myRounder(foodInfo['servingSize'] * foodInfo['protein']);
        _ulController.text =
            myRounder(foodInfo['servingSize'] * foodInfo['kcal']);
        _servingController.text = myRounder(foodInfo['servingSize']);
        _foodNameController.text = foodInfo['foodName'];
      });
      // //print("this is args $args");
      // streamController.add(foodInfo);
    } else {
      //일반적인 상황
      // foodTempInfo = new Map.from(foodInfo);
      // foodTempInfo['foodName'] = _foodNameController.value.text;
      // foodTempInfo['isItMine'] = "T";
      // foodTempInfo['carbohydrate'] = num.tryParse(_carboController.value.text);
      // foodTempInfo['protein'] = num.tryParse(_proController.value.text);
      // foodTempInfo['fat'] = num.tryParse(_fatController.value.text);
      // foodTempInfo['servingSize'] = num.tryParse(_servingController.value.text);
      // foodInfo.clear();
      setState(() {
        // foodInfo = foodTempInfo;
        tempo = false;
      });
    }
  }

  @override
  void initState() {
    widget.streamMap.listen((info) {
      if (!tempo) {
        if (info.containsKey('fat') == false) {
          info['carbohydrate'] = 0;
          info['fat'] = 0;
          info['protein'] = 0;
          info['kcal'] = 0;
        }
        foodInfo = info;
        mySetState(info);
      }
    });
    widget.streamBool.listen((isItCustom) {
      //print("listen cutom $foodInfo");
      streamController.add(foodInfo);
    });
    _controller = ScrollController();
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    // if (tempo) {}
    print('change');
    getInfo();
    streamController.add(foodInfo);
    // print(foodInfo['foodName']);
    super.didChangeDependencies();
  }

  void mySetState(Map info) {
    if (this.mounted) {
      setState(() {
        try {
          _carboController.text =
              myRounder(foodInfo['servingSize'] * info['carbohydrate']);
          _fatController.text =
              myRounder(foodInfo['servingSize'] * info['fat']);
          _proController.text =
              myRounder(foodInfo['servingSize'] * info['protein']);
          _ulController.text =
              myRounder(foodInfo['servingSize'] * info['kcal']);
          _servingController.text = myRounder(foodInfo['servingSize']);

          _foodNameController.text = foodInfo['foodName'];
        } catch (e) {}
      });
    }
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
          flex: 3,
        ),
        Expanded(
          flex: 4,
          child: Card(
            color: Colors.deepOrangeAccent[400],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: InkWell(
                splashColor: Colors.white,
                focusNode: _focusNode,
                child: AspectRatio(
                  aspectRatio: 20 / 8,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 5),
                          padding: EdgeInsets.all(2),
                          child: Icon(
                            Icons.search,
                            size: 40,
                            // color: Colors.deepOrangeAccent[400],
                          ),
                          decoration: BoxDecoration(
                              color: Colors.deepOrangeAccent[400],
                              shape: BoxShape.circle),
                        ),
                        // SizedBox(
                        //   width: 15,
                        // ),
                        Spacer(),
                        Container(
                          margin: EdgeInsets.only(left: 10, right: 10),
                          padding: EdgeInsets.only(top: 0),
                          child: AutoSizeText(
                            " 불러오기",
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                ),
                // color: Colors.deepOrangeAccent[700],
                onTap: () async {
                  // print(whereFrom);
                  // if (whereFrom == "searchFood") {
                  //   Navigator.pop(context, {"pre": "addFood"});
                  //   // Navigator.pop(context);
                  // } else {

                  // await dbHelper.initDB().then((_){
                  //   print("finisj");
                  // });

                  Navigator.popAndPushNamed(context, '/searchFood',
                          arguments: <String, String>{'pre': 'addFood'})
                      .then((code) async {
                    await dbHelper.getFood(code).then((food) {
                      streamController.add(food.toMap());
                    });
                  });
                }),
          ),
          /* TypeFoodName(
              controller: _foodNameController,
              streamBool: widget.streamBool,
            ) */
        ),
        Spacer(
          flex: 3,
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
            // Spacer(),
            Expanded(flex: 5, child: questionForm(controller, value, question)),
            Spacer(),
            spacer_unit(unit),
            Spacer(
              flex: 2,
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
      case "1회 제공량":
        returnValue = "servingSize";
        break;
      case "음식명":
        returnValue = "foodName";
        break;
      default:
    }
    return returnValue;
  }

  Widget questionForm(
      TextEditingController controller, num value, String question) {
    //print(foodInfo);
    String fieldName = koreanQusetionToEnglish(question);
    // bool enable =
    //     fieldName == "servingSize" || fieldName == "foodName" ? false : true;

    return TextFormField(
      autofocus: false,
      controller: controller,
      // focusNode: _focusNode,
      enabled: true,
      keyboardType:
          fieldName == "foodName" ? TextInputType.text : TextInputType.number,
      decoration: InputDecoration(hintText: ''),
      textAlign: TextAlign.center,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter info';
        }
        return null;
      },
      onEditingComplete: () {
        Future.delayed(Duration.zero, () {
          _controller.animateTo(_controller.offset - 500,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut);
          FocusScope.of(context).unfocus();
        });
      },
      onTap: () {
        Future.delayed(Duration.zero, () {
          _controller.animateTo(_controller.offset + 500,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut);
        });
      },
      onChanged: (text) {
        if (fieldName != "foodName") {
          foodInfo[fieldName] = double.parse(text) / foodInfo['servingSize'];
        }
        //   if (fieldName == 'servingSize') {
        //     setState(() {
        //       foodInfo[fieldName] = double.parse(text);
        //     });
        //   } else {
        //     setState(() {
        //       foodInfo[fieldName] =
        //           double.parse(text) / foodInfo['servingSize'];
        //     });
        //   }
        //   // streamController.add(foodInfo);
        // } else {
        //   setState(() {
        //     foodInfo[fieldName] = text;
        //   });
        // }
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
          child: AutoSizeText(
            question,
            maxLines: 1,
            maxFontSize: 20,
            style: TextStyle(fontSize: 16),
          ),
        ));
  }

  Widget spacer_unit(var unit) {
    return Expanded(
        flex: 1,
        child: Center(
          child: AutoSizeText(
            unit,
            maxLines: 1,
            maxFontSize: 20,
            style: TextStyle(fontSize: 16),
          ),
        ));
  }

  Food foodClass;

  Widget add() {
    return Container(
      // color: Colors.deepOrangeAccent[700],
      child: FloatingActionButton(
        backgroundColor: Colors.deepOrangeAccent[400],
        onPressed: () async {
          if (_formKey.currentState.validate()) {
            num serve = double.parse(_servingController.value.text);
            foodClass = Food(
                code: foodInfo['code'],
                dbArmy: foodInfo['dbArmy'],
                foodName: _foodNameController.text,
                foodKinds: foodInfo['foodKinds'],
                kcal: double.parse(_ulController.value.text) / serve,
                protein: double.parse(_proController.value.text) / serve,
                carbohydrate: double.parse(_carboController.value.text) / serve,
                fat: double.parse(_fatController.value.text) / serve,
                isItMine: 'T',
                selected: foodInfo['selected'],
                servingSize: serve);
            //일반적 상황
            if (foodInfo['code'] == null) {
              foodClass.selected = 0;
              showAlertDialog(context);
            } else {
              //업데이트 혹은 하나 더 저장
              duplicateAlertDialog(context);
            }
          }
        },
        tooltip: '저장',
        child: Icon(
          Icons.add,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }

  //searchFood에서 왔을때
  duplicateAlertDialog(BuildContext context) {
    // set up the button
    Widget saveButton = FlatButton(
        child: Text("새로 저장"),
        onPressed: () async {
          var bytes = utf8.encode(_foodNameController.text);
          String codeName =
              "MY" + md5.convert(bytes).toString() + DateTime.now().toString();
          foodClass.code = codeName;
          foodClass.selected = 0;

          await dbHelper.createData(foodClass);
          Navigator.pop(context);
        });

    Widget updateButton = FlatButton(
        child: Text("업데이트"),
        onPressed: () async {
          await dbHelper.updateFood(foodClass);
          Navigator.pop(context);
        });

    Widget noButton = FlatButton(
      child: Text("취소"),
      onPressed: () {
        foodClass = Food();
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("음식 저장/수정"),
      content: Text("새 음식을 저장하시려면 새로 저장,\n\n기존 데이터를 수정하시려면 업데이트를 눌러주세요"),
      actions: [saveButton, updateButton, noButton],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  //그냥 왔을 때
  showAlertDialog(BuildContext context) {
    // set up the button
    Widget saveButton = FlatButton(
        child: Text("저장"),
        onPressed: () async {
          var bytes = utf8.encode(_foodNameController.value.text);
          String codeName =
              "MY" + md5.convert(bytes).toString() + DateTime.now().toString();
          foodClass.code = codeName;

          // print(foodClass.code);
          await dbHelper.createData(foodClass);

          Navigator.pop(context);
        });

    Widget noButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        foodClass = Food();
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("General"),
      content: Text("저장하시겠습니까?"),
      actions: [saveButton, noButton],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

/* 
//입력 버튼
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
  _TypeFoodName({this.controller});
  bool isItCutom = false;
  bool isItSelected = false;
  bool favorite = false;

  @override
  void initState() {
    widget.streamBool.listen((isItCustom) {
      setState(() {
        isItCutom = isItCustom;
        isItSelected = false;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      // autofocus: false,
      // keyboardType: null,
      // enabled: !isItSelected,
      // controller: controller,
      focusNode: _focusNode,
      child: Text("저장된 음식 불러오기"),
      // decoration: const InputDecoration(hintText: 'Type Food Name'),
      // textAlign: TextAlign.center,
      // validator: (value) {
      //   if (value.isEmpty) {
      //     return 'Please enter info';
      //   }
      //   return null;
      // },
      color: Colors.deepOrangeAccent[700],
      onPressed: () {
        Navigator.pushNamed(context, '/searchFood',
            arguments: <String, String>{'pre': 'addFood'}).then((code) async {
          await dbHelper.getFood(code).then((food) {
            streamController.add(food.toMap());
          });
        });
      },
      /* onChanged: (text) async {
        if (isItCutom) {
          //작동 X
        } else {
          //text = 바뀐 글
          if (text != "") {
            await dbHelper.filterFoods(text.toString()).then((value) async {
              foodList = [];
              List<int> foodListIndex = [];
              List<Food> favoriteFood = [];
              List<Food> notFavoriteFood = [];

              var i = 0;
              favoriteFood
                  .addAll(value.where((item) => item.isItMine == "T"));
              notFavoriteFood
                  .addAll(value.where((item) => item.isItMine == "F"));
              for (var item in favoriteFood) {
                foodListIndex.add(item.selected);
                foodListIndex.sort((b, a) => a.compareTo(b));
                var index = foodListIndex.indexOf(item.selected);

                foodList.insert(
                    index,
                    ListTile(
                      title: Text(item.foodName),
                      leading: Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 20,
                      ),
                      trailing: Text("${item.selected}"),
                      subtitle: Text(
                          "${myRounder(item.kcal * item.servingSize)} Kcal"),
                      onTap: () {
                        Map foodInfo = {};
                        controller.text = item.foodName;
                        foodInfo = item.toMap();

                        streamController.add(foodInfo);
                        foodList = [];
                      },
                    ));
              }
              for (var item in notFavoriteFood) {
                if (i < 5 - favoriteFood.length) {
                  foodList.add(ListTile(
                    title: Text(item.foodName),
                    leading: Icon(
                      Icons.favorite,
                      size: 20,
                    ),
                    trailing: Text("${item.selected}"),
                    subtitle: Text(
                        "${myRounder(item.kcal * item.servingSize)} Kcal"),
                    onTap: () {
                      Map foodInfo = {};
                      controller.text = item.foodName;
                      foodInfo = item.toMap();
                      streamController.add(foodInfo);
                      foodList = [];
                    },
                  ));
                  i += 1;
                } else {
                  break;
                }
              }
            }, onError: (e) {
              //print(e);
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
                });
              },
            ));
          }
        }
      } */
    );
  }
} */

//FAB
/* class TransFoodFAB extends StatefulWidget {
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
  Food returnFood = Food();
  String returnCode;

  @override
  initState() {
    myFoodInfo = {};
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
            // begin: Colors.deepOrangeAccent,
            // end: Colors.orange[300],
            )
        .animate(CurvedAnimation(
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
      //print("==========================");
      //print(foodInfo);
      myFoodInfo = foodInfo;
      //print("this is myFoodinfo1 $myFoodInfo");
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

  //db 읽어오는거(필요없음)
  Widget add() {
    return Container(
      child: FloatingActionButton(
        heroTag: null,
        onPressed: () async {
          print("start");

          final dbHelper = DBHelperFood();
          ByteData data = await rootBundle.load("assets/foodNutriData.xlsx");
          List<int> bytes =
              data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
          await dbHelper.deleteAllFood();
          var excel = Excel.decodeBytes(bytes);
          print("start");
          for (var table in excel.tables.keys) {
            for (var row in excel.tables[table].rows) {
              // //print(row);
              var food = Food(
                  code: row[0],
                  dbArmy: row[1],
                  foodName: row[2],
                  foodKinds: row[3],
                  kcal: row[4],
                  carbohydrate: row[5],
                  protein: row[6],
                  fat: row[7],
                  isItMine: 'F',
                  selected: 0,
                  servingSize: row[8]);

              await dbHelper.createData(food);
            }
          }
          print("finish");
        },
        tooltip: 'Add',
        child: Icon(Icons.add, size: 30),
        // backgroundColor: Colors.deepOrangeAccent,
      ),
    );
  }

  Widget search() {
    return Container(
      child: FloatingActionButton(
        heroTag: null,

        onPressed: () async {
          if (_formKey.currentState.validate()) {
            if (tempo) {
              //커스텀: 코드 새로만들어서 저장
              // var bytes = utf8.encode();
              //          returnFood = Food(
              //             code: ,
              //   dbArmy: ,
              //   foodName: ,
              //   foodKinds: ,
              // kcal: ,
              // protein: ,
              // carbohydrate: ,
              // fat: ,
              // isItMine: ,
              // selected: ,
              // servingSize:
              //         );

              // await streamControllerBool.add(isItCutom);
            } else {
              //업데이트 혹은 하나 더 저장
            }

            print(myFoodInfo);
            showAlertDialog(context);
          }
        },
        tooltip: 'Search',
        child: Icon(Icons.search, size: 30),
        // backgroundColor: Colors.deepOrangeAccent,
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
          //print("this is myFoodinfo2 $myFoodInfo");

          print(myFoodInfo);

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
              selected: myFoodInfo['selected'] == null
                  ? 1
                  : myFoodInfo['selected'] + 1,
              servingSize: myFoodInfo['servingSize']);
          await dbHelperFood.updateFood(foodClass);
          Navigator.pop(context);

          /* await dbHelperFood.getFood(myFoodInfo['code']).then((value) async {
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
                selected: myFoodInfo['selected'] + 1,
                servingSize: myFoodInfo['servingSize']); //select 1회 증가

            dbHelperFood.deleteFood(myFoodInfo['code']);

            if (myFoodInfo['isItMine'] == 'T') {
              await dbHelperFood
                  .createData(foodClass); //myFoodInfo에 저장된 데이터로 새로 저장
              //print("new food ${foodClass.toMap()}");
              Navigator.pop(context);
            } else {
              var bytes = utf8.encode(myFoodInfo['foodName']);
              String codeName = "MY" + md5.convert(bytes).toString();
              //print(codeName); //코드네임 암호화
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
          });*/
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
 */
