import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/db_helper.dart';
import 'package:intl/intl.dart';

import 'addDiet.dart';
import 'model.dart';

Future<Diet> formatDiet(
    {String dietName = null,
    String dietDateName,
    List foodList,
    int mainPageIndex = null,
    List massList}) async {
  Diet diet;
  String mealTime;
  String dietTitle;
  Map foodInfo = {'foods': []};
  num totalCalorie = 0.0;
  List<num> foodMass = massList;

  if (dietName == null && mainPageIndex == null) {
    // 있을 수 없는 경우(saveddiet에선 무조건 식단 이름입력)
    return null;
  } else if (dietName == null && mainPageIndex is int) {
    print(dietName);
    print(mainPageIndex);
    mealTime = mainPageReturnMealTime(mainPageIndex);
    dietTitle = dietDateName + '-' + mealTime;
  } else if (dietName != null) {
    dietTitle = dietName;
  }

  await getFoodInfo(foodList).then((val) {
    for (var i = 0; i < foodList.length; i++) {
      totalCalorie += foodMass[i] * val[i].kcal;
      foodInfo['foods'].add({
        "code": val[i].code,
        "foodName": foodList[i].foodName,
        "foodMass": foodMass[i]
      });
    }
  });

  foodInfo['kcal'] = totalCalorie;
  String nutri;
  await justCalNutri(foodList, foodMass).then((value) {
    num sum = value[0] + value[1] + value[2];
    nutri =
        "${myRounder(value[0] * 100 / sum)}:${myRounder(value[1] * 100 / sum)}:${myRounder(value[2] * 100 / sum)}";
  });
  foodInfo['nutri'] = nutri;

  diet = Diet(dietName: dietTitle, foodInfo: jsonEncode(foodInfo));

  return diet;
}

String mainPageReturnMealTime(int index) {
  String returnValue;
  switch (index) {
    case 0:
      returnValue = "B";
      break;
    case 1:
      returnValue = "L";
      break;
    case 2:
      returnValue = "D";
      break;
    case 3:
      returnValue = "S";
      break;
    default:
      returnValue = " ";
  }
  return returnValue;
}

Future<List<Food>> getFoodInfo(List<ListContents> foodList) async {
  List<Food> foods = [];
  for (var i = 0; i < foodList.length; i++) {
    Food food = await dbHelperFood.getFood(foodList[i].code);
    foods.add(food);
  }

  return foods;
}

Future<List<num>> justCalNutri(
    List<ListContents> foodList, List<num> mass) async {
  num carbohydrate = 0.0;
  num protein = 0.0;
  num fat = 0.0;

  print("*" * 100);
  print(foodList.length);
  print(mass.length);
  print("*" * 100);
  for (var i = 0; i < foodList.length; i++) {
    Food food = await dbHelperFood.getFood(foodList[i].code);
    print(mass[i]);
    if (mass[i] == null || mass.length - 1 < i) {
      mass[i] = 0;
    }
    carbohydrate += food.carbohydrate * mass[i];
    protein += food.protein * mass[i];
    fat += food.fat * mass[i];
  }
  return [carbohydrate, protein, fat];
}

String myRounder(num a) {
  return a.toString().length < 4 ? a.toString() : a.toString().substring(0, 4);
}

Future<void> formatDietHistory(
    {String dietName,
    String kcal,
    String nutri,
    int flag,
    String dateTime,
    String isItConfirm}) async {
  String dateData;
  String myBreakFast = "null";
  String myLunch = "null";
  String myDinner = "null";
  String mySnack = "null";

  print("here is formatdiethistory");
  print(dateTime);
  print(kcal);

  final dBHelperDietHistory = DBHelperDietHistory();
  // await dBHelperDietHistory.deleteAllDietHistory();
  DietHistory dietHistory;
  dateData = dateTime;
  int year = num.parse(dateTime.split('-')[0]);
  int month = num.parse(dateTime.split('-')[1]);
  print(year);
  print(month);
  print(isItConfirm);
  int complete = 0;
  if (flag == 0) {
    myBreakFast = jsonEncode({
      "dietName": dietName,
      "kcal": kcal,
      "nutri": nutri,
      "isItConfirm": isItConfirm
    });
  } else if (flag == 1) {
    myLunch = jsonEncode({
      "dietName": dietName,
      "kcal": kcal,
      "nutri": nutri,
      "isItConfirm": isItConfirm
    });
  } else if (flag == 2) {
    myDinner = jsonEncode({
      "dietName": dietName,
      "kcal": kcal,
      "nutri": nutri,
      "isItConfirm": isItConfirm
    });
  } else if (flag == 3) {
    mySnack = jsonEncode({
      "dietName": dietName,
      "kcal": kcal,
      "nutri": nutri,
      "isItConfirm": isItConfirm
    });
  }

  await dBHelperDietHistory.getDietHistory(dateData).then((val) {
    if (val != null) {
      dietHistory = val;
      // dietHistory.year = year == null ? dietHistory.year : year;
      // dietHistory.month = month == null ? dietHistory.month : month;
      print("readdb");
      print(val.year);
      print("readdb");
    } else {
      dietHistory = null;
    }
  });

  await isDateCompleted(dateData).then((val) {
    complete = val;
  });

  String completeString = complete == 4 ? "true" : "false";

  if (dietHistory != null) {
    print("sadfasdfasd");
    if (flag == 0) {
      dietHistory.breakFast = myBreakFast;
    } else if (flag == 1) {
      dietHistory.lunch = myLunch;
    } else if (flag == 2) {
      dietHistory.dinner = myDinner;
    } else if (flag == 3) {
      dietHistory.snack = mySnack;
    }
    print("update");
    dietHistory.complete = completeString;
    print(dietHistory.year);

    await dBHelperDietHistory.updateDietHistory(dietHistory);
  } else {
    print("123423423432");
    print("rwriteb");
    print(year);
    print("rwriteb");

    dietHistory = DietHistory(
        date: dateData,
        breakFast: myBreakFast,
        lunch: myLunch,
        dinner: myDinner,
        snack: mySnack,
        year: year,
        month: month,
        complete: completeString);

    await dBHelperDietHistory.createData(dietHistory);
  }
}

Future<int> isDateCompleted(String dateTime) async {
  final dBHelperDietHistory = DBHelperDietHistory();
  DietHistory diteHistory;
  Map dietHistoryMap = {};
  await dBHelperDietHistory.getDietHistory(dateTime).then((val) {
    if (val != null) {
      diteHistory = val;
      dietHistoryMap = diteHistory.toMap();
      print(dietHistoryMap);
    } else {
      diteHistory = null;
    }
  });
  int tag = 0;

  if (diteHistory == null) {
    return 0;
  } else {
    if (dietHistoryMap.containsKey("breakFast")) {
      if (dietHistoryMap["breakFast"] != "null") {
        tag += 1;
      }
    }
    if (dietHistoryMap.containsKey("lunch")) {
      if (dietHistoryMap["lunch"] != "null") {
        tag += 1;
      }
    }
    if (dietHistoryMap.containsKey("dinner")) {
      if (dietHistoryMap["dinner"] != "null") {
        tag += 1;
      }
    }
    if (dietHistoryMap.containsKey("snack")) {
      if (dietHistoryMap["snack"] != "null") {
        tag += 1;
      }
    }
  }

  print("this is tag");
  print(tag);

  return tag;
}
