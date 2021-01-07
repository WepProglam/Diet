import 'package:flutter/material.dart';

Widget basicAppBar(String title) {
  return AppBar(
    //메뉴
    leading: IconButton(
      icon: Icon(Icons.menu),
      //눌렀을 때 기능 추후에 추가
      onPressed: () {},
    ),

    //앱 이름
    title: Text(title),
    //마이페이지
    actions: <Widget>[
      IconButton(
        icon: Icon(Icons.person),
        onPressed: () {},
      ),
    ],
  );
}
