import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/addDiet.dart';
import 'package:flutter_application_1/model.dart';
// import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import 'db_helper.dart';
import 'mainStream.dart' as mainStream;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:provider/provider.dart';

StreamController<String> streamControllerString =
    mainStream.streamControllerString;

class SelectedFoods extends ChangeNotifier {
  List<String> _selectedFoodsList;

  SelectedFoods(this._selectedFoodsList);

  List<String> getFoods() => _selectedFoodsList;
  setSelectedFoodsList(List<String> foods) => _selectedFoodsList = foods;

  void addSelectedFood(String str) {
    _selectedFoodsList.add(str);
    notifyListeners();
  }

  void removeFood(String str) {
    _selectedFoodsList.remove(str);
    notifyListeners();
  }

  void removeAllFoods() {
    _selectedFoodsList.clear();
    notifyListeners();
  }
}

class SearchFood extends StatelessWidget {
  final Stream<List> stream;
  SearchFood({this.stream});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(
        create: (context) => SelectedFoods([]),
      ),
    ], child: SearchList(streamString: streamControllerString.stream));
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
  SearchList({this.streamString});

  @override
  _SearchListState createState() => _SearchListState();
}

class _SearchListState extends State<SearchList>
    with SingleTickerProviderStateMixin {
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

  int flexVal = 0;
  List<String> selectedFoods = null;
  Widget listView = null;
  var createListViewIcon = Icons.cancel;

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
      // print("end");
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
  void didChangeDependencies() {
    SelectedFoods foodProvider = Provider.of<SelectedFoods>(context);

    if (foodProvider.getFoods().isNotEmpty) {
      setState(() {
        if (listView != null) {
          listView = ListView.separated(
              itemBuilder: (context, int index) {
                return Center(child: Text(selectedFoods[index]));
              },
              separatorBuilder: (context, int index) => const Divider(),
              itemCount: selectedFoods.length);
        }

        selectedFoods = foodProvider.getFoods();
      });
      if (createListViewIcon == Icons.cancel) {
        setState(() {
          createListViewIcon = Icons.arrow_circle_down;
        });
      }
    } else {
      selectedFoods = null;
      listView = null;
    }
    super.didChangeDependencies();
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = FlatButton(
        child: Text("OK"),
        onPressed: () async {
          Navigator.pop(context);
          Navigator.pop(context, codeList);
        });

    Widget noButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("음식 저장"),
      content: Text("담으시겠습니까?"),
      actions: [okButton, noButton],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void handleWillPop(BuildContext context) async {
    if (fromAddDiet) {
      showAlertDialog(context);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> args = ModalRoute.of(context).settings.arguments;
    final SelectedFoods foodProvider = Provider.of<SelectedFoods>(context);

    // print("is searchign $_IsSearching");
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      // backgroundColor: Colors.black,
      appBar: buildBar(context),
      body: Builder(
          builder: (context) => WillPopScope(
                onWillPop: () {
                  handleWillPop(context);
                },
                child: _IsSearching
                    ? GridView.builder(
                        padding: EdgeInsets.all(8),
                        itemCount: foodDBNameEX.length,
                        controller: scrollController,
                        itemBuilder: (context, index) {
                          return Center(
                            child: Uiitem(foodDBNameEX[index]),
                          );
                        },
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, childAspectRatio: 5 / 4),
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
                            crossAxisCount: 2, childAspectRatio: 5 / 4),
                      ),
              )),

      floatingActionButton: (args != null)
          ? ((args['pre'] == 'addDiet')
              ? Column(
                  children: [
                    SizedBox(
                      height: 95,
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.fastLinearToSlowEaseIn,
                      child: Container(
                        // margin: EdgeInsets.only(top: 95),
                        height: flexVal == 0 ? 0 : 200,
                        width: 300,
                        decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border(
                                left: BorderSide(
                                    color: Colors.deepOrangeAccent[700],
                                    width: 1),
                                bottom: BorderSide(
                                    color: Colors.deepOrangeAccent[700],
                                    width: 1),
                                right: BorderSide(
                                    color: Colors.deepOrangeAccent[700],
                                    width: 1))),
                        child: listView,
                      ),
                      vsync: this,
                    ),
                    Material(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(100),
                            bottomRight: Radius.circular(100),
                          ),
                          side: BorderSide(
                              color: Colors.deepOrangeAccent[700], width: 1.2)),
                      child: InkWell(
                        splashColor: Colors.deepOrangeAccent[700],
                        onTap: () {
                          // animation
                          if (flexVal == 0) {
                            if (selectedFoods != null) {
                              setState(() {
                                listView = ListView.separated(
                                    itemBuilder: (context, int index) {
                                      return Center(
                                          child: Text(selectedFoods[index]));
                                    },
                                    separatorBuilder: (context, int index) =>
                                        const Divider(),
                                    itemCount: selectedFoods.length);
                                flexVal = 1;
                              });
                              createListViewIcon = Icons.arrow_circle_up;
                            } else {
                              setState(() {
                                createListViewIcon = Icons.cancel;
                              });
                            }
                            // else {
                            //   setState(() {
                            //     flexVal = 1;
                            //   });

                            //   createListViewIcon = Icons.arrow_circle_up;
                            // }
                          } else {
                            setState(() {
                              listView = null;
                              flexVal = 0;
                            });

                            createListViewIcon = Icons.arrow_circle_down;
                          }
                        },
                        child: Ink(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(100),
                              bottomRight: Radius.circular(100),
                            ),
                          ),
                          child: Icon(
                            createListViewIcon,
                            color: Colors.deepOrangeAccent[700],
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                    Spacer(
                      flex: 2,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.deepOrangeAccent[700], width: 2),
                          borderRadius: BorderRadius.circular(100)),
                      child: FittedBox(
                        alignment: Alignment.bottomCenter,
                        child: FloatingActionButton(

                            // heroTag: null,
                            // backgroundColor: Color(0xFF69C2B0),
                            // focusColor: Color(0xFF69C2B0),
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
                      ),
                    ),
                  ],
                )
              : null)
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget appBarTitle = AutoSizeText(
    // "Search Food",
    "MY FOOD",
    maxLines: 1,
    // style: TextStyle(color: Colors.white),
  );
  Icon actionIcon = Icon(
    Icons.search,
    // color: Colors.orange,
  );

  Widget buildBar(BuildContext context) {
    return AppBar(
        // iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        title: appBarTitle,
        // backgroundColor: Colors.black,
        actions: <Widget>[
          IconButton(
            icon: actionIcon,
            onPressed: () {
              setState(() {
                _IsSearching = !_IsSearching;
                _searchQuery.text = "";

                if (!_IsSearching) {
                  // print("scroll");
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
                          // print(e);
                        });
                        // print(foodList);

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
                          // print(e);
                        });
                        // print(foodList);

                        setState(() {
                          for (var item in foodList) {
                            foodDBNameEX.add(item);
                            // Food(
                            //     code: item.code,
                            //     foodName: item.foodName,
                            //     calories: item.kcal,
                            //     isItFavorite:
                            //         item.isItMine == "T" ? true : false),

                          }
                        });
                      },
                      autofocus: true,
                      // style: TextStyle(
                      //   color: Colors.white,
                      // ),
                      decoration: InputDecoration(
                        hintText: "음식 이름을 입력하세요...",
                      ));
                  // hintStyle: TextStyle(color: Colors.white)));
                } else {
                  this.actionIcon = Icon(
                    Icons.search,
                    // color: Colors.orange,
                  );
                  this.appBarTitle = AutoSizeText(
                    "MY FOOD",
                    maxLines: 1,
                    // style: TextStyle(color: Colors.white),
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
        // color: Colors.white,
      );
      this.appBarTitle = AutoSizeText(
        "Search Food",
        maxLines: 1,
        // style: TextStyle(color: Colors.white),
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

  var materialColor = Colors.black;
  var inkWellSplashColor = Colors.deepOrange[400];

  @override
  Widget build(BuildContext context) {
    final Map<String, String> args = ModalRoute.of(context).settings.arguments;
    final SelectedFoods foodProvider = Provider.of<SelectedFoods>(context);

    return Card(
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(20.0),
      // ),
      margin: EdgeInsets.all(8),

      child: Container(
        decoration: BoxDecoration(
            border:
                Border.all(color: Colors.deepOrangeAccent[700], width: 1.2)),
        child: Stack(
          children: [
            Material(
              color: materialColor,
              child: InkWell(
                splashColor: inkWellSplashColor,
                //여기다 눌렀을 때 기능 넣기
                splashFactory: InkRipple.splashFactory,
                onTap: () {
                  //add Diet 페이지에서 넘어왔을 경우
                  // 이거 수정해서 음식 데이터 보낼 거임
                  if (args != null) {
                    if (args['pre'] == 'addDiet') {
                      streamControllerString.add(building.code);
                      if (!isItSelected) {
                        foodProvider.addSelectedFood(building.foodName);
                        isItSelected = !isItSelected;
                        materialColor = Colors.deepOrangeAccent[700];
                        inkWellSplashColor = Colors.white;
                      } else {
                        foodProvider.removeFood(building.foodName);
                        isItSelected = !isItSelected;
                        materialColor = Colors.black;
                        inkWellSplashColor = Colors.deepOrange[400];
                      }
                      // Future.delayed(Duration(seconds: 1));

                    }
                    // 그 외 일반적인 경우
                    else if (args['pre'] == 'addFood') {
                      Navigator.pop(context, building.code);
                      Navigator.pushNamed(context, '/addFood',
                          arguments: <String, Map>{
                            "myTempoFood": building.toMap()
                          });
                      // print(building.code);
                    } else {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/addFood',
                          arguments: <String, Map>{
                            "myTempoFood": building.toMap()
                          });

                      // print(building.code);
                    }
                  } else {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/addFood',
                        arguments: <String, Map>{
                          "myTempoFood": building.toMap()
                        });

                    // print(building.code);
                  }
                },
                child: Ink(
                  child: Center(
                    child: Column(
                      children: [
                        Spacer(
                          flex: 2,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: AutoSizeText(
                            this.building.foodName,
                            style: TextStyle(
                                fontFamily: 'Raleway',
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                            maxLines: 1,
                          ),
                        ),
                        Spacer(
                          flex: 1,
                        ),
                        AutoSizeText(
                          (this.building.kcal * this.building.servingSize)
                                  .toStringAsFixed(1) +
                              ' kcal',
                          // style: TextStyle(fontFamily: 'Roboto'),
                        ),
                        Spacer(
                          flex: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: GestureDetector(
                child: Icon(
                  Icons.favorite,
                  color: this.building.isItMine == "T"
                      ? Colors.deepOrangeAccent[400]
                      : null,
                  size: 20,
                ),
                onTap: () async {
                  setState(() {
                    this.building.isItMine =
                        this.building.isItMine == "T" ? "F" : "T";
                  });
                  Food food = await dbHelperFood.getFood(this.building.code);
                  food.isItMine = this.building.isItMine == "T" ? "T" : "F";
                  await dbHelperFood.updateFood(food);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
