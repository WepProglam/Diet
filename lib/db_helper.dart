import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'model.dart';

class DBHelperPerson {
  final String dBName = 'Person';
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
            achieve REAL,
            metabolism REAL,
            activity INT,
            nutriRate INT
            )
        ''');
    }, onUpgrade: (db, oldVersion, newVersion) {});
  }

  createHelper(Person person) {
    getAllPerson().then((value) async {
      if (value.isNotEmpty) {
        if (value.last.time == person.time) {
          await deletePerson(value.last.time);
          createData(person);
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
  getPerson(String time) async {
    final db = await database;
    var res = await db.rawQuery('SELECT * FROM $tableName WHERE time = $time');
    return res.isNotEmpty
        ? Person(
            height: res.first['height'],
            weight: res.first['weight'],
            bmi: res.first['bmi'],
            muscleMass: res.first['muscleMass'],
            purpose: res.first['purpose'],
            time: res.first['time'],
            achieve: res.first['achieve'],
            metabolism: res.first['metabolism'],
            activity: res.first['activity'],
            nutriRate: res.first['nutriRate'])
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
                  achieve: c['achieve'],
                  metabolism: c['metabolism'],
                  activity: c['activity'],
                  nutriRate: c['nutriRate']),
            )
            .toList()
        : [];

    return list;
  }

  //Delete
  deletePerson(String time) async {
    final db = await database;
    var res = db.rawDelete("DELETE FROM $tableName WHERE time = '$time'");
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
            selected INTEGER DEFAULT 0,
            servingSize REAL
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
            selected: res.first['selected'],
            servingSize: res.first['servingSize'])
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
                  selected: c['selected'],
                  servingSize: c['servingSize']),
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
                  selected: c['selected'],
                  servingSize: c['servingSize']),
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
            dietName TEXT,
            foodInfo TEXT
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
        ? Diet(dietName: res.first['dietName'], foodInfo: res.first['foodInfo'])
        : Null;
  }

  Future<List<Diet>> getAllMyDiet() async {
    final db = await database;
    var res = await db.rawQuery("SELECT * FROM $tableName");
    List<Diet> list = res.isNotEmpty
        ? res
            .map(
              (c) => Diet(dietName: c['dietName'], foodInfo: c['foodInfo']),
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
