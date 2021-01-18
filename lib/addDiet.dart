import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/model.dart';
import 'appBar.dart';

import 'db_helper.dart';

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
              initialValue: initialVal(food.mass),
              decoration: InputDecoration(hintText: 'mass'),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onChanged: (text) {
                setState(() {
                  foodList[index].mass = num.parse(text);
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
      if (item.mass == 0) {
        n++;
      }
    }
    return n;
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
                        if (foodList.length < 3) {
                          //최소 3개 선택하라는 경고창
                          var snackBar = buildSnackBar('음식을 3종류 이상 선택해주세요');
                          Scaffold.of(context).showSnackBar(snackBar);
                        } else if (numOfMass(foodList) == 3) {
                          print('correct!');
                        } else {
                          print(numOfMass(foodList));
                          var snackBar =
                              buildSnackBar('빈칸이 3개일 경우에만 계산 가능합니다.');
                          Scaffold.of(context).showSnackBar(snackBar);
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
                        if () {
                          //최소 3개 선택하라는 경고창
                          final snackBar = buildSnackBar('음식을 3종류 이상 선택해주세요');
                          Scaffold.of(context).showSnackBar(snackBar);
                        } else{
                          //db에 저장
                        }

                        //var diet = Diet(dietName: dietName, foodInfo: foodInfo);
                        //dbHelperDiet.createData(diet);
                      }),
                ),
                Spacer(
                  flex: 1,
                ),
              ],
            ),
          ),
          Spacer(
            flex: 1,
          ),
        ],
      ),
    );
  }
}
