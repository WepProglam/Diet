import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/dietModelSaver.dart';
import 'package:flutter_application_1/mainPage.dart';
import 'package:flutter_application_1/model.dart';
import 'package:intl/intl.dart';
import 'appBar.dart';
import 'db_helper.dart';
import 'piChart.dart';
import 'calculate.dart';

Color listViewColor = Colors.deepOrangeAccent;
Color iconColor = Colors.deepOrangeAccent[400];
double _currentSliderValue = 0;
double rangeSliderMaxValue = 100;
Person person;

final dbHelperFood = DBHelperFood();

var filterColor = Colors.deepOrangeAccent[700];

class AddDiet extends StatelessWidget {
  const AddDiet({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xFFFFFEF5),
      appBar: AppBar(
          centerTitle: true, title: Text("ADD DIET"), actions: <Widget>[]),
      body: FoodList(),
    );
  }
}

class ListContents {
  String foodName;
  String code;
  dynamic mass;

  ListContents({this.foodName, this.code, this.mass});
}

class FoodList extends StatefulWidget {
  FoodList({Key key}) : super(key: key);

  @override
  _FoodListState createState() => _FoodListState();
}

class _FoodListState extends State<FoodList> {
  List<ListContents> foodList = [];
  final dbHelperDiet = DBHelperDiet();
  TextEditingController dietNameController = TextEditingController();
  List<TextEditingController> foodMassController = [];
  List<TextEditingController> foodServingController = [];
  List<bool> pinPushedList = [];
  num carbohydrateMass, proteinMass, fatMass = 0.0;
  num totalCalorie;
  num correct = 0.0;
  bool isGraphShowed = false;
  var dietInfo = {};
  List<num> massChangeList = [];
  List<num> changeList = [];
  String whereFrom;
  int mainPageIndex;
  String dateTimeInfo;

  @override
  void initState() {
    carbohydrateMass = 0.0;
    proteinMass = 0.0;
    fatMass = 0.0;
    totalCalorie = 0.0;
    correct = 0.0;

    super.initState();
  }

  @override
  void dispose() {
    for (var controller in foodMassController) {
      controller.dispose();
    }
    for (var controller in foodServingController) {
      controller.dispose();
    }
    super.dispose();
  }

  void addItem(List<ListContents> food) {
    setState(() {
      foodList += food;
    });
  }

  void getHowMuchPercentLeft(String dateInfo) async {
    num todaykcal = 0.0;
    String now = DateTime.now().toString().substring(0, 10);
    Map todayDietInfo = {};
    String calender_year = dateInfo.split("-")[0];
    String calender_month = dateInfo.split("-")[1];
    String calender_date = dateInfo.split("-")[2];
    String dateTime;
    if (calender_month.length == 1 && calender_date.length == 1) {
      dateTime = "$calender_year-0$calender_month-0$calender_date";
    } else if (calender_month.length != 1 && calender_date.length == 1) {
      dateTime = "$calender_year-$calender_month-0$calender_date";
    } else if (calender_month.length == 1 && calender_date.length != 1) {
      dateTime = "$calender_year-0$calender_month-$calender_date";
    } else {
      dateTime = "$calender_year-$calender_month-$calender_date";
    }

    await dbHelperPerson.getPerson(dateTime).then((val) async {
      if (val != null) {
        person = val;
      } else {
        await dbHelperPerson.getLastPerson().then((value) {
          person = value;
        });
      }
    });

    await dbHelperDietHistory.getDietHistory(dateTime).then((val) {
      if (val != null) {
        todayDietInfo["b"] =
            val.breakFast != "null" ? jsonDecode(val.breakFast) : null;
        todayDietInfo["l"] = val.lunch != "null" ? jsonDecode(val.lunch) : null;
        todayDietInfo["d"] =
            val.dinner != "null" ? jsonDecode(val.dinner) : null;
        todayDietInfo["s"] = val.snack != "null" ? jsonDecode(val.snack) : null;
      }
    });

    var keys = todayDietInfo.keys;
    for (var item in keys) {
      if (todayDietInfo[item] != null) {
        if (todayDietInfo[item]["isItConfirm"] == "true") {
          todaykcal += num.parse(todayDietInfo[item]["kcal"]);
        }
      }
    }

    // print("today kcal = $todaykcal");

    rangeSliderMaxValue = ((1 - todaykcal / person.metabolism) * 100);
    // print("1-${todaykcal}/ ${person.metabolism}= ${rangeSliderMaxValue / 100}");

    // print("this is rangeslider max value = $rangeSliderMaxValue");
  }

  String initialVal(num mass) {
    if (mass == null || mass == 0) {
      return '';
    } else {
      return '$mass';
    }
  }

  List<num> passDefaultFoodList() {
    List<num> defaultFoods = [];
    for (var i = 0; i < pinPushedList.length; i++) {
      if (pinPushedList[i]) {
        defaultFoods.add(num.parse(foodMassController[i].value.text));
      }
    }

    return defaultFoods;
  }

  Widget buildFood(ListContents food, int index) {
    TextEditingController _controller = TextEditingController();
    TextEditingController _controllerServing = TextEditingController();
    bool pinPushed = false;

    _controller.text = initialVal(food.mass);
    _controllerServing.text = initialVal(0);

    if (index >= foodMassController.length) {
      foodMassController.add(_controller);
    }

    if (index >= foodServingController.length) {
      foodServingController.add(_controllerServing);
    }
    if (index >= pinPushedList.length) {
      pinPushedList.add(pinPushed);
    }
    //받는 매게변수 index 추가
    return Center(
      child: Row(
        children: [
          // Spacer(
          //   flex: 1,
          // ),
          Expanded(
            flex: 1,
            child: Material(
              color: Colors.black,
              child: InkWell(
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Ink(
                    child: Icon(
                      Icons.push_pin,
                      color: pinPushedList[index] ? iconColor : Colors.grey,
                    ),
                  ),
                ),
                onTap: () {
                  ListContents temp = foodList[index];
                  bool tempBool = pinPushedList[index];
                  TextEditingController _controller = foodMassController[index];
                  TextEditingController _controllerServing =
                      foodServingController[index];
                  foodList.removeAt(index);
                  pinPushedList.removeAt(index);
                  foodMassController.removeAt(index);
                  foodServingController.removeAt(index);
                  if (tempBool) {
                    tempBool = !tempBool;
                    setState(() {
                      foodList.add(temp);

                      pinPushedList.add(tempBool);

                      foodMassController.add(_controller);

                      foodServingController.add(_controllerServing);
                      // foodList.insert(index, temp);
                    });
                  } else {
                    setState(() {
                      tempBool = !tempBool;

                      foodList.insert(0, temp);

                      pinPushedList.insert(0, tempBool);

                      foodMassController.insert(0, _controller);

                      foodServingController.insert(0, _controllerServing);
                      // foodList.insert(index, temp);
                    });
                  }
                },
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: Text('${food.foodName}'),
            ),
          ),
          Expanded(
            flex: 2,
            child: TextFormField(
              // initialValue: initialVal(food.mass),
              controller: foodServingController[index],
              decoration: InputDecoration(hintText: '인분'),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              enabled: false,
            ),
          ),
          Expanded(
            flex: 2,
            child: TextFormField(
              // initialValue: initialVal(food.mass),
              controller: foodMassController[index],
              decoration: InputDecoration(hintText: 'mass'),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,

              onChanged: (text) async {
                massChangeList = List(foodMassController.length);
                int length = foodMassController.length;

                List<int> index2 = getIndex();
                for (var item in index2) {
                  massChangeList[item] =
                      num.tryParse(foodMassController[item].value.text);
                }
                // massChangeList[index] =
                //     num.tryParse(foodMassController[index].value.text);
                List<num> servingSize = List(foodList.length);

                // for (var item in index) {
                //   await dbHelperFood.getFood(foodList[item].code).then((val) {
                //     print(val.servingSize);
                //     servingSize[item] = (val.servingSize);
                //   });
                // }
                await dbHelperFood.getFood(foodList[index].code).then((val) {
                  print(val.servingSize);
                  servingSize[index] = (val.servingSize);
                });

                // for (var item in index) {
                //   foodServingController[item].text =
                //       (num.tryParse(foodMassController[item].value.text) /
                //               servingSize[item])
                //           .toString();
                // }

                foodServingController[index].text =
                    (num.tryParse(foodMassController[index].value.text) /
                                servingSize[index])
                            .toStringAsFixed(1) +
                        "인분";

                justCalNutri(foodList, massChangeList).then((val) {
                  print(val);
                  setState(() {
                    carbohydrateMass = val[0];
                    proteinMass = val[1];
                    fatMass = val[2];
                  });
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text('g'),
          ),
          Expanded(
            flex: 1,
            child: Material(
              color: Colors.black,
              child: InkWell(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Ink(
                    child: Icon(
                      Icons.cancel,
                      color: iconColor,
                    ),
                  ),
                ),
                onTap: () {
                  setState(() {
                    foodList.removeAt(index);
                    foodMassController.removeAt(index);
                    // for (var item in foodMassController) {
                    //   item.text = "";
                    // }
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  //음식 추가하는거임
  _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push는 Future를 반환합니다. Future는 선택 창에서
    // Navigator.pop이 호출된 이후 완료될 것입니다.
    List<ListContents> foods = [];
    final result = await Navigator.pushNamed(
      context,
      '/searchFood',
      arguments: <String, String>{
        'pre': 'addDiet',
      },
    );
    for (var code in result) {
      Food food = await DBHelperFood().getFood(code);
      ListContents foodCopy = ListContents(
        foodName: food.foodName,
        code: food.code,
        mass: 0,
      );
      foods.add(foodCopy);
    }
    addItem(foods);
  }

  //경고창
  Widget buildSnackBar(String str) {
    return SnackBar(
      content: Text(str),
      duration: const Duration(milliseconds: 800),
      // action: SnackBarAction(
      //   label: 'Undo',
      //   onPressed: () {
      //     // Some code to undo the change.
      //   },
      // ),
    );
  }

  int numOfMass(List<ListContents> list) {
    int n = 0;
    for (var item in list) {
      if (item.mass == 0 || item.mass == null) {
        n++;
      }
    }

    return n;
  }

  List<int> getIndex() {
    //텍스트필드 중 값이 채워진 인덱스 리스트 반환
    List<int> n = [];
    var k = 0;
    for (var item in foodMassController) {
      dynamic j = num.tryParse(item.value.text);
      if (j != null) {
        if (j != 0) {
          n.add(k);
        }
      }
      k += 1;
    }

    return n;
  }

  int changeNumOfMass() {
    int n = 0;
    for (var item in foodMassController) {
      dynamic j = num.tryParse(item.value.text);
      if (j != null) {
        // if (j != 0) {

        n++;
        // }
      }
    }

    return n;
  }

  int otherNumOfMass(List<TextEditingController> foodMassController) {
    int n = 0;
    for (var item in foodMassController) {
      var text = item.value.text;
      num value = num.tryParse(text);
      if (value == null) {
        n += 1;
      }
    }

    return n;
  }

  @override
  void didChangeDependencies() async {
    final Map<String, Map> args = ModalRoute.of(context).settings.arguments;
    if (args == null) {
      whereFrom = null;
    } else if (args.containsKey('pre')) {
      if (args['pre']['pre'] == "mainPage") {
        whereFrom = "mainPage";
        mainPageIndex = args['pre']['index'];
        dateTimeInfo = args['pre']['dateTime'];
        getHowMuchPercentLeft(dateTimeInfo);
      } else if (args['pre']['pre'] == "searchDiet") {
        dietInfo = args["myTempoDiet"];
        String dietName = dietInfo['dietName'];

        Map foodInfo = jsonDecode(dietInfo['foodInfo']);

        for (var item in foodInfo['foods']) {
          changeList.add(item['foodMass']);
          foodList.add(ListContents(
              foodName: item['foodName'],
              code: item['code'],
              mass: item['foodMass']));
        }

        List<num> tempVal;

        await justCalNutri(foodList, changeList).then((val) {
          tempVal = val;
        });
        try {
          setState(() {
            carbohydrateMass = tempVal[0];
            proteinMass = tempVal[1];
            fatMass = tempVal[2];
            dietNameController.text = dietInfo['dietName'];
          });
        } catch (e) {}

        whereFrom = "searchDietMainPage";
        mainPageIndex = args['pre']['index'];
        dateTimeInfo = args['pre']['dateTime'];
        getHowMuchPercentLeft(dateTimeInfo);
      }
    } else if (args['myTempoDiet'] is Map) {
      //diet db 문제
      whereFrom = "savedDiet";
      dietInfo = args["myTempoDiet"];

      // print("/" * 100);
      // print(dietInfo);
      // print("/" * 100);

      String dietName = dietInfo['dietName'];

      Map foodInfo = jsonDecode(dietInfo['foodInfo']);

      // Map foodInfo = jsonDecode(dietInfo['foodInfo']);
      // Map foods = Map<String, dynamic>.from(foodInfo[dietInfo['dietName']]);
      // print(foods);
      // var foodCodes = foods.keys;

      for (var item in foodInfo['foods']) {
        changeList.add(item['foodMass']);
        foodList.add(ListContents(
            foodName: item['foodName'],
            code: item['code'],
            mass: item['foodMass']));
      }

      justCalNutri(foodList, changeList).then((val) {
        setState(() {
          carbohydrateMass = val[0];
          proteinMass = val[1];
          fatMass = val[2];
        });
      });

      setState(() {
        dietNameController.text = dietInfo['dietName'];
      });
    } else {
      dietNameController.text = null;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Expanded(
            flex: 10,
            child: Column(
              children: [
                //listview & 음식추가 버튼 Stack
                Expanded(
                  // flex: 8,
                  child: Container(
                    margin: EdgeInsets.only(
                        top: 10, left: 10, right: 10, bottom: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: listViewColor, width: 2),
                    ),
                    child: Stack(
                      children: [
                        ListView.separated(
                          padding: EdgeInsets.all(8),
                          itemCount: foodList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return buildFood(foodList[index], index);
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              Divider(
                            color: listViewColor,
                            thickness: 1,
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            margin: EdgeInsets.all(10),
                            height: 40,
                            width: 120,
                            child: FloatingActionButton.extended(
                              icon: Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                              // backgroundColor: Color(0xFF69C2B0),
                              backgroundColor: iconColor,
                              splashColor: Colors.white,
                              onPressed: () {
                                _navigateAndDisplaySelection(context);
                                isGraphShowed = false;
                              },
                              label: Text(
                                '음식 추가',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          //식단명 입력
          Expanded(
            flex: 1,
            child: Container(
              child: Row(
                children: [
                  Spacer(
                    flex: 1,
                  ),
                  // calculate button
                  Expanded(
                    flex: 1,
                    child: InkWell(
                        splashColor: Colors.white,
                        child: Ink(
                          child: Icon(Icons.calculate_outlined,
                              color: Colors.deepOrangeAccent[700] //iconColor,
                              ),
                        ),
                        onTap: () async {
                          List<num> defaultFood = passDefaultFoodList();
                          List<num> servingSize = [];

                          if (await DBHelperPerson().getLastPerson() == null) {
                            var snackBar = buildSnackBar('신체 정보가 비어있습니다!!');
                            Scaffold.of(context).showSnackBar(snackBar);
                          } else {
                            if (foodList.isNotEmpty) {
                              await getFoodInfo(foodList).then((value) {
                                List<Map> defaultFoodList = [];
                                for (var i = 0; i < defaultFood.length; i++) {
                                  defaultFoodList.add({
                                    "food": value[i],
                                    "mass": defaultFood[i]
                                  });
                                }

                                makeCsvFile(
                                        defaultFoodList: defaultFoodList,
                                        foodList:
                                            value.sublist(defaultFood.length),
                                        hardOrSoft: true) //hard모드
                                    .then((val) {
                                  List<num> sendData = [];
                                  List<num> nutriInfo =
                                      new List(value.length * 3);
                                  for (var i = 0; i < value.length; i++) {
                                    servingSize.add(value[i].servingSize);
                                    nutriInfo[i * 3] = value[i].carbohydrate;
                                    nutriInfo[i * 3 + 1] = value[i].protein;
                                    nutriInfo[i * 3 + 2] = value[i].fat;
                                  }

                                  sendData.addAll(nutriInfo);
                                  sendData.addAll(val);

                                  try {
                                    List<dynamic> carProFat =
                                        justCalculateNutri(
                                            sendData,
                                            foodList.length -
                                                defaultFood.length,
                                            defaultFood.length);
                                    num total = carProFat[3] * 4 +
                                        carProFat[4] * 4 +
                                        carProFat[5] * 9;
                                    // assert(total < 600 * 1.2 && total > 600 * 0.8); //이 칼로리 조합이 아니면 단 하나의 경우도 케이스 통과 X

                                    for (var i = 0; i < foodList.length; i++) {
                                      foodMassController[i].text =
                                          val[i].toStringAsFixed(0);
                                      foodServingController[i].text =
                                          "${(val[i] / servingSize[i]).toStringAsFixed(1)}인분";
                                    }

                                    setState(() {
                                      correct = carProFat[1];
                                      carbohydrateMass = carProFat[3];
                                      proteinMass = carProFat[4];
                                      fatMass = carProFat[5];
                                    });
                                  } catch (e) {
                                    var snackBar =
                                        buildSnackBar('음식 조합이 매우 부적합합니다.');
                                    Scaffold.of(context).showSnackBar(snackBar);
                                  }
                                });
                              });
                            }
                          }
                        }),
                  ),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                        splashColor: Colors.white,
                        child: Ink(
                          child: Icon(Icons.calculate_outlined,
                              color: Colors.deepOrangeAccent[100] //iconColor,
                              ),
                        ),
                        onTap: () async {
                          List<num> defaultFood = passDefaultFoodList();
                          List<num> servingSize = [];

                          if (await DBHelperPerson().getLastPerson() == null) {
                            var snackBar = buildSnackBar('신체 정보가 비어있습니다!!');
                            Scaffold.of(context).showSnackBar(snackBar);
                          } else {
                            if (foodList.isNotEmpty) {
                              await getFoodInfo(foodList).then((value) {
                                List<Map> defaultFoodList = [];
                                for (var i = 0; i < defaultFood.length; i++) {
                                  defaultFoodList.add({
                                    "food": value[i],
                                    "mass": defaultFood[i]
                                  });
                                }

                                makeCsvFile(
                                        defaultFoodList: defaultFoodList,
                                        foodList:
                                            value.sublist(defaultFood.length),
                                        hardOrSoft: false) //soft
                                    .then((val) {
                                  List<num> sendData = [];
                                  List<num> nutriInfo =
                                      new List(value.length * 3);
                                  for (var i = 0; i < value.length; i++) {
                                    servingSize.add(value[i].servingSize);
                                    nutriInfo[i * 3] = value[i].carbohydrate;
                                    nutriInfo[i * 3 + 1] = value[i].protein;
                                    nutriInfo[i * 3 + 2] = value[i].fat;
                                  }

                                  sendData.addAll(nutriInfo);
                                  sendData.addAll(val);

                                  try {
                                    List<dynamic> carProFat =
                                        justCalculateNutri(
                                            sendData,
                                            foodList.length -
                                                defaultFood.length,
                                            defaultFood.length);
                                    num total = carProFat[3] * 4 +
                                        carProFat[4] * 4 +
                                        carProFat[5] * 9;
                                    // assert(total < 600 * 1.2 && total > 600 * 0.8); //이 칼로리 조합이 아니면 단 하나의 경우도 케이스 통과 X

                                    for (var i = 0; i < foodList.length; i++) {
                                      foodMassController[i].text =
                                          val[i].toStringAsFixed(0);
                                      foodServingController[i].text =
                                          "${(val[i] / servingSize[i]).toStringAsFixed(1)}인분";
                                    }

                                    setState(() {
                                      correct = carProFat[1];
                                      carbohydrateMass = carProFat[3];
                                      proteinMass = carProFat[4];
                                      fatMass = carProFat[5];
                                    });
                                  } catch (e) {
                                    var snackBar =
                                        buildSnackBar('음식 조합이 매우 부적합합니다.');
                                    Scaffold.of(context).showSnackBar(snackBar);
                                  }
                                });
                              });
                            }
                          }
                        }),
                  ),
                  Spacer(),

                  Expanded(
                    flex: 5,
                    child: TextField(
                      // style: TextStyle(
                      //   color: Colors.white,
                      // ),
                      decoration: InputDecoration(
                        hintText: '식단명을 입력하세요',
                        // hintStyle: TextStyle(color: Colors.white)
                      ),
                      controller: dietNameController,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // add button
                  Spacer(),
                  Expanded(
                    flex: 2,
                    child: IconButton(
                        splashColor: Colors.white,
                        icon: Icon(
                          Icons.add,
                          color: iconColor,
                        ),
                        onPressed: () async {
                          if (changeNumOfMass() != foodList.length) {
                            for (var item in foodMassController) {
                              print(item.value.text);
                            }

                            var snackBar = buildSnackBar('빈칸이 있습니다.');
                            Scaffold.of(context).showSnackBar(snackBar);
                          } else {
                            //db에 저장

                            String dietName =
                                dietNameController.value.text.trim() == "" ||
                                        dietNameController.value.text.trim() ==
                                            null
                                    ? null
                                    : dietNameController.value.text.trim();

                            List<num> foodMass = [];
                            Diet diet;

                            for (var i = 0; i < foodList.length; i++) {
                              foodMass.add(
                                  num.parse(foodMassController[i].value.text));
                            }

                            if (whereFrom == "mainPage") {
                              //메인페이지에서 접근
                              await formatDiet(
                                      dietName: dietName,
                                      dietDateName: dateTimeInfo,
                                      foodList: foodList,
                                      mainPageIndex: mainPageIndex,
                                      massList: foodMass)
                                  .then((value) {
                                diet = value;
                              });

                              mainPageAlertDialog(context, diet);
                            } else if (whereFrom == "searchDietMainPage") {
                              await formatDiet(
                                      dietName: dietName,
                                      dietDateName: dateTimeInfo,
                                      foodList: foodList,
                                      mainPageIndex: mainPageIndex,
                                      massList: foodMass)
                                  .then((value) {
                                diet = value;
                              });
                              mainPageAlertDialog(context, diet);
                            } else {
                              //savedDiet,다른 경로로 접근
                              bool flag =
                                  whereFrom == "savedDiet" ? true : false;
                              if (dietName == null) {
                                noDietNameAlertDialog(context, diet, flag);
                              } else {
                                await formatDiet(
                                        dietName: dietName,
                                        foodList: foodList,
                                        mainPageIndex: null,
                                        massList: foodMass)
                                    .then((value) {
                                  diet = value;
                                });
                                showAlertDialog(context, diet, flag);
                              }
                            }
                          }
                        }),
                  ),
                  Spacer(
                    flex: 1,
                  ),
                ],
              ),
            ),
          ),

          Stack(children: [
            // padding: EdgeInsets.only(
            //   left: 20,
            //   right: 20,
            // ),
            Container(
              margin: EdgeInsets.only(
                left: 30,
                right: 30,
              ),
              child: PieChartSample2(
                carbohydrate: carbohydrateMass * 4,
                fat: fatMass * 9,
                protein: proteinMass * 4,
                totalCalorie:
                    carbohydrateMass * 4 + fatMass * 9 + proteinMass * 4,
                correct: correct.toDouble(),
              ),
            ),

            Positioned(
              bottom: 1,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: AutoSizeText(
                    '하루 총 칼로리를 기준으로 계산된 값입니다',
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ),
          ]),

          // Spacer(
          //   flex: 1,
          // ),
        ],
      ),
    );
  }

  showNoZeroDialog(BuildContext context) {
    // set up the button
    Widget okButton = FlatButton(
        child: Text("OK"),
        onPressed: () async {
          Navigator.pop(context);
        });

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Value Error"),
      content: Text("0으로 설정할 수 없습니다."),
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

  mainPageAlertDialog(BuildContext context, Diet diet) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("저장"),
      onPressed: () async {
        if (_currentSliderValue == 0) {
          showNoZeroDialog(context);
        } else {
          String mealTime = mainPageReturnMealTime(mainPageIndex);

          String dietTitle = '$dateTimeInfo-$mealTime';

          diet.dietName =
              (diet.dietName.length > 0) ? diet.dietName : dietTitle;
          await dbHelperDiet.createHelper(diet);
          Map passingData = diet.toMap();
          passingData["rate"] = _currentSliderValue;
          print("mainpagealert dialog");
          print(passingData['rate']);
          print(passingData['rate'] * person.metabolism * 0.01);
          _currentSliderValue = 0;
          Navigator.pop(context);
          Navigator.pop(context, passingData);
          setState(() {
            _currentSliderValue = 0;
          });
        }
      },
    );

    Widget noButton = FlatButton(
      child: Text("취소"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.black,
      title: Text("저장하기"),
      content: FittedBox(
        // height: MediaQuery.of(context).size.height / 4,
        child: Column(
          children: [
            Text("하루 전체 식사량 중 몇프로를 섭취할지 골라주세요.\n",
                style: TextStyle(color: Colors.white), maxLines: 1),
            Text(
              "\n권장되는 비율은 아침 점심 저녁 간식 순 3:4:2:1입니다.\n",
              style: TextStyle(fontSize: 15),
              // maxLines: 2,
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                  "\n오늘 총 칼로리 중 ${(100 - rangeSliderMaxValue).toStringAsFixed(1)}%를 이미 사용하셨습니다."),
            ),
            RangeSlider()
          ],
        ),
      ),
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

  showAlertDialog(BuildContext context, Diet diet, bool flag) {
    // set up the button
    Widget okButton = FlatButton(
        child: Text("OK"),
        onPressed: () async {
          await dbHelperDiet.createHelper(diet);
          if (flag) {
            Navigator.pop(context);
            Navigator.pop(context);
          } else {
            Navigator.pop(context);
            Navigator.pop(context);
            List temp = await dbHelperDiet.getAllMyDiet();
            temp.clear();
            Navigator.pushNamed(context, '/searchDiet');
          }
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

  noDietNameAlertDialog(BuildContext context, Diet diet, bool flag) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("식단 이름을 지정하지 않았습니다."),
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

  num detnum(List<List<num>> matrix, int row, int col) {
    List<num> mat = [];
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (i != row && j != col) {
          mat.add(matrix[i][j]);
        }
      }
    }
    return mat[0] * mat[3] - mat[1] * mat[2];
  }

  num detTriple(List<List<num>> matrix) {
    return (matrix[0][0] * detnum(matrix, 0, 0) -
        matrix[0][1] * detnum(matrix, 0, 1) +
        matrix[0][2] * detnum(matrix, 0, 2));
  }

  Future<List<num>> calculate(List<ListContents> foodList,
      {List<int> defaultMass = null}) async {
    List<Map> foods = [];
    num determinant, x_det, y_det, z_det;
    List<List<num>> matrix = [];
    List<List<num>> matrixTemp = [];
    List<num> carbohydrate = [];
    List<num> protein = [];
    List<num> fat = [];
    num totalCalorie = 600; //일단 가정(kcal)
    // List<num> ratio = [5, 3, 2]; //탄 단 지 순서 (가정) 5:3:2라 가정
    num unit;
    num x, y, z; //각 음식별 무게
    for (var i = 0; i < foodList.length; i++) {
      Food food = await dbHelperFood.getFood(foodList[i].code);

      if (defaultMass != null) {
        if (defaultMass.contains(i)) {
          totalCalorie -= food.carbohydrate *
                  num.parse(foodMassController[i].value.text) *
                  4 +
              food.fat * num.parse(foodMassController[i].value.text) * 9 +
              food.protein * num.parse(foodMassController[i].value.text) * 4;
        } else {
          foods.add(food.toMap());
          carbohydrate.add(food.carbohydrate);
          protein.add(food.protein);
          fat.add(food.fat);
        }
      } else {
        foods.add(food.toMap());
        carbohydrate.add(food.carbohydrate);
        protein.add(food.protein);
        fat.add(food.fat);
      }
    }

    unit = totalCalorie / 50;
    /*
    탄수화물  단백질     지방
    4cal/g    4cal/g    9cal/g

    탄수화물  단백질      지방
    5k(g)     3k(g)      2k(g)

    20k(cal)  12k(cal)   18k(cal)   => 합하면 50k

    unit은 k
    */
    carbohydrate.add(unit * 5);
    protein.add(unit * 3);
    fat.add(unit * 2);

    matrix = [carbohydrate, protein, fat];

    //디터미넌트
    matrixTemp = selectRow(matrix, 0, 1, 2);
    determinant = detTriple(matrixTemp);

    //x_디터미넌트
    matrixTemp = selectRow(matrix, 3, 1, 2);
    x_det = detTriple(matrixTemp);

    //y_디터미넌트
    matrixTemp = selectRow(matrix, 0, 3, 2);
    y_det = detTriple(matrixTemp);

    //z_디터미넌트
    matrixTemp = selectRow(matrix, 0, 1, 3);
    z_det = detTriple(matrixTemp);

    //x,y,z 계산
    x = x_det / determinant;
    y = y_det / determinant;
    z = z_det / determinant;

    return [x, y, z];
  }

  List<List<num>> selectRow(List<List<num>> matrix, int x, int y, int z) {
    var temp = [
      [matrix[0][x], matrix[0][y], matrix[0][z]],
      [matrix[1][x], matrix[1][y], matrix[1][z]],
      [matrix[2][x], matrix[2][y], matrix[2][z]]
    ];
    return temp;
  }

  Future<List<Food>> getFoodInfo(List<ListContents> foodList) async {
    List<Food> foods = [];
    for (var i = 0; i < foodList.length; i++) {
      Food food = await dbHelperFood.getFood(foodList[i].code);
      foods.add(food);
    }

    return foods;
  }

  Future<List<num>> justCalNutri(
      List<ListContents> foodList, List<num> mass) async {
    num carbohydrate = 0.0;
    num protein = 0.0;
    num fat = 0.0;

    List<num> index = [];
    index = getIndex();

    for (var i = 0; i < foodList.length; i++) {
      Food food = await dbHelperFood.getFood(foodList[i].code);
      if (mass[i] == null || mass.length - 1 < i) {
        mass[i] = 0;
      }
      carbohydrate += food.carbohydrate * mass[i];
      protein += food.protein * mass[i];
      fat += food.fat * mass[i];
    }
    return [carbohydrate, protein, fat];
  }
}

class RangeSlider extends StatefulWidget {
  RangeSlider({Key key}) : super(key: key);

  @override
  RangeSliderState createState() => RangeSliderState();
}

/// This is the private State class that goes with MyStatefulWidget.
class RangeSliderState extends State<RangeSlider> {
  @override
  Widget build(BuildContext context) {
    return Slider(
      value: _currentSliderValue,
      min: 0,
      max: 100,
      divisions: 1000,
      label:
          (_currentSliderValue * person.metabolism / 100).toStringAsFixed(1) +
              "Kcal" +
              " ${_currentSliderValue.toStringAsFixed(1)}%",
      onChanged: (double value) {
        if (value > rangeSliderMaxValue) {
          //몇프로 남았는지 계산해야함
        } else {
          setState(() {
            _currentSliderValue = value;
          });
        }
      },
    );
  }
}
