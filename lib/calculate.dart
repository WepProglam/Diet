import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'appBar.dart';
import 'model.dart';

num calculateDensity = 1;
const targetCalorie = 600;

List<dynamic> csvList = [];

List<dynamic> justCalculateNutri(List<num> foodList, num foodLength) {
  List<num> ratio = [5, 3, 2];
  List<num> carbohydrateList = List<num>(foodLength);
  List<num> proteinList = List<num>(foodLength);
  List<num> fatList = List<num>(foodLength);
  for (var i = 0; i < foodLength; i++) {
    carbohydrateList[i] = foodList[3 * i];
    proteinList[i] = foodList[3 * i + 1];
    fatList[i] = foodList[3 * i + 2];
  }

  List<num> mass = List<num>(foodList.length - foodLength * 3 - 1);

  int j = 0;
  //일치율은 무게 계산에서 제외
  for (var i = foodLength * 3; i < foodList.length - 1; i++) {
    mass[j] = foodList[i];
    j += 1;
  }

  num carbohydrate = 0.0;
  num protein = 0.0;
  num fat = 0.0;

  for (var i = 0; i < mass.length; i++) {
    carbohydrate += carbohydrateList[i] * mass[i];
    protein += proteinList[i] * mass[i];
    fat += fatList[i] * mass[i];
  }
  List<num> nutriRatio = [carbohydrate * 4, protein * 4, fat * 9];
  num cosTheta = returnDotProduct(ratio, nutriRatio) /
      (returnAmplitude(ratio) * returnAmplitude(nutriRatio));
  // num degree = acos(cosTheta);
  // num correctRate = (4 * cosTheta - 3) * 100;
  num correctRate = correctness(ratio, nutriRatio);

  // if (degree > 0.9) {
  //   correctRate = 0;
  // }

  List<dynamic> csvFile = [
    mass,
    // (1 - degree / (pi / 2)) * 100,
    correctRate,
    "1 : ${myRounder(protein / carbohydrate)} : ${myRounder(fat * 9 / (carbohydrate * 4))}",
    carbohydrate,
    protein,
    fat
  ];
  return csvFile;
}

//ratio: 설정 비율, nutriRatio: 특정 점의 비율
num correctness(List<num> ratio, List<num> nutriRatio) {
  num ampRatio = returnAmplitude(ratio);
  num ampNutriRatio = returnAmplitude(nutriRatio);
  //단위원 안에 넣기
  for (int i = 0; i < 3; i++) {
    if (ampRatio == 0 || ampNutriRatio == 0) {
      return 0;
    }
    ratio[i] = ratio[i] / ampRatio;
    nutriRatio[i] = nutriRatio[i] / ampNutriRatio;
  }

  //nutriRatio - ratio (ratio -> nutriRatio)
  List<num> minusV = returnMinus(ratio, nutriRatio);
  //법선벡터
  List<num> normalV = returnCrossProduct(ratio, nutriRatio);

  //직선과 평면이 만날 때 매개변수 값
  //[yz, zx, xy] (x = 0, y = 0, z = 0)
  int direction = 0;
  for (; direction < 3; direction++) {
    if (minusV[direction] == 0) {
      continue;
    } else {
      // num t = -ratio[direction] / minusV[direction];
      if (ratio[direction] / minusV[direction] <= 0) {
        break;
      } else {
        continue;
      }
    }
  }

  // List<num> plane = normalV;
  List<num> pointInPlane = new List(3);
  switch (direction) {
    case 0: //yz평면 방향으로 갈때
      {
        pointInPlane[0] = 0;
        pointInPlane[1] = sqrt(1 / (pow((normalV[1] / normalV[2]), 2) + 1));
        pointInPlane[2] = sqrt(1 / (pow((normalV[2] / normalV[1]), 2) + 1));
      }
      break;
    case 1: //zx 평면 방향
      {
        pointInPlane[1] = 0;
        pointInPlane[2] = sqrt(1 / (pow((normalV[2] / normalV[0]), 2) + 1));
        pointInPlane[0] = sqrt(1 / (pow((normalV[0] / normalV[2]), 2) + 1));
      }
      break;
    case 2: //xy평면 방향
      {
        pointInPlane[2] = 0;
        pointInPlane[0] = sqrt(1 / (pow((normalV[0] / normalV[1]), 2) + 1));
        pointInPlane[1] = sqrt(1 / (pow((normalV[1] / normalV[0]), 2) + 1));
      }
      break;

    default:
      return 100;
  }

  num degreeWithNutriRatio = acos(returnDotProduct(ratio, nutriRatio));
  num degreeWithPointInPlane = acos(returnDotProduct(ratio, pointInPlane));

  num result =
      (1 - pow(((degreeWithNutriRatio / degreeWithPointInPlane)), 2)) * 100;
  // print(result);
  return result;
}

List<num> returnMinus(List<num> a, List<num> b) {
  List<num> result = new List(3);
  for (int i = 0; i < 3; i++) {
    result[i] = b[i] - a[i];
  }
  return result;
}

num returnAmplitude(List<num> a) {
  num amp = 0;
  for (var i = 0; i < a.length; i++) {
    amp += pow(a[i], 2);
  }
  return (pow(amp, 1 / 2));
}

num returnDotProduct(List<num> a, List<num> b) {
  num dot = 0;
  for (var i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
  }
  return dot;
}

List<num> returnCrossProduct(List<num> a, List<num> b) {
  List<num> cross = new List(3);

  cross[0] = a[1] * b[2] - a[2] * b[1];
  cross[1] = a[2] * b[0] - a[0] * b[2];
  cross[2] = a[0] * b[1] - a[1] * b[0];

  return cross;
}

num totalCalorieOverFlow(List<num> mass, List<num> calorie) {
  num totalCalorie = 0;

  for (var i = 0; i < calorie.length; i++) {
    totalCalorie += calorie[i] * mass[i];
  }

  return totalCalorie;
}

List<num> makeForLooP(
    num tempIndex,
    List<num> myFoodMassList,
    List<num> minMass,
    List<num> maxMass,
    List<num> nutriInfo,
    List<num> calorie) {
  List<num> maxMassList;
  num totalCalorie = 0;
  if (tempIndex == maxMass.length - 1) {
    num tempDegree = 0;
    num maxDegree = myFoodMassList.last;
    List<num> returnMassList = List<num>.from(myFoodMassList);
    List<num> tempMassList = List<num>.from(myFoodMassList);
    for (tempMassList[tempIndex] = minMass[tempIndex];
        tempMassList[tempIndex] < maxMass[tempIndex];
        tempMassList[tempIndex] +=
            ((maxMass[tempIndex] - minMass[tempIndex]) ~/ calculateDensity)) {
      totalCalorie = totalCalorieOverFlow(myFoodMassList, calorie);
      if (totalCalorie > targetCalorie * 1.3 ||
          totalCalorie < targetCalorie * 0.7) {
        //걍 넘어가
      } else {
        List<num> sendData = [];
        sendData.addAll(nutriInfo);
        sendData.addAll(tempMassList);
        tempDegree = justCalculateNutri(sendData, maxMass.length)[1];

        if (tempDegree >= maxDegree) {
          //현재의 일치율을 가져와 전보다 높으면 return mass list에 저장
          maxDegree = tempDegree;
          print(maxDegree);
          returnMassList = List<num>.from(tempMassList);
          returnMassList.last = maxDegree;
        } else {}
      }
    }
    return returnMassList;
  } else if (tempIndex < maxMass.length - 1) {
    maxMassList = List<num>.from(myFoodMassList);
    List<num> tempMassList = List<num>.from(myFoodMassList);
    for (myFoodMassList[tempIndex] = minMass[tempIndex];
        myFoodMassList[tempIndex] < maxMass[tempIndex];
        myFoodMassList[tempIndex] +=
            (maxMass[tempIndex] - minMass[tempIndex]) ~/ calculateDensity) {
      tempIndex += 1;
      tempMassList = new List<num>.from(makeForLooP(
          tempIndex, myFoodMassList, minMass, maxMass, nutriInfo, calorie));

      if (tempMassList.last >= maxMassList.last) {
        maxMassList = new List<num>.from(tempMassList);
      }
      tempIndex -= 1;
    }
  } else {}
  // print("mass : $myFoodMassList");
  return maxMassList;
}

Future<List<num>> makeCsvFile({List<Food> foodList}) async {
  int foodLength = 0;
  List<List<num>> massList = [[]];
  calculateDensity = 1;
  foodLength = foodList.length;
  if (foodLength <= 3) {
    calculateDensity *= 30;
  } else if (foodLength <= 5) {
    calculateDensity *= 20;
  } else if (foodLength <= 7) {
    calculateDensity *= 5;
  } else {
    calculateDensity *= 3;
  }

  //음식 무게 리스트 초기화 600은 kcal
  List<num> myFoodMassList = new List(foodLength + 1);
  List<num> maxMass = new List(foodLength);
  List<num> minMass = new List(foodLength);
  List<num> calorie = new List(foodLength);
  List<num> nutriInfo = new List(foodLength * 3);

  for (var i = 0; i < foodLength; i++) {
    minMass[i] = foodList[i].servingSize / 4;
    myFoodMassList[i] = minMass[i];
    maxMass[i] = foodList[i].servingSize * 2;
    calorie[i] = foodList[i].carbohydrate * 4 +
        foodList[i].fat * 9 +
        foodList[i].protein * 4;

    nutriInfo[i * 3] = foodList[i].carbohydrate;
    nutriInfo[i * 3 + 1] = foodList[i].protein;
    nutriInfo[i * 3 + 2] = foodList[i].fat;
  }

  int tempIndex = 0;
  //일치율
  myFoodMassList.last = 0;
  massList = [
    makeForLooP(tempIndex, myFoodMassList, minMass, maxMass, nutriInfo, calorie)
  ];

  num totalCalorie = totalCalorieOverFlow(massList[0], calorie);

  num sum = 0;
  for (var i = 0; i < calorie.length; i++) {
    sum += calorie[i];
  }
  // for (var i = 0; i < calorie.length; i++) {
  //   massList[0][i] *= (targetCalorie / totalCalorie);
  // }
  totalCalorie = totalCalorieOverFlow(massList[0], calorie);

  // print(totalCalorie);

  // String csv = const ListToCsvConverter().convert([csvList]);
  // final directory = await getApplicationDocumentsDirectory();
  // final pathOfTheFileToWrite = directory.path + "/calExcercise.csv";
  // File file = await File(pathOfTheFileToWrite);
  // file.writeAsString(csv);
  return massList[0];
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
