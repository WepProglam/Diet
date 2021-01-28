import 'dart:async';

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
import 'calcDiet.dart';
import 'calculate.dart';
import 'activityPage.dart';

StreamController<Map> streamController = StreamController<Map>.broadcast();
StreamController<bool> streamControllerBool =
    StreamController<bool>.broadcast();

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
        // backgroundColor: Color(0xFFFFFEF5),
        backgroundColor: Colors.black,
        // primaryColor: Color(0xFF69C2B0),
        primaryColor: Colors.deepOrangeAccent,
        buttonColor: Colors.deepOrangeAccent,
        accentColor: Colors.white,
        textTheme: TextTheme(
          headline1:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          bodyText1: TextStyle(
            // color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        )),
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
      '/calcDiet': (context) => CalcDiet(),
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
