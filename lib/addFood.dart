import 'package:flutter/material.dart';
import 'package:flutter_application_1/savedFood.dart';
import 'appBar.dart';
import 'db_helper.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'dart:async';
import 'foodFloatAction.dart';

StreamController<Map> streamController = StreamController<Map>.broadcast();

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
        child: AddFoodSub(stream: streamController.stream));
  }
}

class AddFoodSub extends StatefulWidget {
  final Stream<Map> stream;
  AddFoodSub({this.stream});
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var foodList = <Widget>[];
  final FocusNode _focusNode = FocusNode();
  OverlayEntry _overLayEntry;

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
        floatingActionButton: TransFoodFAB());
  }

  @override
  void initState() {
    super.initState();
    widget.stream.listen((foodInfo) {
      mySetState(foodInfo);
    });
  }

  void mySetState(Map foodInfo) {
    setState(() {
      _carboController.text = myRounder(foodInfo['carbohydrate']);
      _fatController.text = myRounder(foodInfo['fat']);
      _proController.text = myRounder(foodInfo['protein']);
      _ulController.text = myRounder(foodInfo['kcal']);
    });
  }

  String myRounder(num a) {
    return a.toString().length < 5
        ? a.toString()
        : a.toString().substring(0, 6);
  }

  Widget searchBar() {
    return Center(
        child: Row(
      children: [
        Spacer(
          flex: 1,
        ),
        Expanded(flex: 2, child: TypeFoodName(controller: _foodNameController)),
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
      decoration: InputDecoration(hintText: ''),
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

class TypeFoodName extends StatefulWidget {
  var controller;

  TypeFoodName({this.controller});
  @override
  _TypeFoodName createState() => _TypeFoodName(controller: controller);
}

class _TypeFoodName extends State<TypeFoodName> {
  final FocusNode _focusNode = FocusNode();
  final dbHelper = DBHelperFood();
  var foodList = <Widget>[];
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
  _TypeFoodName({this.controller});

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
        //text = 바뀐 글
        if (text != "") {
          await dbHelper.filterFoods(text.toString()).then((value) async {
            foodList = [];
            var i = 0;
            for (var item in value) {
              if (i < 10) {
                foodList.add(ListTile(
                  title: Text(item.foodName),
                  subtitle: Text("${item.kcal}Kcal"),
                  onTap: () {
                    Map foodInfo = {};
                    controller.text = item.foodName;
                    foodInfo['kcal'] = item.kcal;
                    foodInfo['carbohydrate'] = item.carbohydrate;
                    foodInfo['protein'] = item.protein;
                    foodInfo['fat'] = item.fat;
                    foodInfo['code'] = item.code;
                    streamController.add(foodInfo);
                    _overlayEntry.remove();
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
          _overlayEntry = _createOverlayEntry();
          Overlay.of(context).insert(_overlayEntry);
        }
      },
    );
  }
}
