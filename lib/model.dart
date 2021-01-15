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
