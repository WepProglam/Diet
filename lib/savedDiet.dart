//To_ToRo
import 'package:flutter/material.dart';
import 'appBar.dart';

class SavedDiet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diet_3',
      home: Scaffold(
        appBar: basicAppBar('Diet List'),
        body: Center(
          child: DietList(),
        ),
      ),
    );
  }
}

class DietList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //실제로는 db에서 얻어와야 함
    final List<String> dietNameEX = [
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
      childAspectRatio: 5 / 4,
      children: List.generate(
        dietNameEX.length,
        (index) {
          return Card(
            margin: EdgeInsets.all(8),
            child: FlatButton(
              //onPressed에 식단 설정 페이지로 이동하는 함수 넣기
              onPressed: () {},

              child: Text(
                '${dietNameEX[index]}',
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
