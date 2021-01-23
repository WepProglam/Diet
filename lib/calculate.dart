import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'appBar.dart';

List<dynamic> justCalculateNutri(List<num> foodList) {
  List<num> ratio = [5, 3, 2];
  List<num> carbohydrateList = [foodList[0], foodList[1], foodList[2]];
  List<num> proteinList = [foodList[3], foodList[4], foodList[5]];
  List<num> fatList = [foodList[6], foodList[7], foodList[8]];

  List<num> mass = [foodList[9], foodList[10], foodList[11]];

  num carbohydrate = 0.0;
  num protein = 0.0;
  num fat = 0.0;

  for (var i = 0; i < mass.length; i++) {
    carbohydrate += carbohydrateList[i] * mass[i];
    protein += proteinList[i] * mass[i];
    fat += fatList[i] * mass[i];
  }
  List<num> nutriRatio = [carbohydrate, protein, fat];
  num degree = acos(returnDotProduct(ratio, nutriRatio) /
      (returnAmplitude(ratio) * returnAmplitude(nutriRatio)));
  // print(mass);
  // print("일치율 : ${(1 - degree / pi) * 100}");
  // print(
  //     "1 : ${myRounder(protein / carbohydrate)} : ${myRounder(fat / carbohydrate)}");

  List<dynamic> csvFile = [
    mass[0],
    mass[1],
    mass[2],
    (1 - degree / (pi / 2)) * 100,
    "1 : ${myRounder(protein / carbohydrate)} : ${myRounder(fat / carbohydrate)}",
    carbohydrate,
    protein,
    fat
  ];
  return csvFile;
}

num returnAmplitude(List<num> a) {
  return (pow(pow(a[0], 2) + pow(a[1], 2) + pow(a[2], 2), 1 / 2));
}

num returnDotProduct(List<num> a, List<num> b) {
  return (a[0] * b[0] + a[1] * b[1] + a[2] * b[2]);
}

Future<List<num>> makeCsvFile({List<num> nutri = null}) async {
  List<num> randomList1 = [];
  List<List<dynamic>> randomList = [
    [
      "a1",
      "b1",
      "c1",
      "a2",
      "b2",
      "c2",
      "a3",
      "b3",
      "c3",
      "mass1",
      "mass2",
      "mass3",
      "correct(%)",
      "1 : 0.6 : 0.4"
    ]
  ];
  num repeat = 100;

  for (var i = 0; i < repeat; i++) {
    randomList1 = [];
    bool isNutriAllPos = true;
    if (nutri != null) {
      repeat = 1;
      randomList1.addAll(nutri);
    } else {
      num a1 = Random().nextDouble();
      num a2 = Random().nextDouble();
      num a3 = Random().nextDouble();

      num b1 = Random().nextDouble();
      num b2 = Random().nextDouble();
      num b3 = Random().nextDouble();

      num c1 = Random().nextDouble();
      num c2 = Random().nextDouble();
      num c3 = Random().nextDouble();

      if (a1 + a2 + a3 < 1 || b1 + b2 + b3 < 1 || c1 + c2 + c3 < 1) {
        //각 영양성분(탄단지들의 합)이 1보다 커지면 안되므로(g당 탄단지)
        isNutriAllPos = false;
        print("false $i");
      } else {
        randomList1.addAll([a1, a2, a3, b1, b2, b3, c1, c2, c3]);
      }
    }
    if (isNutriAllPos) {
      List<dynamic> massDegree = [];
      List<dynamic> putItem = [];
      num biggestDegree = 100;
      num tempDegree = 0;
      bool saveOrNot = true;
      bool keepGoing = true;
      int j = 0;
      List<num> massList = [];

      for (num car = 0; car < 25 * 10; car++) {
        for (num pro = 0; pro < 25 * 10; pro++) {
          num myCar =
              car / 10; // 25*10/10=25  (지방이 음수가 아니려면 (탄 + 단)*4 < 100)=> 탄 < 25
          num myPro = pro / 10;
          num myFat =
              (100 - myCar * 4 - myPro * 4) / 9; //전체 칼로리 100 중 지방은 100 - 탄 - 단

          List<num> item = new List<num>.from(randomList1);

          List<dynamic> pushMass = [];

          if (myFat < 0 || myCar < (myFat + myPro) / 5) {
            //탄수화물이 20프로보다 적으면 필터링
            //지방 음수 막기
            biggestDegree = j == 0 ? tempDegree : biggestDegree;
            // print("$i : $j fat $fat");
            // saveOrNot=false;
            // print("$tempDegree $leastDegree $j");

          } else {
            await calculate(item, [myCar, myPro, myFat]).then((value) {
              List<num> nums = new List<num>.from(value);
              nums.sort();
              // *옵션 설정하기(강 - 중 - 약) 강일수록 밑에 음식 비율 규제 완화 -> 조금더 5:3:2에 가까워짐*
              if (nums[0] / nums[2] > 0.3 && nums[1] / nums[2] > 0.3) {
                // 다른 음식 : 가장 무거운 음식이 1:6을 넘어가지 않게
                //100칼로리 기준 1.7g 이고 600칼로리면 대략 10g // 10g 이하는 계량 너무 어려워서
                keepGoing = true;
                item.addAll(value);
                massList = value;
              } else {
                // print("$i : $j value $value");
                keepGoing = false;
                // saveOrNot=false;
              }
            });
            if (keepGoing) {
              keepGoing = true;
              saveOrNot = true;
              pushMass = justCalculateNutri(item);
              massList.add(pushMass[3]);
              tempDegree = pushMass[3];
              biggestDegree = j == 0 ? tempDegree : biggestDegree;

              if (tempDegree >= biggestDegree) {
                massDegree = justCalculateNutri(item).sublist(0,
                    5); //각 음식 무게 비율 토대로 목표 비율과 얼마나 차이가 나는지 계산 (삼차원 공간 속 내적으로 각도 계산함(feat 내적))
                biggestDegree = tempDegree;
              }
            } else {
              biggestDegree = j == 0 ? tempDegree : biggestDegree;
            }
          }
          j += 1;
        }
      }
      if (nutri != null) {
        return massList;
      } else if (saveOrNot) {
        putItem.addAll(randomList1);
        putItem.addAll(massDegree);
        randomList.add(putItem);
        if (i % 100 == 0) {
          print("$i th loop - $putItem");
        }
      }
    } else {}
  }
  String csv = const ListToCsvConverter().convert(randomList);
  final directory = await getApplicationDocumentsDirectory();
  final pathOfTheFileToWrite = directory.path + "/calExcercise.csv";
  File file = await File(pathOfTheFileToWrite);
  file.writeAsString(csv);
  print("finish");
  // print(randomList[10]);
}

String myRounder(num a) {
  return a.toString().length < 5 ? a.toString() : a.toString().substring(0, 5);
}

class Calculate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: basicAppBar('cal excercise', context),
        drawer: NavDrawer(),
        body: RaisedButton(
          child: Text('push'),
          onPressed: () {
            makeCsvFile();
          },
        ));
  }
}

num detnum(List<List<num>> matrix, int row, int col) {
  List<num> mat = [];
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      if (i != row && j != col) {
        mat.add(matrix[i][j]);
      }
    }
  }
  return mat[0] * mat[3] - mat[1] * mat[2];
}

num detTriple(List<List<num>> matrix) {
  return (matrix[0][0] * detnum(matrix, 0, 0) -
      matrix[0][1] * detnum(matrix, 0, 1) +
      matrix[0][2] * detnum(matrix, 0, 2));
}

Future<List<num>> calculate(List<num> foodList, List<num> mass) async {
  num determinant, xDet, yDet, zDet;
  List<List<num>> matrix = [];
  List<List<num>> matrixTemp = [];
  List<num> carbohydrate = [];
  List<num> protein = [];
  List<num> fat = [];

  num x, y, z; //각 음식별 무게

  carbohydrate = [foodList[0], foodList[1], foodList[2], mass[0]];
  protein = [foodList[3], foodList[4], foodList[5], mass[1]];
  fat = [foodList[6], foodList[7], foodList[8], mass[2]];

  matrix = [carbohydrate, protein, fat];

  //디터미넌트
  matrixTemp = selectRow(matrix, 0, 1, 2);
  determinant = detTriple(matrixTemp);

  //x_디터미넌트
  matrixTemp = selectRow(matrix, 3, 1, 2);
  xDet = detTriple(matrixTemp);

  //y_디터미넌트
  matrixTemp = selectRow(matrix, 0, 3, 2);
  yDet = detTriple(matrixTemp);

  //z_디터미넌트
  matrixTemp = selectRow(matrix, 0, 1, 3);
  zDet = detTriple(matrixTemp);

  //x,y,z 계산
  x = xDet / determinant;
  y = yDet / determinant;
  z = zDet / determinant;

  return [x, y, z];
}

List<List<num>> selectRow(List<List<num>> matrix, int x, int y, int z) {
  var temp = [
    [matrix[0][x], matrix[0][y], matrix[0][z]],
    [matrix[1][x], matrix[1][y], matrix[1][z]],
    [matrix[2][x], matrix[2][y], matrix[2][z]]
  ];
  return temp;
}
