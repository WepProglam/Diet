import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/model.dart';
import 'appBar.dart';
import 'db_helper.dart';
import 'piChart.dart';
import 'calculate.dart';

final dbHelperFood = DBHelperFood();

class AddDiet extends StatelessWidget {
  const AddDiet({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFEF5),
      appBar: basicAppBar('Add Diet', context),
      drawer: NavDrawer(),
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
  num carbohydrateMass, proteinMass, fatMass = 0.0;
  num totalCalorie;
  num correct = 0.0;
  bool isGraphShowed = false;
  var dietInfo = {};
  List<num> massChangeList = [];
  List<num> changeList = [];

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
    super.dispose();
  }

  void addItem(List<ListContents> food) {
    setState(() {
      foodList += food;
    });
  }

  String initialVal(num mass) {
    if (mass == null || mass == 0) {
      return '';
    } else {
      return '$mass';
    }
  }

  Widget buildFood(ListContents food, int index) {
    // print("index" * 10);
    // print(index);
    // print(food.foodName);
    if (foodList.length > foodMassController.length) {
      //saved에서 넘어오는 경우 계속 controller를 만드는거 방지
      TextEditingController _controller = TextEditingController();
      if (foodList.contains(food)) {
        print(food.foodName);
        print(food.code);
        print(food.mass);
        _controller.text = initialVal(food.mass);
      } else {
        _controller.text = initialVal(0);
      }
      foodMassController.add(_controller);
    } else {}

    // print("=$index" * 100);
    // print(foodMassController.length);
    //받는 매게변수 index 추가
    return Center(
      child: Row(
        children: [
          Spacer(
            flex: 1,
          ),
          Expanded(
            flex: 4,
            child: Text('${food.foodName}'),
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
                massChangeList = [];
                List<int> index = getIndex();
                for (var item in index) {
                  massChangeList.insert(
                      item, num.tryParse(foodMassController[item].value.text));
                }

                justCalNutri(foodList, massChangeList).then((val) {
                  // print(val);
                  setState(() {
                    carbohydrateMass = val[0];
                    proteinMass = val[1];
                    fatMass = val[2];
                  });
                });
              },
            ),
          ),
          Text('g'),
          Expanded(
            flex: 1,
            child: FlatButton(
              child: Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  foodList.removeAt(index);
                  foodMassController[index].text = "";
                  // for (var item in foodMassController) {
                  //   item.text = "";
                  // }
                });
              },
            ),
          )
        ],
      ),
    );
  }

  //음식 추가하는거임
  _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push는 Future를 반환합니다. Future는 선택 창에서
    // Navigator.pop이 호출된 이후 완료될 것입니다.
    List<ListContents> foods = [];
    var result;
    await Navigator.pushNamed(
      context,
      '/searchFood',
      arguments: <String, String>{
        'pre': 'addDiet',
      },
    ).then((val) {
      result = val;
    });
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
      // if (j != null) {
      // if (j != 0) {
      n.add(k);
      // }
      // }
      k += 1;
    }
    print("return $n");
    return n;
  }

  int changeNumOfMass() {
    int n = 0;
    for (var item in foodMassController) {
      dynamic j = num.tryParse(item.value.text);
      if (j != null) {
        // if (j != 0) {
        print("j is $j");
        n++;
        // }
      }
    }
    print("return $n");
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
  void didChangeDependencies() {
    final Map<String, Map> args = ModalRoute.of(context).settings.arguments;
    if (args != null) {
      foodList = [];
      changeList = [];
      dietInfo = args["myTempoDiet"];
      Map foodInfo = jsonDecode(dietInfo['foodInfo']);
      Map foods = Map<String, dynamic>.from(foodInfo[dietInfo['dietName']]);
      // print(foods);
      var foodCodes = foods.keys;

      for (var item in foodCodes) {
        changeList.add(foods[item]['foodMass']);
        foodList.add(ListContents(
            foodName: foods[item]['foodName'],
            code: item,
            mass: foods[item]['foodMass']));
      }
      // print(foodList.length);

      justCalNutri(foodList, changeList).then((val) {
        // print(val);
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

    print("foodlist length : ${foodList.length}");
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              children: [
                //음식 추가 버튼

                //listview
                Expanded(
                  flex: 8,
                  child: Container(
                    margin: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF69C2B0)),
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
                              Divider(),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: FloatingActionButton(
                            onPressed: null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Spacer(
                            flex: 1,
                          ),
                          Expanded(
                            flex: 4,
                            child: GestureDetector(
                              onTap: () {
                                _navigateAndDisplaySelection(context);
                                isGraphShowed = false;
                              },
                              child: Container(
                                height: MediaQuery.of(context).size.height / 14,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color(0xFF69C2B0),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '음식 추가',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Spacer(
                            flex: 1,
                          ),
                        ],
                      ),
                      Spacer(
                        flex: 1,
                      ),
                    ],
                  ),
                ),
<<<<<<< HEAD
                //listview
                Expanded(
                  flex: 8,
                  child: Container(
                    margin: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF69C2B0)),
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.all(8),
                      itemCount: foodList.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (index <= foodList.length - 1) {
                          return buildFood(foodList[index], index);
                        } else {
                          return null;
                        }
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          Divider(),
                    ),
                  ),
                ),
=======
>>>>>>> 671eb50f8c9d2a30bb113c19cf8afa604227e8ec
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Spacer(
                  flex: 1,
                ),
                // calculate button
                Expanded(
                  flex: 1,
                  child: IconButton(
                      icon: Icon(Icons.calculate, color: Color(0xFF69C2B0)),
                      onPressed: () async {
                        // print(numOfMass(foodList));
                        // print("==================================");
                        // print(foodList.length);
                        if (foodList.length < 3) {
                          //최소 3개 선택하라는 경고창
                          var snackBar = buildSnackBar('음식을 3종류 이상 선택해주세요');
                          Scaffold.of(context).showSnackBar(snackBar);
                        } else if (foodList.length == 3) {
                          await getFoodInfo(foodList).then((value) {
                            makeCsvFile(nutri: value).then((val) {
                              List<num> sendData = [];
                              sendData.addAll(value);
                              sendData.addAll(val);
                              try {
                                List<dynamic> carProFat =
                                    justCalculateNutri(sendData);
                                setState(() {
                                  carbohydrateMass = carProFat[5];
                                  proteinMass = carProFat[6];
                                  fatMass = carProFat[7];
                                  correct = carProFat[3];
                                });
                                for (var i = 0; i < 3; i++) {
                                  foodMassController[i].text =
                                      val[i].toString();
                                }
                              } catch (e) {
                                var snackBar =
                                    buildSnackBar('음식 조합이 매우 부적합합니다.');
                                Scaffold.of(context).showSnackBar(snackBar);
                              }
                            });
                          });
                        } else {
                          if (foodList.length - changeNumOfMass() == 3) {
                            //should add change calorie

                            List<int> index = getIndex();

                            calculate(foodList, defaultMass: index)
                                .then((value) {
                              for (var i = 0; i < 3; i++) {
                                // print(value[i]);
                              }
                              var massList = value;
                              // print(massList);
                              for (var item in index) {
                                massList.insert(
                                    item,
                                    num.parse(
                                        foodMassController[item].value.text));
                              }
                              // print(massList);

                              justCalNutri(foodList, massList).then((val) {
                                // print(val);
                                setState(() {
                                  carbohydrateMass = val[0];
                                  proteinMass = val[1];
                                  fatMass = val[2];
                                });
                                var controllerIndex = 0;

                                for (var i = 0; i < value.length; i++) {
                                  if (index.contains(controllerIndex)) {
                                  } else {
                                    foodMassController[controllerIndex].text =
                                        value[i].toString();
                                  }
                                  controllerIndex += 1;
                                }
                              });
                            });
                          } else {
                            var snackBar = buildSnackBar(
                                '빈칸이 3개일 경우에만 계산 가능합니다.\n 0인 값이 4개 이상입니다.');
                            Scaffold.of(context).showSnackBar(snackBar);
                          }
                        }
                      }),
                ),
                // Expanded(
                //   flex: 1,
                //   child: IconButton(
                //     icon: Icon(Icons.palette),
                //     color: Color(0xFF69C2B0),
                //     onPressed: () {
                //       if (changeNumOfMass() == foodList.length) {
                //         var massList = <num>[];
                //         for (var i = 0; i < foodList.length; i++) {
                //           massList
                //               .add(num.parse(foodMassController[i].value.text));
                //         }
                //         print(massList);
                //         justCalNutri(foodList, massList).then((value) {
                //           setState(() {
                //             carbohydrateMass = value[0];
                //             proteinMass = value[1];
                //             fatMass = value[2];
                //           });
                //         });
                //       } else {
                //         var snackBar = buildSnackBar('그래프를 보려면 빈칸을 모두 채워주세요');
                //         Scaffold.of(context).showSnackBar(snackBar);
                //       }
                //     },
                //   ),
                // ),
                // enter diet textfield
                Expanded(
                  flex: 4,
                  child: TextField(
                    decoration: InputDecoration(hintText: '식단명을 입력하세요'),
                    controller: dietNameController,
                    textAlign: TextAlign.center,
                  ),
                ),
                // add button
                Expanded(
                  flex: 1,
                  child: IconButton(
                      icon: Icon(Icons.add, color: Color(0xFF69C2B0)),
                      onPressed: () {
                        int k = 0;
                        for (var item in foodMassController) {
                          // print(item.value.text);
                          // print(item);
                          if (item.value.text != "" ||
                              item.value.text != null) {
                            k += 1;
                          }
                        }
                        // print(k);
                        if (k != foodList.length) {
                          var snackBar = buildSnackBar('빈칸이 있습니다.');
                          Scaffold.of(context).showSnackBar(snackBar);
                        } else {
                          //db에 저장
                          String dietName = dietNameController.value.text;
                          Map foodInfo = {dietName: {}};
                          for (var i = 0; i < foodList.length; i++) {
                            var foodMass =
                                num.parse(foodMassController[i].value.text);

                            foodInfo[dietName][foodList[i].code] = {
                              "foodName": foodList[i].foodName,
                              "foodMass": foodMass
                            };
                          }
                          String foodInfoString = jsonEncode(foodInfo);
                          var diet = Diet(
                            dietName: dietName,
                            foodInfo: foodInfoString,
                          );
                          showAlertDialog(context, diet);
                        }
                      }),
                ),
                Spacer(
                  flex: 1,
                ),
              ],
            ),
          ),
          PieChartSample2(
            carbohydrate: carbohydrateMass * 4,
            fat: fatMass * 9,
            protein: proteinMass * 4,
            totalCalorie: carbohydrateMass * 4 + fatMass * 9 + proteinMass * 4,
            correct: correct,
          ),
          Spacer(
            flex: 1,
          ),
        ],
      ),
    );
  }

  showAlertDialog(BuildContext context, Diet diet) {
    // set up the button
    Widget okButton = FlatButton(
        child: Text("OK"),
        onPressed: () {
          dbHelperDiet.createData(diet);
          Navigator.pop(context);
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
      // print(foodList[i].code);
      if (defaultMass != null) {
        if (defaultMass.contains(i)) {
          totalCalorie -=
              food.kcal * num.parse(foodMassController[i].value.text);
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
    // print(carbohydrate);
    // print(protein);
    // print(fat);
    // print("totalcalorie $totalCalorie");
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

  Future<List<num>> getFoodInfo(List<ListContents> foodList) async {
    List<num> carbohydrateList = [];
    List<num> proteinList = [];
    List<num> fatList = [];
    for (var i = 0; i < foodList.length; i++) {
      Food food = await dbHelperFood.getFood(foodList[i].code);
      carbohydrateList.add(food.carbohydrate);
      proteinList.add(food.protein);
      fatList.add(food.fat);
    }
    print("탄수화물 : $carbohydrateList");

    print(carbohydrateList + proteinList + fatList);

    return carbohydrateList + proteinList + fatList;
  }

  Future<List<num>> justCalNutri(
      List<ListContents> foodList, List<num> mass) async {
    num carbohydrate = 0.0;
    num protein = 0.0;
    num fat = 0.0;

    List<num> index = [];
    index = getIndex();
    // print("*" * 100);
    // print(foodList.length);
    // print(mass.length);
    // print("*" * 100);
    for (var i = 0; i < foodList.length; i++) {
      Food food = await dbHelperFood.getFood(foodList[i].code);
      // print(mass[i]);
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
