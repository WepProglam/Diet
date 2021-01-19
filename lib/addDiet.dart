import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/model.dart';
import 'appBar.dart';
import 'db_helper.dart';
import 'piChart.dart';

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
  num mass;

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
  double carbohydrateMass, proteinMass, fatMass = 0;
  bool isGraphShowed = false;

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
    TextEditingController _controller = TextEditingController();
    _controller.text = initialVal(food.mass);
    foodMassController.add(_controller);
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
              onChanged: (text) {
                setState(() {
                  foodList[index].mass = num.parse(text);
                  print(foodMassController[index].value.text);
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
                  for (var item in foodMassController) {
                    item.text = "";
                  }
                  carbohydrateMass = 0.0;
                  fatMass = 0.0;
                  proteinMass = 0.0;
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

  int changeNumOfMass(List<ListContents> list) {
    int n = 0;
    for (var item in list) {
      if (item.mass != null) {
        n++;
      }
    }
    return n;
  }

  bool isThereBlank(List<ListContents> list) {
    for (var item in list) {
      if (item.mass == 0 || item.mass == null) {
        return true;
      }
    }
    return false;
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
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Spacer(
                        flex: 1,
                      ),
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
                              },
                              child: Container(
                                height: 80,
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
                //listview
                Expanded(
                  flex: 4,
                  child: Container(
                    margin: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF69C2B0)),
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.all(8),
                      itemCount: foodList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return buildFood(foodList[index], index);
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          Divider(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
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
                      onPressed: () {
                        if (!isGraphShowed) {
                          if (foodList.length < 3) {
                            //최소 3개 선택하라는 경고창
                            var snackBar = buildSnackBar('음식을 3종류 이상 선택해주세요');
                            Scaffold.of(context).showSnackBar(snackBar);
                          } else if (numOfMass(foodList) == 3) {
                            calculate(foodList).then((value) {
                              justCalNutri(foodList, value).then((val) {
                                print(val);
                                setState(() {
                                  carbohydrateMass =
                                      val[0] * 100 / (val[0] + val[1] + val[2]);
                                  proteinMass =
                                      val[1] * 100 / (val[0] + val[1] + val[2]);
                                  fatMass =
                                      val[2] * 100 / (val[0] + val[1] + val[2]);
                                });

                                for (var i = 0; i < 3; i++) {
                                  foodMassController[i].text =
                                      value[i].toString();
                                  foodList[i].mass = double.parse(
                                      foodMassController[i].value.text);
                                }
                              });

                              isGraphShowed = true;
                            });
                          } else {
                            print(numOfMass(foodList));
                            var snackBar =
                                buildSnackBar('빈칸이 3개일 경우에만 계산 가능합니다.');
                            Scaffold.of(context).showSnackBar(snackBar);
                          }
                        } else {
                          if (changeNumOfMass(foodList) == 3) {
                            print("hello");
                            var massList = <double>[];
                            for (var i = 0; i < 3; i++) {
                              massList.add(
                                  num.parse(foodMassController[i].value.text));
                            }
                            print(massList);
                            justCalNutri(foodList, massList).then((value) {
                              setState(() {
                                carbohydrateMass = value[0] *
                                    100 /
                                    (value[0] + value[1] + value[2]);
                                proteinMass = value[1] *
                                    100 /
                                    (value[0] + value[1] + value[2]);
                                fatMass = value[2] *
                                    100 /
                                    (value[0] + value[1] + value[2]);
                              });
                            });
                          }
                        }
                      }),
                ),
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
                        if (isThereBlank(foodList)) {
                          var snackBar = buildSnackBar('빈칸이 있습니다.');
                          Scaffold.of(context).showSnackBar(snackBar);
                        } else {
                          //db에 저장
                          String dietName = dietNameController.value.text;
                          Map foodInfo = {dietName: {}};
                          for (var item in foodList) {
                            foodInfo[dietName][item.code] = {
                              "foodName": item.foodName,
                              "foodMass": item.mass
                            };
                          }
                          String foodInfoString = jsonEncode(foodInfo);
                          var diet = Diet(
                            dietName: dietName,
                            foodInfo: foodInfoString,
                          );
                          dbHelperDiet.createData(diet);
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
            carbohydrate: carbohydrateMass,
            fat: fatMass,
            protein: proteinMass,
          ),
          Spacer(
            flex: 1,
          ),
        ],
      ),
    );
  }

  double detDouble(List<List<double>> matrix, int row, int col) {
    List<double> mat = [];
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (i != row && j != col) {
          mat.add(matrix[i][j]);
        }
      }
    }
    return mat[0] * mat[3] - mat[1] * mat[2];
  }

  double detTriple(List<List<double>> matrix) {
    return (matrix[0][0] * detDouble(matrix, 0, 0) -
        matrix[0][1] * detDouble(matrix, 0, 1) +
        matrix[0][2] * detDouble(matrix, 0, 2));
  }

  Future<List<double>> calculate(List<ListContents> foodList) async {
    List<Map> foods = [];
    double determinant, x_det, y_det, z_det;
    List<List<double>> matrix = [];
    List<List<double>> matrixTemp = [];
    List<double> carbohydrate = [];
    List<double> protein = [];
    List<double> fat = [];
    double totalCalorie = 600; //일단 가정
    List<double> ratio = [5, 3, 2]; //탄 단 지 순서 (가정)
    double x, y, z; //각 음식별 무게

    for (var item in foodList) {
      Food food = await dbHelperFood.getFood(item.code);
      foods.add(food.toMap());
      carbohydrate.add(food.carbohydrate);
      protein.add(food.protein);
      fat.add(food.fat);
    }
    carbohydrate
        .add(totalCalorie * ratio[0] / (ratio[0] + ratio[1] + ratio[2]));
    protein.add(totalCalorie * ratio[1] / (ratio[0] + ratio[1] + ratio[2]));
    fat.add(totalCalorie * ratio[2] / (ratio[0] + ratio[1] + ratio[2]));

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

  List<List<double>> selectRow(List<List<double>> matrix, int x, int y, int z) {
    var temp = [
      [matrix[0][x], matrix[0][y], matrix[0][z]],
      [matrix[1][x], matrix[1][y], matrix[1][z]],
      [matrix[2][x], matrix[2][y], matrix[2][z]]
    ];
    return temp;
  }

  Future<List<double>> justCalNutri(
      List<ListContents> foodList, List<double> mass) async {
    double carbohydrate = 0.0;
    double protein = 0.0;
    double fat = 0.0;

    var i = 0;
    for (var item in foodList) {
      Food food = await dbHelperFood.getFood(item.code);
      carbohydrate += food.carbohydrate * mass[i];
      protein += food.protein * mass[i];
      fat += food.fat * mass[i];
      i += 1;
    }
    return [carbohydrate, protein, fat];
  }
}
