import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'personalForm.dart';
import 'initPage.dart';
import 'savedDiet.dart';

void main() => runApp(MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => InitPage(),
        '/personalForm': (context) => PersonalForm(),
        '/saving': (context) => Saving(),
        '/savedDiet': (context) => SavedDiet()
      },
    ));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => InitPage(),
        '/personalForm': (context) => PersonalForm(),
        '/saving': (context) => Saving(),
      },
    );
  }
}