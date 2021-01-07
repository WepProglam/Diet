//To_ToRo
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diet_3',
      home: Scaffold(
        appBar: basicAppBar(),
        body: Center(
          child: Text('HI'),
        ),
      ),
    );
  }
}

//appbar 기본 틀
Widget basicAppBar() {
  return AppBar(
    //메뉴
    leading: IconButton(
      icon: Icon(Icons.menu),
      //눌렀을 때 기능 추후에 추가
      onPressed: () {},
    ),

    //앱 이름
    title: Text('Diet_3'),

    //마이페이지
    actions: <Widget>[
      IconButton(
        icon: Icon(Icons.person),
        onPressed: () {},
      ),
    ],
  );
}
