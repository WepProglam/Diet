import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
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
            weightTarget REAL,
            bmiTarget REAL,
            muscleTarget REAL,
            sex INTEGER,
            age INTEGER
            )
        ''');
    }, onUpgrade: (db, oldVersion, newVersion) {});
  }

  createHelper(Person person) async {
    await getAllPerson().then((value) async {
      if (value.isNotEmpty) {
        if (value.last.time == person.time) {
          await updatePerson(person);
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
            weightTarget: res.first['weightTarget'],
            bmiTarget: res.first['bmiTarget'],
            muscleTarget: res.first['muscleTarget'],
            sex: res.first['sex'],
            age: res.first['age'])
        : null;
  }

  //ReadLast
  Future<Person> getLastPerson() async {
    final db = await database;
    var res = await db.rawQuery("SELECT * FROM $tableName");
    return res.isNotEmpty
        ? Person(
            height: res.last['height'],
            weight: res.last['weight'],
            bmi: res.last['bmi'],
            muscleMass: res.last['muscleMass'],
            purpose: res.last['purpose'],
            time: res.last['time'],
            achieve: res.last['achieve'],
            metabolism: res.last['metabolism'],
            activity: res.last['activity'],
            weightTarget: res.last['weightTarget'],
            bmiTarget: res.last['bmiTarget'],
            muscleTarget: res.last['muscleTarget'],
            sex: res.last['sex'],
            age: res.last['age'])
        : null;
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
                  weightTarget: c['weightTarget'],
                  bmiTarget: c['bmiTarget'],
                  muscleTarget: c['muscleTarget'],
                  sex: c['sex'],
                  age: c['age']),
            )
            .toList()
        : [];

    return list;
  }

  Future<void> updatePerson(Person person) async {
    final db = await database;
    await db.update(
      tableName,
      person.toMap(),
      where: "time = ?",
      whereArgs: [person.time],
    );
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
  final String dBName = 'Food';
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

    final exist=await databaseExists(path);
    if(exist){
      print("db alredy exits");
    }else{
      // try{
      //   await Directory(dirname(path)).create(recursive: true);
      // }catch(_){
        ByteData data =await rootBundle.load(join("assets","FoodDiet.db"));
        List<int> bytes=data.buffer.asUint8List(data.offsetInBytes,data.lengthInBytes);
        print(data.lengthInBytes);

        await File(path).writeAsBytes(bytes,flush: true);
      // }
    }
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


    // return await openDatabase(path, version: 1, onCreate: (db, version) async {
    //   await db.execute('''
    //       CREATE TABLE $tableName(
    //         code TEXT,
    //         dbArmy TEXT,
    //         foodName TEXT,
    //         foodKinds TEXT,
    //         kcal REAL,
    //         protein REAL,
    //         carbohydrate REAL,
    //         fat REAL,
    //         isItMine TEXT DEFAULT F,
    //         selected INTEGER DEFAULT 0,
    //         servingSize REAL
    //         )
    //     ''');
    // }, onUpgrade: (db, oldVersion, newVersion) {});

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
            servingSize: res.first['servingSize'],
          )
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
        print(value.first.dietName);
        print(diet.dietName);
        print("/" * 100);
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
            snack TEXT,
            year INT,
            month INT,
            complete TEXT
            )
        ''');
    }, onUpgrade: (db, oldVersion, newVersion) {});
  }

  Future<List<dynamic>> getCompleteDietHistory({int year, int month}) async {
    final db = await database;
    var res = await db.rawQuery(
        "SELECT date FROM $tableName WHERE year = '$year' AND month = '$month' AND complete = 'true'");
    List<dynamic> list =
        res.isNotEmpty ? res.map((c) => c['date']).toList() : [];
    return list;
  }

  Future<List<DietHistory>> getMonthlyDietHistory({int month}) async {
    final db = await database;
    var res =
        await db.rawQuery("SELECT * FROM $tableName WHERE month = '$month'");
    List<DietHistory> list = res.isNotEmpty
        ? res
            .map((c) => DietHistory(
                date: c['date'],
                breakFast: c['breakFast'],
                lunch: c['lunch'],
                dinner: c['dinner'],
                snack: c['snack'],
                year: c['year'],
                month: c['month'],
                complete: c['complete']))
            .toList()
        : [];
    return list;
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

  Future<List<int>> createHelper(DietHistory dietHistory) {
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
            snack: res.first['snack'],
            year: res.first['year'],
            month: res.first['month'],
            complete: res.first['complete'])
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
                snack: c['snack'],
                year: c['year'],
                month: c['month'],
                complete: c['complete']))
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
