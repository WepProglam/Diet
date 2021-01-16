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

StreamController<Map> streamController = StreamController<Map>.broadcast();
StreamController<bool> streamControllerBool =
    StreamController<bool>.broadcast();

void main() => runApp(MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.purple[300],
      ),
      color: Colors.purple[300],
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
