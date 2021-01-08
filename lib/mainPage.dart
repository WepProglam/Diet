import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPage createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/personalForm');
        },
        child: Container(
          child: Center(
              child: Text(
            "MAIN PAGE\nmaking..\nTAP HERE",
            style: TextStyle(decoration: TextDecoration.none),
          )),
        ));
  }
}
