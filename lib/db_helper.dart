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
            nutriRate INT,
            weightTarget REAL,
            bmiTarget REAL,
            muscleTarget REAL
            )
        ''');
    }, onUpgrade: (db, oldVersion, newVersion) {});
  }

  createHelper(Person person) {
    getAllPerson().then((value) async {
      if (value.isNotEmpty) {
        if (value.last.time == person.time) {
          await deletePerson(value.last.time);
          await createData(person);
        } else {
          await createData(person);
        }
      } else {
        await createData(person);
      }
    }, onError: (e) async {
      await createData(person);
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
  Future<Person> getPerson(String time) async {
    final db = await database;
    var res =
        await db.rawQuery("SELECT * FROM $tableName WHERE time = '$time'");
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
            nutriRate: res.first['nutriRate'],
            weightTarget: res.first['weightTarget'],
            bmiTarget: res.first['bmiTarget'],
            muscleTarget: res.first['muscleTarget'])
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
                  nutriRate: c['nutriRate'],
                  weightTarget: c['weightTarget'],
                  bmiTarget: c['bmiTarget'],
                  muscleTarget: c['muscleTarget']),
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
      // conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateFood(Food food) async {
    final db = await database;
    await db.update(
      tableName,
      food.toMap(),
      where: "code = ?",
      whereArgs: [food.code],
    );
  }

  //Read
  Future<Food> getFood(String code) async {
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
  Future<List<Food>> filterFoods(String value, {int limit = 10}) async {
    final db = await database;
    var res = await db.rawQuery(
        "SELECT * FROM $tableName WHERE foodName LIKE '%$value%' LIMIT '$limit'");
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

//Read All
  Future<List<Food>> getAllFood() async {
    final db = await database;
    var res = await db.rawQuery("SELECT * FROM $tableName");
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

  Future<List<Food>> getLimitFood(int offset, int rows) async {
    final db = await database;
    var res = await db.rawQuery(
        "SELECT * FROM $tableName WHERE isItMine = 'F' LIMIT '$rows' OFFSET '$offset'");
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

  Future<void> updateDiet(Diet diet) async {
    final db = await database;
    await db.update(
      tableName,
      diet.toMap(),
      where: "dietName = ?",
      whereArgs: [diet.dietName],
    );
  }

  createHelper(Diet diet) {
    getAllMyDiet().then((value) async {
      if (value.isNotEmpty) {
        bool isThere = false;
        for (var item in value) {
          if (diet.dietName == item.dietName) {
            isThere = true;
            break;
          } else {
            isThere = false;
          }
        }
        if (isThere) {
          await updateDiet(diet);
        } else {
          await createData(diet);
        }
      } else {
        await createData(diet);
      }
    });
  }

  Future<Diet> getDiet(String dietName) async {
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

class DBHelperDietHistory {
  final String dBName = 'DietHistory';
  final String tableName = 'DietHistory';
  DBHelperDietHistory._();
  static final DBHelperDietHistory _db = DBHelperDietHistory._();
  factory DBHelperDietHistory() => _db;

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
            date TEXT,
            breakFast TEXT,
            lunch TEXT,
            dinner TEXT,
            snack TEXT
            )
        ''');
    }, onUpgrade: (db, oldVersion, newVersion) {});
  }

  createData(DietHistory dietHistory) async {
    final db = await database;
    await db.insert(
      tableName,
      dietHistory.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateDietHistory(DietHistory dietHistory) async {
    final db = await database;
    await db.update(
      tableName,
      dietHistory.toMap(),
      where: "date = ?",
      whereArgs: [dietHistory.date],
    );
  }

  createHelper(DietHistory dietHistory) {
    getAllMyDietHistory().then((value) async {
      if (value.isNotEmpty) {
        bool isThere = false;
        for (var item in value) {
          if (dietHistory.date == item.date) {
            isThere = true;
            break;
          } else {
            isThere = false;
          }
        }
        if (isThere) {
          await updateDietHistory(dietHistory);
        } else {
          await createData(dietHistory);
        }
      } else {
        await createData(dietHistory);
      }
    });
  }

   Future<DietHistory> getDietHistory(String date) async {
    final db = await database;
    var res =
        await db.rawQuery("SELECT * FROM $tableName WHERE date = '$date'");
    return res.isNotEmpty
        ? DietHistory(
            date: res.first['date'],
            breakFast: res.first['breakFast'],
            lunch: res.first['lunch'],
            dinner: res.first['dinner'],
            snack: res.first['snack'])
        : null;
  }

  Future<List<DietHistory>> getAllMyDietHistory() async {
    final db = await database;
    var res = await db.rawQuery("SELECT * FROM $tableName");
    List<DietHistory> list = res.isNotEmpty
        ? res
            .map((c) => DietHistory(
                date: c['date'],
                breakFast: c['breakFast'],
                lunch: c['lunch'],
                dinner: c['dinner'],
                snack: c['snack']))
            .toList()
        : [];
    return list;
  }

  deleteDietHistory(String date) async {
    final db = await database;
    var res = db.rawDelete("DELETE FROM $tableName WHERE date = '$date'");
    return res;
  }

  deleteAllDietHistory() async {
    final db = await database;
    db.rawDelete('DELETE FROM $tableName');
  }
}
