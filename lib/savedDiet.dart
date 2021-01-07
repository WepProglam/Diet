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

    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: dietNameEX.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          height: 50,
          color: Colors.grey,

          //이걸 수정해서 두 개로 나눌 수 있음
          child: Center(child: Text('${dietNameEX[index]}')),
        );
      },
      separatorBuilder: (context, index) => Divider(),
    );
  }
}
