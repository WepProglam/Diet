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

  Person(
      {this.height,
      this.weight,
      this.bmi,
      this.muscleMass,
      this.purpose,
      this.time});

  Map<String, dynamic> toMap() {
    return {
      "height": height,
      'weight': weight,
      'bmi': bmi,
      'muscleMass': muscleMass,
      'purpose': purpose,
      'time': time
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
      this.selected});

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
      "selected": selected
    };
  }
}

class Diet {
  String dietName;
  String foodCode1;
  String foodCode2;
  String foodCode3;
  String foodCode4;
  String foodCode5;
  String foodCode6;

  Diet(
      {this.dietName,
      this.foodCode1,
      this.foodCode2,
      this.foodCode3,
      this.foodCode4,
      this.foodCode5,
      this.foodCode6});

  Map<String, dynamic> toMap() {
    return {
      "dietName": dietName,
      "foodCode1": foodCode1,
      "foodCode2": foodCode2,
      "foodCode3": foodCode3,
      "foodCode4": foodCode4,
      "foodCode5": foodCode5,
      "foodCode6": foodCode6,
    };
  }
}
