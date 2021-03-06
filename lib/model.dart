import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class RecentSubmit {
  String datetime;

  RecentSubmit({this.datetime});

  Map<String, String> toMap() {
    return ({"datetime": datetime});
  }
}

class Person {
  num height;
  num weight;
  num bmi;
  num muscleMass;
  num purpose;
  String time; //2021-01-28
  num achieve;

  num metabolism; //총 에너지 대사량
  num activity; //1, 2, 3, 4, 5, 6

  num weightTarget;
  num bmiTarget;
  num muscleTarget;

  num sex; //0 남자 1 여자
  num age;

  Person(
      {this.height,
      this.weight,
      this.bmi,
      this.muscleMass,
      this.purpose,
      this.time,
      this.achieve,
      this.metabolism,
      this.activity,
      this.weightTarget,
      this.bmiTarget,
      this.muscleTarget,
      this.sex,
      this.age});

  Map<String, dynamic> toMap() {
    return {
      "height": height,
      'weight': weight,
      'bmi': bmi,
      'muscleMass': muscleMass,
      'purpose': purpose,
      'time': time,
      'achieve': achieve,
      'metabolism': metabolism,
      'activity': activity,
      'weightTarget': weightTarget,
      'bmiTarget': bmiTarget,
      'muscleTarget': muscleTarget,
      'sex': sex,
      'age': age
    };
  }
}

class Food {
  String code;
  String dbArmy;
  String foodName;
  String foodKinds;
  String isItMine;

  num kcal;
  num protein;
  num carbohydrate;
  num fat;
  num selected;
  num servingSize;

  Food(
      {this.code,
      this.dbArmy,
      this.foodName,
      this.foodKinds,
      this.kcal,
      this.protein,
      this.carbohydrate,
      this.fat,
      this.isItMine,
      this.selected,
      this.servingSize,
      age});

  Map<String, dynamic> toMap() {
    return {
      "code": code,
      "dbArmy": dbArmy,
      "foodName": foodName,
      "foodKinds": foodKinds,
      "kcal": kcal,
      "protein": protein,
      "carbohydrate": carbohydrate,
      "fat": fat,
      "isItMine": isItMine,
      "selected": selected,
      "servingSize": servingSize
    };
  }
}

class Diet {
  String dietName;
  String foodInfo;
  //일치율 추가 해야함
  /*
  {
    "kcal" : "식단의 칼로리(num 형태로)",
    "nutri" : "탄단지 비율(string으로 5:2:3)",
    "foods" : [
        { 
        "code" : "음식 코드1",
        "foodName" :"음식 이름1",
        "foodMass" : "음식 무게1"
        },
         { 
        "code" : "음식 코드2",0+
        "foodName" :"음식 이름2",
        "foodMass" : "음식 무게2"
        },
         { 
        "code" : "음식 코드3",
        "foodName" :"음식 이름3",
        "foodMass" : "음식 무게3"
        }
    ]
  }
  */

  Diet({
    this.dietName,
    this.foodInfo,
  });

  Map<String, dynamic> toMap() {
    return {"dietName": dietName, "foodInfo": foodInfo};
  }
}

class DietHistory {
  String date; //2020-01-30
  String breakFast;
  String lunch;
  String dinner;
  String snack;
  int year; //2021
  int month; //1 9 10
  String complete; //"true" "false"

  /*
  breakfast 예시
  {
    "isItConfirm" : "true", => 확정인가 아닌가
    "dietName" : "식단 이름",
    "kcal" : "칼로리",
    "nutri" : "영양소 비율"(5:2:3),
  }
  */
  DietHistory(
      {this.date,
      this.breakFast,
      this.lunch,
      this.dinner,
      this.snack,
      this.year,
      this.month,
      this.complete});
  Map<String, dynamic> toMap() {
    return {
      "date": date,
      "breakFast": breakFast,
      "lunch": lunch,
      "dinner": dinner,
      "snack": snack,
      "year": year,
      "month": month,
      "complete": complete
    };
  }
}
