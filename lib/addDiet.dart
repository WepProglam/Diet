import 'package:flutter/material.dart';
import 'appBar.dart';

class AddDiet extends StatelessWidget {
  const AddDiet({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: basicAppBar('Add Diet', context),
      drawer: NavDrawer(),
      body: SearchFoodBar(),
    );
  }
}

//search 어떻게 구현하누
class SearchFoodBar extends StatefulWidget {
  SearchFoodBar({Key key}) : super(key: key);

  @override
  _SearchFoodBarState createState() => _SearchFoodBarState();
}

class _SearchFoodBarState extends State<SearchFoodBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('search food'),
    );
  }
}
