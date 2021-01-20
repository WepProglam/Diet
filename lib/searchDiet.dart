import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/model.dart';

import 'db_helper.dart';
import 'mainStream.dart' as mainStream;

StreamController<String> streamControllerString =
    mainStream.streamControllerString;

class SearchDiet extends StatelessWidget {
  final Stream<List> stream;
  SearchDiet({this.stream});
  @override
  Widget build(BuildContext context) {
    return SearchList(
      streamString: streamControllerString.stream,
    );
  }
}

// class Building {
//   //나중에 바꿔야 함
//   String dietName;
//   String foodInfo;

//   Building({this.dietName, this.foodInfo});
// }

class SearchList extends StatefulWidget {
  final Stream<String> streamString;
  SearchList({Key key, this.streamString}) : super(key: key);

  @override
  _SearchListState createState() => _SearchListState();
}

class _SearchListState extends State<SearchList> {
  final key = GlobalKey<ScaffoldState>();
  final _searchQuery = TextEditingController();
  List<Diet> _list;
  List<Diet> _searchList = List();

  bool _IsSearching = false;
  String _searchText = "";

  final dbHelperDiet = DBHelperDiet();
  List<Diet> dietNameEX = [];

  _SearchListState() {
    _searchQuery.addListener(() {
      if (_searchQuery.text.isEmpty) {
        setState(() {
          _IsSearching = false;
          _searchText = "";
          _buildSearchList();
        });
      } else {
        setState(() {
          _IsSearching = true;
          _searchText = _searchQuery.text;
          _buildSearchList();
        });
      }
    });
  }

  List<Diet> _buildSearchList() {
    if (_searchText.isEmpty) {
      return _searchList = _list;
    } else {
      _searchList = _list
          .where((element) => //여기다가 검색될 요소 추가 가능
              element.dietName
                  .toLowerCase()
                  .contains(_searchText.toLowerCase()))
          .toList();
      // print('${_searchList.length}');
      return _searchList;
    }
  }

  void getInfo() async {
    await dbHelperDiet.getAllMyDiet().then((val) {
      for (var item in val) {
        dietNameEX.add(item);
      }
    });
    setState(() {});
  }

  //init
  @override
  void initState() {
    super.initState();
    _IsSearching = false;
    init();
  }

  //이 함수에서 list 만듦
  void init() async {
    _list = List();
    int i = 1;
    await getInfo();
    for (var item in dietNameEX) {
      _list.add(
        Diet(dietName: item.dietName, foodInfo: item.foodInfo),
      );
    }
    _searchList = _list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFEF5),
      key: key,
      appBar: buildBar(context),
      body: GridView.builder(
        padding: EdgeInsets.all(8),
        itemCount: _searchList.length,
        itemBuilder: (context, index) {
          return Center(
            child: Uiitem(_searchList[index]),
          );
        },
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 5 / 3),
      ),
    );
  }

  Widget appBarTitle = Text(
    "Search Diet",
    style: TextStyle(color: Colors.white),
  );
  Icon actionIcon = Icon(
    Icons.search,
    // color: Colors.orange,
  );

  Widget buildBar(BuildContext context) {
    return AppBar(
        centerTitle: true,
        title: appBarTitle,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF69C2B0),
        actions: <Widget>[
          IconButton(
            icon: actionIcon,
            onPressed: () {
              setState(() {
                if (this.actionIcon.icon == Icons.search) {
                  this.actionIcon = Icon(
                    Icons.close,
                    color: Colors.white,
                  );
                  this.appBarTitle = TextField(
                    controller: _searchQuery,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                        hintText: "Search here..",
                        hintStyle: TextStyle(color: Colors.white)),
                  );
                  _handleSearchStart();
                } else {
                  _handleSearchEnd();
                }
              });
            },
          ),
        ]);
  }

  void _handleSearchStart() {
    setState(
      () {
        _IsSearching = true;
      },
    );
  }

  void _handleSearchEnd() {
    setState(() {
      this.actionIcon = Icon(
        Icons.search,
        color: Colors.white,
      );
      this.appBarTitle = Text(
        "Search Diet",
        style: TextStyle(color: Colors.white),
      );
      _IsSearching = false;
      _searchQuery.clear();
    });
  }
}

//
class Uiitem extends StatefulWidget {
  final Diet diet;
  Uiitem(this.diet);

  @override
  _UiitemState createState() => _UiitemState();
}

class _UiitemState extends State<Uiitem> {
  void reactWhenCalc() {
    // print(widget.diet.toMap());
    Navigator.pop(context, <String, Map>{"myDiet": widget.diet.toMap()});
  }

  void reactWhenAdd() {
    // print(widget.diet.toMap());
    Navigator.pushNamed(context, '/addDiet',
        arguments: <String, Map>{"myTempoDiet": widget.diet.toMap()});
  }

  void react(bool flag) {
    // print(flag);
    if (flag) {
      reactWhenCalc();
    } else {
      reactWhenAdd();
    }
  }

  Widget build(BuildContext context) {
    bool fromCalcDiet = false;

    final Map<String, bool> args = ModalRoute.of(context).settings.arguments;

    if (args != null && args['fromCalcDiet']) {
      fromCalcDiet = true;
    } else {
      fromCalcDiet = false;
    }

    return Card(
      margin: EdgeInsets.all(8),
      color: Colors.white70,
      child: InkWell(
        // splashColor: Colors.orange,
        //여기다 눌렀을 때 기능 넣기
        onTap: () async {
          react(fromCalcDiet);
        },
        child: Center(
          child: Column(
            children: <Widget>[
              Spacer(
                flex: 2,
              ),
              Text(
                widget.diet.dietName,
                style: TextStyle(
                    // fontFamily: 'Raleway',
                    // fontWeight: FontWeight.bold,
                    fontSize: 30),
              ),
              SizedBox(height: 5.0),
              Text(
                // '${this.building.calories}',
                '',
                // style: TextStyle(fontFamily: 'Roboto'),
              ),
              Spacer(
                flex: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
