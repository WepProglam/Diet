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
