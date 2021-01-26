import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/model.dart';

import 'db_helper.dart';
import 'mainStream.dart' as mainStream;

StreamController<String> streamControllerString =
    mainStream.streamControllerString;

class SearchFood extends StatelessWidget {
  final Stream<List> stream;
  SearchFood({this.stream});
  @override
  Widget build(BuildContext context) {
    return SearchList(
      streamString: streamControllerString.stream,
    );
  }
}

class Building {
  String code; //나중에 바꿔야 함
  String foodName;
  num calories;
  num carbohydrate;
  num protein;
  num fat;

  Building(
      {this.code,
      this.foodName,
      this.calories,
      this.carbohydrate,
      this.protein,
      this.fat});
}

class SearchList extends StatefulWidget {
  final Stream<String> streamString;
  SearchList({Key key, this.streamString}) : super(key: key);

  @override
  _SearchListState createState() => _SearchListState();
}

class _SearchListState extends State<SearchList> {
  final key = GlobalKey<ScaffoldState>();
  final _searchQuery = TextEditingController();
  List<Building> _list;
  List<Building> _searchList = List();
  bool _IsSearching = false;
  String _searchText = "";
  List<String> codeList = [];
  bool fromAddDiet = false;

  final dbHelperFood = DBHelperFood();
  List<Food> foodNameEX = [];

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

  List<Building> _buildSearchList() {
    if (_searchText.isEmpty) {
      return _searchList = _list;
    } else {
      _searchList = _list
          .where((element) => //여기다가 검색될 요소 추가 가능
              element.foodName
                  .toLowerCase()
                  .contains(_searchText.toLowerCase()))
          .toList();
      print('${_searchList.length}');
      return _searchList;
    }
  }

  void getInfo() async {
    await dbHelperFood.getAllFood().then((val) {
      //한번에 다 읽지말고 인덱스 설정해서 읽어오는 기능 필요
      for (var item in val) {
        foodNameEX.add(item);
      }
    });
    setState(() {});
  }

  //init
  @override
  initState() {
    _IsSearching = false;
    init();
    widget.streamString.listen((code) {
      fromAddDiet = true;
      if (codeList.contains(code)) {
        codeList.removeWhere((item) => item == code);
      } else {
        codeList.add(code);
      }
    });
    super.initState();
  }

  //이 함수에서 list 만듦
  void init() async {
    _list = List();
    int i = 1;
    await getInfo();
    for (var item in foodNameEX) {
      print(item);
      _list.add(
        Building(code: item.code, foodName: item.foodName, calories: item.kcal),
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
      floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xFF69C2B0),
          focusColor: Color(0xFF69C2B0),
          child: Icon(Icons.done),
          onPressed: () {
            // print(codeList);
            if (fromAddDiet) {
              Navigator.pop(context, codeList);
            } else {
              Navigator.pop(context);
            }
          }

          //print(_heightController.text);
          ),
    );
  }

  Widget appBarTitle = Text(
    "Search Food",
    style: TextStyle(color: Colors.white),
  );
  Icon actionIcon = Icon(
    Icons.search,
    // color: Colors.orange,
  );

  Widget buildBar(BuildContext context) {
    return AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        title: appBarTitle,
        backgroundColor: Color(0xFF69C2B0),
        actions: <Widget>[
          IconButton(
            icon: actionIcon,
            onPressed: () {
              setState(() {
                if (this.actionIcon.icon == Icons.search) {
                  this.actionIcon = Icon(
                    Icons.close,
                    // color: Colors.orange,
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
        "Search Food",
        style: TextStyle(color: Colors.white),
      );
      _IsSearching = false;
      _searchQuery.clear();
    });
  }
}

class Uiitem extends StatefulWidget {
  final Building building;
  Uiitem(this.building);
  @override
  _UiitemState createState() => _UiitemState(building);
}

class _UiitemState extends State<Uiitem> {
  final Building building;
  _UiitemState(this.building);
  bool isItSelected = false;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> args = ModalRoute.of(context).settings.arguments;
    return Card(
      margin: EdgeInsets.all(8),
      color: isItSelected ? Colors.green : Colors.white70,
      child: InkWell(
        // splashColor: Colors.orange,
        //여기다 눌렀을 때 기능 넣기
        onTap: () {
          //add Diet 페이지에서 넘어왔을 경우
          // 이거 수정해서 음식 데이터 보낼 거임
          if (args['pre'] == 'addDiet') {
            streamControllerString.add(building.code);
            setState(() {
              isItSelected = !isItSelected;
            });
          }
          // 그 외 일반적인 경우
          else {
            print(building.code);
          }
        },
        child: Center(
          child: Column(
            children: <Widget>[
              Spacer(
                flex: 2,
              ),
              Text(
                this.building.foodName,
                style: TextStyle(
                    // fontFamily: 'Raleway',
                    // fontWeight: FontWeight.bold,
                    fontSize: 30),
              ),
              SizedBox(height: 5.0),
              Text(
                '${this.building.calories}',
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
//
