import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class Person {
  var height;
  var weight;
  var bmi;
  var muscleMass;
  var purpose;
  String time;
  num achieve;

  Person(
      {this.height,
      this.weight,
      this.bmi,
      this.muscleMass,
      this.purpose,
      this.time,
      this.achieve});

  Map<String, dynamic> toMap() {
    return {
      "height": height,
      'weight': weight,
      'bmi': bmi,
      'muscleMass': muscleMass,
      'purpose': purpose,
      'time': time,
      'achieve': achieve
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
      this.servingSize});

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
  /*
  {
    "식단 이름" : {
      "음식 코드1" : {
        "foodName" :"음식 이름1",
        "foodMass" : "음식 무게1"
        },
        "음식 코드2" : {
        "foodName" :"음식 이름2",
        "foodMass" : "음식 무게2"
        },
        "음식 코드3" : {
        "foodName" :"음식 이름3",
        "foodMass" : "음식 무게3"
        }
    }
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
