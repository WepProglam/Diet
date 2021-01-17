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

  void addItem(ListContents food) {
    setState(() {
      foodList.add(food);
    });
  }

  String initialVal(num mass) {
    if (mass == null) {
      return '';
    } else {
      return '$mass';
    }
  }

  Widget buildFood(ListContents food) {
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
            ),
          ),
          Text('g'),
          Spacer(
            flex: 1,
          ),
        ],
      ),
    );
  }

  //음식 추가하는거임
  _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push는 Future를 반환합니다. Future는 선택 창에서
    // Navigator.pop이 호출된 이후 완료될 것입니다.
    final result = await Navigator.pushNamed(
      context,
      '/searchFood',
      arguments: <String, String>{
        'pre': 'addDiet',
      },
    );

    Food food = await DBHelperFood().getFood(result);
    ListContents foodCopy =
        ListContents(foodName: food.foodName, code: food.code);
    addItem(foodCopy);
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
                        return buildFood(foodList[index]);
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
                Expanded(
                  flex: 4,
                  child: TextField(
                    decoration: InputDecoration(hintText: '식단명을 입력하세요'),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                      icon: Icon(Icons.add, color: Color(0xFF69C2B0)),
                      onPressed: null),
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
