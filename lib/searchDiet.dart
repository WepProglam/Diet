import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/model.dart';
import 'package:provider/provider.dart';

import 'db_helper.dart';
import 'mainStream.dart' as mainStream;

class DietList extends ChangeNotifier {
  List<Diet> dietNameEX;

  DietList(this.dietNameEX);

  getDietList() => dietNameEX;
  setDietList(List<Diet> diets) => dietNameEX = diets;

  void addDiet(Diet diet) {
    dietNameEX.add(diet);
    notifyListeners();
  }

  void removeDiet(Diet diet) {
    dietNameEX.removeWhere((element) => element.dietName == diet.dietName);
    notifyListeners();
  }
}

class SearchDiet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DietList([]),
      child: SearchList(),
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
  SearchList({Key key}) : super(key: key);

  @override
  _SearchListState createState() => _SearchListState();
}

class _SearchListState extends State<SearchList> {
  // final DietList listProvider = Provider.of<DietList>(context);
  final key = GlobalKey<ScaffoldState>();
  final _searchQuery = TextEditingController();
  // List<Diet> _list;
  List<Diet> _searchList = List();
  List<Diet> dietNameEX = [];

  bool _IsSearching = false;
  String _searchText = "";

  final dbHelperDiet = DBHelperDiet();

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
      return _searchList = dietNameEX;
    } else {
      _searchList = dietNameEX
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
      dietNameEX = [];
      for (var item in val) {
        dietNameEX.add(item);
      }
    });
    setState(() {});
  }

  //이 함수에서 list 만듦
  void init() async {
    // _list = List();
    // int i = 1;
    await getInfo();
    // _list.addAll(dietNameEX);
    // for (var item in dietNameEX) {
    //   _list.add(
    //     Diet(dietName: item.dietName, foodInfo: item.foodInfo),
    //   );
    // }
    _searchList = dietNameEX;
  }

  //init
  @override
  void initState() {
    super.initState();
    _IsSearching = false;
    init();
  }

  @override
  void didChangeDependencies() {
    init();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final DietList listProvider = Provider.of<DietList>(context);
    listProvider.setDietList(dietNameEX);

    return Scaffold(
      backgroundColor: Colors.black,
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
            crossAxisCount: 2, childAspectRatio: 4 / 6),
      ),
      floatingActionButton: add(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget add() {
    return FloatingActionButton(
      splashColor: Colors.deepOrangeAccent,
      heroTag: null,
      onPressed: () {
        //이거 addDiet로 바꿔야 함
        Navigator.pop(context);
        Navigator.pushNamed(context, '/addDiet');
      },
      tooltip: 'Add',
      child: Icon(
        Icons.add,
        size: 40,
        color: Colors.deepOrangeAccent,
      ),
    );
  }

  Widget appBarTitle = Text(
    "Diets",
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
        // backgroundColor: Color(0xFF69C2B0),
        backgroundColor: Colors.black,
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
                    // autocorrect: true,
                    autofocus: true,
                    controller: _searchQuery,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                        hintText: "식단 이름을 입력하세요...",
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
        "Diets",
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
  final dbHelperDiet = DBHelperDiet();
  String whereFrom = null;

  void reactWhenCalc() {
    // print(widget.diet.toMap());
    Navigator.pop(context, <String, Map>{"myDiet": widget.diet.toMap()});
  }

  void reactWhenMain() {
    // print(widget.diet.toMap());
    Navigator.pop(context, widget.diet.toMap());
  }

  void reactWhenAdd() {
    // print(widget.diet.toMap());
    Navigator.pushNamed(context, '/addDiet',
        arguments: <String, Map>{"myTempoDiet": widget.diet.toMap()});
  }

  void react(String whereFrom) {
    // print(flag);
    print(whereFrom);
    if (whereFrom == "calcDiet") {
      reactWhenCalc();
    } else if (whereFrom == "mainPage") {
      reactWhenMain();
    } else {
      reactWhenAdd();
    }
  }

  Widget build(BuildContext context) {
    final DietList listProvider = Provider.of<DietList>(context);
    final Map<String, String> args = ModalRoute.of(context).settings.arguments;

    if (args == null) {
    } else if (args['pre'] == "calcDiet") {
      whereFrom = "calcDiet";
    } else if (args['pre'] == "mainPage") {
      whereFrom = "mainPage";
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      margin: EdgeInsets.all(8),
      color: Colors.deepOrangeAccent,
      child: Stack(
        children: [
          InkWell(
            splashColor: Colors.white,
            //여기다 눌렀을 때 기능 넣기
            onTap: () async {
              react(whereFrom);
            },
            child: Center(
              child: Text(
                widget.diet.dietName,
                textScaleFactor: 1.5,
                maxLines: 1,
                // style: TextStyle(fontSize: 30),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: () async {
                await dbHelperDiet.deleteDiet(widget.diet.dietName);
                listProvider.removeDiet(widget.diet);
                // dietNameEX.removeWhere(
                //     (item) => item.dietName == widget.diet.dietName);
                // );
              },
              child: Icon(
                Icons.delete,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
