import 'package:flutter/material.dart';
import 'appBar.dart';

class AddDiet extends StatelessWidget {
  const AddDiet({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: basicAppBar('Add Diet', context),
      drawer: NavDrawer(),
      body: Center(
        child: Column(
          children: [
            SearchFoodBar(),
            FoodList(),
          ],
        ),
      ),
    );
  }
}

//search Bar만 만들어놓음. drop down 구현 가능하면 하고 아님 버튼으로 바꾸고
class SearchFoodBar extends StatefulWidget {
  SearchFoodBar({Key key}) : super(key: key);

  @override
  _SearchFoodBarState createState() => _SearchFoodBarState();
}

class _SearchFoodBarState extends State<SearchFoodBar> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Spacer 조절로 위치 조절하셈
          Spacer(
            flex: 1,
          ),
          Row(
            children: [
              Spacer(
                flex: 1,
              ),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: null,
                  decoration: InputDecoration(hintText: 'search food'),
                  textAlign: TextAlign.center,
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
    );
  }
}

class ListContents {
  String foodName;
  num mass;

  ListContents({this.foodName, this.mass});
}

class FoodList extends StatefulWidget {
  FoodList({Key key}) : super(key: key);

  @override
  _FoodListState createState() => _FoodListState();
}

class _FoodListState extends State<FoodList> {
  //이건 Search Food에서 onPressed로 하나씩 추가할거임 List.add로 추가할거임
  List<ListContents> foodList = [
    ListContents(foodName: '현미밥', mass: 150),
    ListContents(foodName: '닭가슴살', mass: 120),
    ListContents(foodName: '계란', mass: 70),
  ];

  Widget buildFood(ListContents food) {
    return Center(
      child: Row(
        children: [
          Spacer(
            flex: 1,
          ),
          Expanded(
            flex: 6,
            child: Text('${food.foodName}'),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              decoration: InputDecoration(hintText: '${food.mass}'),
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

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: ListView.separated(
        padding: EdgeInsets.all(8),
        itemCount: foodList.length,
        itemBuilder: (BuildContext context, int index) {
          return buildFood(foodList[index]);
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
    );
  }
}
