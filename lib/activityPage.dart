import 'package:flutter/material.dart';
import 'dart:convert';

import 'appBar.dart';
import 'package:flutter/material.dart';

class Activity extends StatelessWidget {
  const Activity({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: basicAppBar('Activity Page', context),
      drawer: NavDrawer(),
      body: ActivityPage(),
    );
  }
}

class ActivityPage extends StatefulWidget {
  ActivityPage({Key key}) : super(key: key);

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
    );
  }
}
