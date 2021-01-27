import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'addDiet.dart';
import 'model.dart';

Future<Diet> formatDiet(
    {String dietName = null,
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
    mealTime = mainPageReturnMealTime(mainPageIndex);
    dietTitle = DateFormat('yyMMdd$mealTime').format(DateTime.now());
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
    nutri = "${value[0]}:${value[1]}:${value[2]}";
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
