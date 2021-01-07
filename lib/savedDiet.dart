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
      crossAxisCount: 2,
      children: List.generate(
        dietNameEX.length,
        (index) {
          return Card(
            child: Center(
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
