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

StreamController<Map> streamController = StreamController<Map>.broadcast();
StreamController<bool> streamControllerBool =
    StreamController<bool>.broadcast();

void main() => runApp(MaterialApp(
      theme: ThemeData(
        backgroundColor: Color(0xFFFFFEF5),
        primaryColor: Color(0xFF69C2B0),
      ),
      initialRoute: '/',
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
        '/calculate':(context)=>Calculate()
      },
    ));

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
