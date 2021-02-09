import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'personalForm.dart';
// import 'initPage.dart';
import 'mainPage.dart';
import 'addFood.dart';
import 'searchDiet.dart';
import 'searchFood.dart';
import 'addDiet.dart';
import 'calculate.dart';
import 'activityPage.dart';
import 'archieve.dart';
import 'db_helper.dart';

final dbHelperRecent = DBHelperRecent();
// var accColor = Colors.white;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool flag;
  await compareDatetime().then((val) {
    flag = val;
  });

  runApp(MaterialApp(
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      // canvasColor: Colors.black,
      // backgroundColor: Colors.deepOrangeAccent,
      primaryColor: Colors.deepOrangeAccent[700],
      appBarTheme: AppBarTheme(color: Colors.black),
      buttonColor: Colors.deepOrangeAccent[400],
      // iconTheme: IconThemeData(
      //   color: Colors.deepOrangeAccent[700],
      // ),
      // cardColor: Colors.deepOrangeAccent[700],
      cardColor: Colors.black,
      accentColor: Colors.white,
      splashColor: Colors.deepOrangeAccent[400],

      // textSelectionColor: Colors.white,
      // textTheme: TextTheme(
      //   headline1:
      //       TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      //   headline2:
      //       TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      //   headline3:
      //       TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      //   bodyText1: TextStyle(
      //     color: Colors.white,
      //     fontWeight: FontWeight.normal,
      //   ),
      //   bodyText2: TextStyle(
      //     color: Colors.white,
      //     fontWeight: FontWeight.normal,
      //   ),
      // )
    ),
    initialRoute: flag != null && flag == true ? '/' : '/personalForm',
    routes: {
      '/': (context) => MainPage(),
      '/personalForm': (context) => PersonalForm(),
      // '/mainPage': (context) => MainPage(),
      '/addFood': (context) => AddFood(),
      '/searchDiet': (context) => SearchDiet(),
      '/searchFood': (context) => SearchFood(),
      '/addDiet': (context) => AddDiet(),
      '/calculate': (context) => Calculate(),
      '/activityPage': (context) => Activity(),
      '/archieve': (context) => Archieve()
    },
  ));
}

Future<bool> compareDatetime() async {
  bool returnValue;
  await dbHelperRecent.getRecent().then((val) {
    print(val);
    print(DateTime.now().toString().substring(0, 10));
    if (val == null) {
      print("first");
      returnValue = false;
    } else if (val != DateTime.now().toString().substring(0, 10)) {
      print("second");
      returnValue = false;
    } else {
      print("third");
      returnValue = true;
    }
  });
  return returnValue;
}
