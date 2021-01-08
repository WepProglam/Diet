import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'personalForm.dart';
import 'initPage.dart';
import 'savedDiet.dart';
import 'mainPage.dart';
import 'addFood.dart';

void main() => runApp(MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => AddFood(),
        '/personalForm': (context) => PersonalForm(),
        '/saving': (context) => Saving(),
        '/savedDiet': (context) => SavedDiet(),
        '/main': (context) => MainPage(),
        '/addFood': (context) => AddFood(),
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
