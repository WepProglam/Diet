import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/model.dart';
import 'package:provider/provider.dart';

import 'db_helper.dart';
import 'mainStream.dart' as mainStream;
import 'package:auto_size_text/auto_size_text.dart';

class DietList extends ChangeNotifier {
  List<Diet> dietNameEX;
  List<Diet> fillteredDiets;

  DietList(this.dietNameEX, this.fillteredDiets);

  getDietList() => dietNameEX;
  setDietList(List<Diet> diets) => dietNameEX = diets;

  getFillteredDietList() => fillteredDiets;
  setFillteredDietList(List<Diet> diets) => fillteredDiets = diets;

  void addDiet(Diet diet) {
    dietNameEX.add(diet);
    notifyListeners();
  }

  void addFillteredDiet(Diet diet) {
    fillteredDiets.add(diet);
    notifyListeners();
  }

  void removeDiet(Diet diet) {
    dietNameEX.removeWhere((element) => element.dietName == diet.dietName);
    notifyListeners();
  }

  void removeFillteredDiet(Diet diet) {
    fillteredDiets.removeWhere((element) => element.dietName == diet.dietName);
    notifyListeners();
  }
}

int mealIndex;
String mealTime;

class SearchDiet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DietList([], []),
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
  List<Diet> fillteredDiet = [];

  bool _Isfilltered = false;

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
      if (_Isfilltered) {
        return _searchList = fillteredDiet;
      } else {
        return _searchList = dietNameEX;
      }
    } else {
      if (_Isfilltered) {
        _searchList = fillteredDiet
            .where((element) => //여기다가 검색될 요소 추가 가능
                element.dietName
                    .toLowerCase()
                    .contains(_searchText.toLowerCase()))
            .toList();

        return _searchList;
      } else {
        _searchList = dietNameEX
            .where((element) => //여기다가 검색될 요소 추가 가능
                element.dietName
                    .toLowerCase()
                    .contains(_searchText.toLowerCase()))
            .toList();

        return _searchList;
      }
    }
  }

  void getInfo() async {
    await dbHelperDiet.getAllMyDiet().then((val) {
      dietNameEX = [];
      fillteredDiet = [];
      for (var item in val) {
        dietNameEX.add(item);

        var splitted = item.dietName.split("-");
        String mayDate = '';

        if (splitted.length == 4) {
          if (splitted[1].length == 1) {
            splitted[1] = '0' + splitted[1];
            if (splitted[2].length == 1) {
              splitted[2] = '0' + splitted[2];
            }
          } else if (splitted[2].length == 1) {
            splitted[2] = '0' + splitted[2];
          }
          mayDate = (splitted[0] + splitted[1] + splitted[2]);
        }
        if (DateTime.tryParse(mayDate) == null) {
          fillteredDiet.add(item);
        }
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
    if (_Isfilltered) {
      _searchList = fillteredDiet;
    } else {
      _searchList = dietNameEX;
    }
    // var splitted = dietNameEX[0].dietName.split("-");
    // if (splitted.length == 4) {
    //   if (splitted[1].length == 1) {
    //     splitted[1] = '0' + splitted[1];
    //     if (splitted[2].length == 1) {
    //       splitted[2] = '0' + splitted[2];
    //     }
    //   } else if (splitted[2].length == 1) {
    //     splitted[2] = '0' + splitted[2];
    //   }
    // }
    // String mayDate = splitted[0] + splitted[1] + splitted[2];
    // print(DateTime.tryParse(mayDate));
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
      // backgroundColor: Colors.black,
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
      // splashColor: Colors.deepOrangeAccent,
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
        // color: Colors.deepOrangeAccent,
      ),
    );
  }

  Widget appBarTitle = Text(
    "Diets",
    // style: TextStyle(color: Colors.white),
  );
  Icon actionIcon = Icon(
    Icons.search,
    // color: Colors.orange,
  );

  var filterColor = Colors.deepOrangeAccent[700];

  Widget buildBar(BuildContext context) {
    return AppBar(centerTitle: true, title: appBarTitle, actions: <Widget>[
      IconButton(
          icon: Icon(Icons.date_range),
          color: filterColor,
          onPressed: () {
            setState(() {
              if (filterColor == Colors.deepOrangeAccent[700]) {
                filterColor = Colors.white;
                _searchList = fillteredDiet;
                setState(() {
                  _Isfilltered = !_Isfilltered;
                });
              } else {
                filterColor = Colors.deepOrangeAccent[700];
                _searchList = dietNameEX;
                setState(() {
                  _Isfilltered = !_Isfilltered;
                });
              }
            });
          }),
      IconButton(
        icon: actionIcon,
        onPressed: () {
          setState(() {
            if (this.actionIcon.icon == Icons.search) {
              this.actionIcon = Icon(
                Icons.close,
                // color: Colors.white,
              );
              this.appBarTitle = TextField(
                // autocorrect: true,
                autofocus: true,
                controller: _searchQuery,
                style: TextStyle(
                    // color: Colors.white,
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
        // color: Colors.white,
      );
      this.appBarTitle = Text(
        "Diets",
        // style: TextStyle(color: Colors.white),
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
    Navigator.pushNamed(context, "/addDiet", arguments: <String, Map>{
      "myTempoDiet": widget.diet.toMap(),
      "pre": {"pre": "searchDiet", "index": mealIndex, "dateTime": mealTime}
    }).then((value) {
      Navigator.pop(context, value);
    });
  }

  void reactWhenAdd() {
    // print(widget.diet.toMap());
    Navigator.pushNamed(context, '/addDiet',
        arguments: <String, Map>{"myTempoDiet": widget.diet.toMap()});
  }

  void react(String whereFrom) {
    // print(flag);
    // print(whereFrom);
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
    final Map<String, Map> args = ModalRoute.of(context).settings.arguments;
    final tempDietInfo = jsonDecode(widget.diet.foodInfo);
    final List nutriRate = tempDietInfo['nutri'].split(':');

    if (args == null) {
    } else if (args['pre']["pre"] == "mainPage") {
      whereFrom = "mainPage";
      // print(args['pre']);
      // print(args['pre'] is Map);
      mealIndex = args['pre']["index"];
      mealTime = args['pre']['dateTime'];
    }

    return Card(
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(20.0),
      // ),
      margin: EdgeInsets.all(8),
      // color: Colors.deepOrangeAccent,
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.deepOrangeAccent[700], width: 2)),
        child: Stack(
          children: [
            InkWell(
              // splashColor: Colors.white,
              //여기다 눌렀을 때 기능 넣기
              onTap: () async {
                react(whereFrom);
              },
              child: Center(
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 40, bottom: 40, left: 8, right: 8),
                        child: AutoSizeText(
                          widget.diet.dietName,
                          // textScaleFactor: 2,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 50,
                              color: Colors.deepOrangeAccent[700],
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            bottom: 20, top: 20, left: 4, right: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AutoSizeText(
                              '${tempDietInfo['kcal'].toStringAsFixed(0)}' +
                                  ' kcal',
                              maxLines: 1,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            AutoSizeText(
                              num.parse(nutriRate[0]).toStringAsFixed(0) +
                                  ' : ' +
                                  num.parse(nutriRate[1]).toStringAsFixed(0) +
                                  ' : ' +
                                  num.parse(nutriRate[2]).toStringAsFixed(0),
                              maxLines: 1,
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            SizedBox(
                              // maxWidth: 20,
                              height: MediaQuery.of(context).size.height / 11,
                              child: ListView.builder(
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    bottom: 8,
                                    left: 8,
                                    right: 8,
                                  ),
                                  itemCount: tempDietInfo['foods'].length,
                                  itemBuilder: (context, int index) {
                                    return Row(
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: AutoSizeText(
                                            tempDietInfo['foods'][index]
                                                ['foodName'],
                                            maxLines: 1,
                                          ),
                                        ),
                                        Container(
                                          child: SizedBox(
                                            width: 3,
                                          ),
                                          // decoration: BoxDecoration(
                                          //     border: Border(
                                          //         right: BorderSide(
                                          //             color: Colors.white,
                                          //             width: 1))),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: AutoSizeText(
                                            tempDietInfo['foods'][index]
                                                        ['foodMass']
                                                    .toStringAsFixed(0) +
                                                'g',
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: InkWell(
                splashColor: Colors.deepOrangeAccent[700],
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
      ),
    );
  }
}
