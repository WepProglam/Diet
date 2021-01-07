import 'package:flutter/material.dart';
import 'personalForm.dart';
import 'initPage.dart';

void main() => runApp(MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => InitPage(),
        '/personalForm': (context) => PersonalForm(),
        '/saving': (context) => Saving(),
      },
    ));
