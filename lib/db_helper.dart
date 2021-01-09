import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'model.dart';

final String dBName = 'Diet';
final String tableName = 'Person';

class DBHelper {
  DBHelper._();
  static final DBHelper _db = DBHelper._();
  factory DBHelper() => _db;

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
