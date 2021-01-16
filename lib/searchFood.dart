import 'package:flutter/material.dart';
import 'package:flutter_application_1/model.dart';

import 'db_helper.dart';

class SearchFood extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SearchList();
  }
}

class Building {
  num id; //나중에 바꿔야 함
  String foodName;
  num calories;
  num carbohydrate;
  num protein;
  num fat;

  Building(
      {this.id,
      this.foodName,
      this.calories,
      this.carbohydrate,
      this.protein,
      this.fat});
}

class SearchList extends StatefulWidget {
  SearchList({Key key}) : super(key: key);

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

  final dbHelperFood = DBHelperFood();
  List<Food> foodNameEX = [];
  final dBHelperMyTempoFood = DBHelperMyTempoFood();

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
    await dbHelperFood.getAllMyFood().then((val) {
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
        Building(id: i++, foodName: item.foodName, calories: item.kcal),
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
    "Search Food",
    // style: TextStyle(color: Colors.white),
  );
  Icon actionIcon = Icon(
    Icons.search,
    // color: Colors.orange,
  );

  Widget buildBar(BuildContext context) {
    return AppBar(
        centerTitle: true,
        title: appBarTitle,
        // iconTheme: IconThemeData(color: Colors.orange),
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
                    // style: TextStyle(
                    //   color: Colors.orange,
                    // ),
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
        // color: Colors.orange,
      );
      this.appBarTitle = Text(
        "Search Food",
        // style: TextStyle(color: Colors.white),
      );
      _IsSearching = false;
      _searchQuery.clear();
    });
  }
}

//
class Uiitem extends StatelessWidget {
  final Building building;
  Uiitem(this.building);

  Widget build(BuildContext context) {
    final Map<String, String> args = ModalRoute.of(context).settings.arguments;
    return Card(
      margin: EdgeInsets.all(8),
      color: Colors.white70,
      child: InkWell(
        // splashColor: Colors.orange,
        //여기다 눌렀을 때 기능 넣기
        onTap: () {
          //add Diet 페이지에서 넘어왔을 경우
          // 이거 수정해서 음식 데이터 보낼 거임
          if (args['pre'] == 'addDiet') {
            Navigator.pop(context);
          }
          // 그 외 일반적인 경우
          else {
            print(building.id);
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
