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
  String foodCodes; //'code1, code2, code3 ...'
  String foodMasses; //'mass1, mass2, mass3 ...'

  Diet({
    this.dietName,
    this.foodCodes,
    this.foodMasses,
  });

  Map<String, dynamic> toMap() {
    return {
      "dietName": dietName,
      "foodCodes": foodCodes,
      "foodMasses": foodMasses,
    };
  }
}
