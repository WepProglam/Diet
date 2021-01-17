import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'model.dart';

class DBHelperPerson {
  final String dBName = 'Diet';
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
            time TEXT,
            achieve REAL
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
            time: res.first['time'],
        achieve: res.first['achieve'])
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
                  time: c['time'],
                  achieve: c['achieve']),
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
  final String dBName = 'FoodDiet';
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
    String path = join(documentsDirectory.path, "$dBName.db");
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
            fat REAL,
            isItMine TEXT DEFAULT F,
            selected INTEGER DEFAULT 0
            )
        ''');
    }, onUpgrade: (db, oldVersion, newVersion) {});
  }

  //Create
  createData(Food food) async {
    final db = await database;
    await db.insert(
      tableName,
      food.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //Read
  getFood(String code) async {
    final db = await database;
    var res =
        await db.rawQuery("SELECT * FROM $tableName WHERE code = '$code'");
    return res.isNotEmpty
        ? Food(
            code: res.first['code'],
            dbArmy: res.first['dbArmy'],
            foodName: res.first['foodName'],
            foodKinds: res.first['foodKinds'],
            kcal: res.first['kcal'],
            protein: res.first['protein'],
            carbohydrate: res.first['carbohydrate'],
            fat: res.first['fat'],
            isItMine: res.first['isItMine'],
            selected: res.first['selected'])
        : Null;
  }

  //Read All
  Future<List<Food>> filterFoods(String value) async {
    final db = await database;
    var res = await db
        .rawQuery("SELECT * FROM $tableName WHERE foodName LIKE '%$value%'");
    List<Food> list = res.isNotEmpty
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
                  fat: c['fat'],
                  isItMine: c['isItMine'],
                  selected: c['selected']),
            )
            .toList()
        : [];

    return list;
  }

  //Read All
  Future<List<Food>> getAllMyFood() async {
    final db = await database;
    var res =
        await db.rawQuery("SELECT * FROM $tableName WHERE isItMine = 'T'");
    List<Food> list = res.isNotEmpty
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
                  fat: c['fat'],
                  isItMine: c['isItMine'],
                  selected: c['selected']),
            )
            .toList()
        : [];
    return list;
  }

  //Delete
  deleteFood(String code) async {
    final db = await database;
    var res = db.rawDelete("DELETE FROM $tableName WHERE code = '$code'");
    return res;
  }

  //Delete All
  deleteAllFood() async {
    final db = await database;
    db.rawDelete('DELETE FROM $tableName');
  }
}

class DBHelperDiet {
  final String dBName = 'Diet';
  final String tableName = 'Diet';
  DBHelperDiet._();
  static final DBHelperDiet _db = DBHelperDiet._();
  factory DBHelperDiet() => _db;

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "$dBName.db");
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
          CREATE TABLE $tableName(
            dietName TEXT
            foodCodes TEXT
            foodMasses TEXT
            )
        ''');
    }, onUpgrade: (db, oldVersion, newVersion) {});
  }

  createData(Diet diet) async {
    final db = await database;
    await db.insert(
      tableName,
      diet.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  getDiet(String dietName) async {
    final db = await database;
    var res = await db
        .rawQuery("SELECT * FROM $tableName WHERE dietName = '$dietName'");
    return res.isNotEmpty
        ? Diet(
            dietName: res.first['dietName'],
            foodCodes: res.first['foodCodes'],
            foodMasses: res.first['foodMasses'],
          )
        : Null;
  }

  Future<List<Food>> getAllMyDiet() async {
    final db = await database;
    var res = await db.rawQuery("SELECT * FROM $tableName");
    List<Food> list = res.isNotEmpty
        ? res
            .map(
              (c) => Diet(
                dietName: c['dietName'],
                foodCodes: c['foodCodes'],
                foodMasses: c['foodMasses'],
              ),
            )
            .toList()
        : [];
    return list;
  }

  deleteDiet(String dietName) async {
    final db = await database;
    var res =
        db.rawDelete("DELETE FROM $tableName WHERE dietName = '$dietName'");
    return res;
  }

  deleteAllDiet() async {
    final db = await database;
    db.rawDelete('DELETE FROM $tableName');
  }
}
