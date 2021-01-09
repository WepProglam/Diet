//To_ToRo
import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'appBar.dart';

class SavedFood extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: basicAppBar('Food List', context),
      drawer: NavDrawer(),
      body: Center(
        child: FoodList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(
          Icons.expand_less,
          size: 40,
        ),
        backgroundColor: Colors.black45,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class FoodList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //실제로는 db에서 얻어와야 함
    final List<String> foodNameEX = [
      'AB',
      'BC',
      'CD',
      'DE',
      'EF',
      'FG',
      'GH',
      'HI',
      'IJ'
    ];

    return GridView.count(
      padding: EdgeInsets.all(8),
      crossAxisCount: 2,
      //각 항목의 사이즈
      childAspectRatio: 5 / 3,
      children: List.generate(
        foodNameEX.length,
        (index) {
          return Card(
            margin: EdgeInsets.all(8),
            child: FlatButton(
              //onPressed에 식단 설정 페이지로 이동하는 함수 넣기
              onPressed: () {},

              child: Text(
                '${foodNameEX[index]}',
                style: TextStyle(fontSize: 30),
              ),
            ),
            color: Colors.white70,
          );
        },
      ),
    );
  }
}
