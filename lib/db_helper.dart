import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'model.dart';

final String dBName = 'Diet';

class DBHelperPerson {
  final String tableName = 'Person';
  DBHelperPerson._();
  static final DBHelperPerson _db = DBHelperPerson._();
  factory DBHelperPerson() => _db;

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, '$dBName.db');

    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
          CREATE TABLE $tableName(
            height REAL,
            weight REAL,
            bmi REAL,
            muscleMass REAL,
            purpose INTEGER,
            time TEXT
            )
        ''');
    }, onUpgrade: (db, oldVersion, newVersion) {});
  }

  createHelper(Person person) {
    getAllPerson().then((value) {
      print(value.isNotEmpty);
      if (value.isNotEmpty) {
        if (value.last.time == person.time) {
          return null;
        } else {
          createData(person);
        }
      } else {
        createData(person);
      }
    }, onError: (e) {
      createData(person);
    });
  }

  //Create
  createData(Person person) async {
    final db = await database;
    await db.insert(
      tableName,
      person.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //Read
  getPerson(int id) async {
    final db = await database;
    var res = await db.rawQuery('SELECT * FROM $tableName WHERE id = $id');
    return res.isNotEmpty
        ? Person(
            height: res.first['height'],
            weight: res.first['weight'],
            bmi: res.first['bmi'],
            muscleMass: res.first['muscleMass'],
            purpose: res.first['purpose'],
            time: res.first['time'])
        : Null;
  }

  //Read All
  Future<List<Person>> getAllPerson() async {
    final db = await database;
    var res = await db.rawQuery('SELECT * FROM $tableName');
    List<Person> list = res.isNotEmpty
        ? res
            .map(
              (c) => Person(
                  height: c['height'],
                  weight: c['weight'],
                  bmi: c['bmi'],
                  muscleMass: c['muscleMass'],
                  purpose: c['purpose'],
                  time: c['time']),
            )
            .toList()
        : [];

    return list;
  }

  //Delete
  deletePerson(int id) async {
    final db = await database;
    var res = db.rawDelete('DELETE FROM $tableName WHERE id = ?', [id]);
    return res;
  }

  //Delete All
  deleteAllPerson() async {
    final db = await database;
    db.rawDelete('DELETE FROM $tableName');
  }
}

class DBHelperFood {
  final String tableName = 'Food';
  DBHelperFood._();
  static final DBHelperFood _db = DBHelperFood._();
  factory DBHelperFood() => _db;

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, '$dBName.db');

    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
          CREATE TABLE $tableName(
            code TEXT,
            dbArmy TEXT,
            foodName TEXT,
            foodKinds TEXT,
            kcal REAL,
            protein REAL,
            carbohydrate REAL,
            fat REAL
            )
        ''');
    }, onUpgrade: (db, oldVersion, newVersion) {});
  }

  // createHelper(Food food) {
  //   getAllFood().then((value) {
  //     print(value.isNotEmpty);
  //     if (value.isNotEmpty) {
  //       if (value.last.time == person.time) {
  //         return null;
  //       } else {
  //         createData(person);
  //       }
  //     } else {
  //       createData(person);
  //     }
  //   }, onError: (e) {
  //     createData(person);
  //   });
  // }

  //Create
  createData(Person person) async {
    final db = await database;
    await db.insert(
      tableName,
      person.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //Read
  getFood(int id) async {
    final db = await database;
    var res = await db.rawQuery('SELECT * FROM $tableName WHERE id = $id');
    return res.isNotEmpty
        ? Food(
            code: res.first['code'],
            dbArmy: res.first['dbArmy'],
            foodName: res.first['foodName'],
            foodKinds: res.first['foodKinds'],
            kcal: res.first['kcal'],
            protein: res.first['protein'],
            carbohydrate: res.first['carbohydrate'],
            fat: res.first['fat'])
        : Null;
  }

  //Read All
  Future<List<Person>> getAllFood() async {
    final db = await database;
    var res = await db.rawQuery('SELECT * FROM $tableName');
    List<Person> list = res.isNotEmpty
        ? res
            .map(
              (c) => Food(
                  code: c['code'],
                  dbArmy: c['dbArmy'],
                  foodName: c['foodName'],
                  foodKinds: c['foodKinds'],
                  kcal: c['kcal'],
                  protein: c['protein'],
                  carbohydrate: c['carbohydrate'],
                  fat: c['fat']),
            )
            .toList()
        : [];

    return list;
  }

  //Delete
  deletePerson(int id) async {
    final db = await database;
    var res = db.rawDelete('DELETE FROM $tableName WHERE id = ?', [id]);
    return res;
  }

  //Delete All
  deleteAllPerson() async {
    final db = await database;
    db.rawDelete('DELETE FROM $tableName');
  }
}
