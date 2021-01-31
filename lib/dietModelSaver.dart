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
    num sum = value[0] * 4 + value[1] * 4 + value[2] * 9;
    nutri =
        "${myRounder(value[0] * 4 * 100 / sum)}:${myRounder(value[1] * 4 * 100 / sum)}:${myRounder(value[2] * 9 * 100 / sum)}";
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
  DietHistory dietHistory;



  print("here is formatdiethistory");
  print(dateTime);
  print(kcal);

  final dBHelperDietHistory = DBHelperDietHistory();
  // await dBHelperDietHistory.deleteAllDietHistory();

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
    } else {
      dietHistory = null;
    }
  });

  await isDateCompleted(dateData).then((val) {
    complete = val;
  });



  String completeString = complete == 4 ? "true" : "false";
  if(completeString == "false"){
    completeString = calculatekcalAchieve(dietHistory,num.parse(kcal)) >= 90 ? "true" : "false";
  }

  print("kcal archieve = ${calculatekcalAchieve(dietHistory,num.parse(kcal))}");

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

num calculatekcalAchieve(DietHistory dietHistory,num existKcal) {
  num archieve=0.0;

  num totalCal = 0;
  num car = 0;
  num pro = 0;
  num fat = 0;
  if (dietHistory != null) {
    for (var i = 0; i < 4; i++) {
      switch (i) {
        case 0:
          Map breakfast = jsonDecode(dietHistory.breakFast);
          if (breakfast != "null" && breakfast != null) {
            if (breakfast['isItConfirm'] == "true") {
              totalCal += num.parse(breakfast['kcal']);
              num carRatio =
                  num.parse(breakfast["nutri"].split(":")[0]) / 100;
              num proRatio =
                  num.parse(breakfast["nutri"].split(":")[1]) / 100;
              num fatRatio =
                  num.parse(breakfast["nutri"].split(":")[2]) / 100;

              car += carRatio * num.parse(breakfast['kcal']);
              pro += proRatio * num.parse(breakfast['kcal']);
              fat += fatRatio * num.parse(breakfast['kcal']);
            }
          }
          // print(dietConfirmConfirm);

          break;
        case 1:
          Map lunch = jsonDecode(dietHistory.lunch);
          if (lunch != "null" && lunch != null) {
            if (lunch['isItConfirm'] == "true") {
              totalCal += num.parse(lunch['kcal']);

              num carRatio = num.parse(lunch["nutri"].split(":")[0]) / 100;
              num proRatio = num.parse(lunch["nutri"].split(":")[1]) / 100;
              num fatRatio = num.parse(lunch["nutri"].split(":")[2]) / 100;

              car += carRatio * num.parse(lunch['kcal']);
              pro += proRatio * num.parse(lunch['kcal']);
              fat += fatRatio * num.parse(lunch['kcal']);
            }
          }

          break;
        case 2:
          Map dinner = jsonDecode(dietHistory.dinner);
          if (dinner != "null" && dinner != null) {
            if (dinner['isItConfirm'] == "true") {
              totalCal += num.parse(dinner['kcal']);

              num carRatio = num.parse(dinner["nutri"].split(":")[0]) / 100;
              num proRatio = num.parse(dinner["nutri"].split(":")[1]) / 100;
              num fatRatio = num.parse(dinner["nutri"].split(":")[2]) / 100;

              car += carRatio * num.parse(dinner['kcal']);
              pro += proRatio * num.parse(dinner['kcal']);
              fat += fatRatio * num.parse(dinner['kcal']);
            }
          }

          break;
        case 3:
          Map snack = jsonDecode(dietHistory.snack);
          if (snack != "null" && snack != null) {
            if (snack['isItConfirm'] == "true") {
              totalCal += num.parse(snack['kcal']);

              num carRatio = num.parse(snack["nutri"].split(":")[0]) / 100;
              num proRatio = num.parse(snack["nutri"].split(":")[1]) / 100;
              num fatRatio = num.parse(snack["nutri"].split(":")[2]) / 100;

              car += carRatio * num.parse(snack['kcal']);
              pro += proRatio * num.parse(snack['kcal']);
              fat += fatRatio * num.parse(snack['kcal']);
            }
          }

          break;

        default:
      }
    }


    num correct =
        (1 - ((person.metabolism - (totalCal+existKcal)) / person.metabolism).abs()) *
            100;

    archieve=correct;

  } else {
    archieve=0.0;
  }
// print(monthlyAchieveKcal);
return archieve;
}
