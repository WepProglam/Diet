import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'personalForm.dart';
import 'initPage.dart';
import 'savedDiet.dart';
import 'mainPage.dart';
import 'addFood.dart';
import 'savedFood.dart';
import 'searchDiet.dart';
import 'searchFood.dart';
import 'addDiet.dart';
import 'calculate.dart';
import 'activityPage.dart';

StreamController<Map> streamController = StreamController<Map>.broadcast();
StreamController<bool> streamControllerBool =
    StreamController<bool>.broadcast();
var accColor = Colors.white;
void main() {
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
      cardColor: Colors.deepOrangeAccent[700],

      accentColor: accColor,
      splashColor: accColor == Colors.white
          ? Colors.deepOrangeAccent[700]
          : Colors.white,

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
    initialRoute: '/mainPage',
    routes: {
      '/': (context) => InitPage(),
      '/personalForm': (context) => PersonalForm(),
      '/savedDiet': (context) => SavedDiet(),
      '/savedFood': (context) => SavedFood(),
      '/mainPage': (context) => MainPage(),
      '/addFood': (context) => AddFood(),
      '/searchDiet': (context) => SearchDiet(),
      '/searchFood': (context) => SearchFood(),
      '/addDiet': (context) => AddDiet(),
      '/calculate': (context) => Calculate(),
      '/activityPage': (context) => Activity()
    },
  ));
}

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       initialRoute: '/',
//       routes: {
//         '/': (context) => InitPage(),
//         '/personalForm': (context) => PersonalForm(),
//         '/saving': (context) => Saving(),
//       },
//     );
//   }
// }
