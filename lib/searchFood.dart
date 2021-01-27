import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/addDiet.dart';
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

/* class Building {
  String code; //나중에 바꿔야 함
  String foodName;
  num calories;
  num carbohydrate;
  num protein;
  num fat;
  bool isItFavorite;

  Building(
      {this.code,
      this.foodName,
      this.calories,
      this.carbohydrate,
      this.protein,
      this.fat,
      this.isItFavorite});
} */

class SearchList extends StatefulWidget {
  final Stream<String> streamString;
  SearchList({Key key, this.streamString}) : super(key: key);

  @override
  _SearchListState createState() => _SearchListState();
}

class _SearchListState extends State<SearchList> {
  final key = GlobalKey<ScaffoldState>();
  final _searchQuery = TextEditingController();
  List<Food> _list;

  List<Food> _searchList = List();

  bool _IsSearching = false;
  String _searchText = "";
  List<String> codeList = [];
  bool fromAddDiet = false;
  int offset = 0;
  final ScrollController scrollController = ScrollController();

  final dbHelperFood = DBHelperFood();
  List<Food> foodNameEX = [];
  List<Food> foodDBNameEX = [];

  // _SearchListState() {
  //   _searchQuery.addListener(() async {
  //     print("listen");

  //     if (_searchQuery.text.isEmpty) {
  //       setState(() {
  //         _searchText = "";
  //       });
  //     } else {}
  //   });
  // }

  void getInfo() async {
    if (offset == 0) {
      await dbHelperFood.getAllMyFood().then((val) {
        for (var item in val) {
          foodNameEX.add(item);
        }
      });
    }
    await dbHelperFood.getLimitFood(offset, 50).then((val) {
      for (var item in val) {
        foodNameEX.add(item);
      }
    });
    init();
  }

  _scrollListener() async {
    if (scrollController.offset >=
            scrollController.position.maxScrollExtent * 0.6 &&
        !scrollController.position.outOfRange) {
      print("end");
      offset += 50;
      await getInfo();
    }
  }

  //init
  @override
  initState() {
    _IsSearching = false;
    getInfo();
    offset = 0;
    scrollController.addListener(_scrollListener);
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
    _list = [];
    _searchList = [];
    for (var item in foodNameEX) {
      await _list.add(item);
      //   Food(
      //       code: item.code,
      //       foodName: item.foodName,
      //       calories: item.kcal,
      //       isItFavorite: item.isItMine == "T" ? true : false),
      // );
    }
    setState(() {
      _searchList = _list;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> args = ModalRoute.of(context).settings.arguments;
    print("is searchign $_IsSearching");
    return Scaffold(
        backgroundColor: Color(0xFFFFFEF5),
        appBar: buildBar(context),
        body: _IsSearching
            ?
            // Column(children: [
            //     for (var item in foodDBNameEX) Text("${item.foodName}")
            //   ])
            GridView.builder(
                padding: EdgeInsets.all(8),
                itemCount: foodDBNameEX.length,
                controller: scrollController,
                itemBuilder: (context, index) {
                  return Center(
                    child: Uiitem(foodDBNameEX[index]),
                  );
                },
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 5 / 3),
              )
            : GridView.builder(
                padding: EdgeInsets.all(8),
                itemCount: _searchList.length,
                controller: scrollController,
                itemBuilder: (context, index) {
                  return Center(
                    child: Uiitem(_searchList[index]),
                  );
                },
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 5 / 3),
              ),
        floatingActionButton: (args != null)
            ? ((args['pre'] == 'addDiet')
                ? FloatingActionButton(
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
                    )
                : null)
            : null);
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
        key: key,
        title: appBarTitle,
        backgroundColor: Color(0xFF69C2B0),
        actions: <Widget>[
          IconButton(
            icon: actionIcon,
            onPressed: () {
              setState(() {
                _IsSearching = !_IsSearching;
                _searchQuery.text = "";

                if (!_IsSearching) {
                  print("scroll");
                  init();

                  scrollController.jumpTo(
                    scrollController.position.maxScrollExtent,
                  );
                } else {
                  init();
                }

                if (this.actionIcon.icon == Icons.search) {
                  this.actionIcon = Icon(
                    Icons.close,
                    // color: Colors.orange,
                  );
                  this.appBarTitle = TextField(
                      controller: _searchQuery,
                      onEditingComplete: () async {
                        List<Food> foodList = [];
                        List<int> foodListIndex = [];
                        List<Food> favoriteFood = [];
                        List<Food> notFavoriteFood = [];
                        foodDBNameEX = [];
                        _searchList = [];
                        await dbHelperFood
                            .filterFoods(_searchQuery.value.text.toString(),
                                limit: 50)
                            .then((value) async {
                          favoriteFood.addAll(
                              value.where((item) => item.isItMine == "T"));
                          notFavoriteFood.addAll(
                              value.where((item) => item.isItMine == "F"));
                          for (var item in favoriteFood) {
                            foodListIndex.add(item.selected);
                            foodListIndex.sort((b, a) => a.compareTo(b));
                            var index = foodListIndex.indexOf(item.selected);
                            foodList.insert(index, item);
                          }
                          for (var item in notFavoriteFood) {
                            foodList.add(item);
                          }
                        }, onError: (e) {
                          print(e);
                        });
                        print(foodList);

                        setState(() {
                          for (var item in foodList) {
                            foodDBNameEX.add(item
                                // Food(
                                //     code: item.code,
                                //     foodName: item.foodName,
                                //     calories: item.kcal,
                                //     isItFavorite:
                                //         item.isItMine == "T" ? true : false),
                                );
                          }
                        });
                      },
                      onChanged: (text) async {
                        List<Food> foodList = [];
                        List<int> foodListIndex = [];
                        List<Food> favoriteFood = [];
                        List<Food> notFavoriteFood = [];
                        foodDBNameEX = [];
                        _searchList = [];
                        await dbHelperFood
                            .filterFoods(text.toString(), limit: 50)
                            .then((value) async {
                          favoriteFood.addAll(
                              value.where((item) => item.isItMine == "T"));
                          notFavoriteFood.addAll(
                              value.where((item) => item.isItMine == "F"));
                          for (var item in favoriteFood) {
                            foodListIndex.add(item.selected);
                            foodListIndex.sort((b, a) => a.compareTo(b));
                            var index = foodListIndex.indexOf(item.selected);
                            foodList.insert(index, item);
                          }
                          for (var item in notFavoriteFood) {
                            foodList.add(item);
                          }
                        }, onError: (e) {
                          print(e);
                        });
                        print(foodList);

                        setState(() {
                          for (var item in foodList) {
                            foodDBNameEX.add(item
                                // Food(
                                //     code: item.code,
                                //     foodName: item.foodName,
                                //     calories: item.kcal,
                                //     isItFavorite:
                                //         item.isItMine == "T" ? true : false),
                                );
                          }
                        });
                      },
                      autofocus: true,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                          hintText: "Search here..",
                          hintStyle: TextStyle(color: Colors.white)));
                } else {
                  this.actionIcon = Icon(
                    Icons.search,
                    // color: Colors.orange,
                  );
                  this.appBarTitle = Text(
                    "Search Food",
                    style: TextStyle(color: Colors.white),
                  );
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
  final Food building;
  Uiitem(this.building);
  @override
  _UiitemState createState() => _UiitemState(building);
}

class _UiitemState extends State<Uiitem> {
  final Food building;
  _UiitemState(this.building);
  bool isItSelected = false;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> args = ModalRoute.of(context).settings.arguments;
    return Card(
        margin: EdgeInsets.all(8),
        color: isItSelected ? Colors.green : Colors.white70,
        child: Stack(
          children: [
            InkWell(
              // splashColor: Colors.orange,
              //여기다 눌렀을 때 기능 넣기
              onTap: () {
                //add Diet 페이지에서 넘어왔을 경우
                // 이거 수정해서 음식 데이터 보낼 거임
                if (args != null) {
                  if (args['pre'] == 'addDiet') {
                    streamControllerString.add(building.code);
                    setState(() {
                      isItSelected = !isItSelected;
                    });
                  }
                  // 그 외 일반적인 경우
                  else if (args['pre'] == 'addFood') {
                    Navigator.pop(context, building.code);
                    print(building.code);
                  } else {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/addFood',
                        arguments: <String, Map>{
                          "myTempoFood": building.toMap()
                        });

                    print(building.code);
                  }
                } else {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/addFood',
                      arguments: <String, Map>{
                        "myTempoFood": building.toMap()
                      });

                  print(building.code);
                }
              },
              child: Center(
                child: Column(
                  children: [
                    Spacer(
                      flex: 1,
                    ),
                    Text(
                      this.building.foodName,
                      style: TextStyle(
                          // fontFamily: 'Raleway',
                          // fontWeight: FontWeight.bold,
                          fontSize: 25),
                      maxLines: 1,
                    ),
                    Spacer(
                      flex: 1,
                    ),
                    Text(
                      '${this.building.kcal}',
                      // style: TextStyle(fontFamily: 'Roboto'),
                    ),
                    Spacer(
                      flex: 1,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 5,
              left: 5,
              child: GestureDetector(
                child: Icon(
                  Icons.favorite,
                  color: this.building.isItMine == "T" ? Colors.red : null,
                  size: 20,
                ),
                onTap: () async {
                  setState(() {
                    this.building.isItMine =
                        this.building.isItMine == "T" ? "F" : "T";
                  });
                  Food food;
                  await dbHelperFood.getFood(this.building.code).then((val) {
                    food = val;
                  });
                  food.isItMine = this.building.isItMine == "T" ? "T" : "F";
                  dbHelperFood.updateFood(food);
                },
              ),
            ),
          ],
        )

        /* FlatButton(
                      child: Icon(
                        Icons.favorite,
                        color:
                            this.building.isItMine == "T" ? Colors.red : null,
                        size: 25,
                      ),
                      onPressed: () async {
                        setState(() {
                          this.building.isItMine =
                              this.building.isItMine == "T" ? "F" : "T";
                        });
                        Food food;
                        await dbHelperFood
                            .getFood(this.building.code)
                            .then((val) {
                          food = val;
                        });
                        food.isItMine =
                            this.building.isItMine == "T" ? "T" : "F";
                        dbHelperFood.updateFood(food);
                      },
                    ), */

        );
  }
}
