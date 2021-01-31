import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:csv/csv.dart';
import 'package:flutter_application_1/lineChart.dart';
import 'package:path_provider/path_provider.dart';
import 'appBar.dart';
import 'model.dart';

num calculateDensity = 1;
//person에서 받아와야 함!!
num targetCalorie;
List<num> ratio = List(3);

List<dynamic> csvList = [];
int purposeIndex = 0;
void getPersonKcal(
    {List<num> defaultMassList, List<num> defaultNutriList}) async {
  await dbHelperPerson.getLastPerson().then((val) {
    targetCalorie = val.metabolism;
    print("adsfdfs");
    print(val.metabolism);
    print("adsfdfs");
    print("adsfdfs");
    purposeIndex = val.purpose;
    // purposeIndex = 0;
    switch (purposeIndex) {
      case 0:
        ratio = [3, 4, 3];
        break;
      case 1:
        ratio = [4, 4, 2];
        break;
      case 2:
        ratio = [5, 3, 2];
        break;
      default:
    }
    num minus;
    for (var i = 0; i < defaultMassList.length; i++) {
      minus = defaultMassList[i] *
          (defaultNutriList[i * 3] * 4 +
              defaultNutriList[i * 3 + 1] * 4 +
              defaultNutriList[i * 3 + 2] * 9);

      targetCalorie -= minus;
    }
    if (targetCalorie <= 0) {
      targetCalorie = 0;
    }
    print(targetCalorie);
  });
}

Future<List<num>> makeCsvFile(
    {List<Food> foodList,
    List<Map> defaultFoodList,
    bool hardOrSoft = true}) async {
  //hard = true, soft=false
  List<List<num>> massList = [[]];

  // print(defaultFoodList);
  // print(foodList);

  List<num> defaultNutriInfo = new List(defaultFoodList.length * 3);
  List<num> defaultMassList = new List(defaultFoodList.length);

  for (var i = 0; i < defaultFoodList.length; i++) {
    defaultNutriInfo[3 * i] = defaultFoodList[i]["food"].carbohydrate;
    defaultNutriInfo[3 * i + 1] = defaultFoodList[i]["food"].protein;
    defaultNutriInfo[3 * i + 2] = defaultFoodList[i]["food"].fat;
    defaultMassList[i] = defaultFoodList[i]["mass"];
  }

  await getPersonKcal(
      defaultMassList: defaultMassList, defaultNutriList: defaultNutriInfo);

  calculateDensity = 1;
  num foodLength = foodList.length;
  num defaultFoodLength = defaultFoodList.length;
  num totalFoodLength = foodLength + defaultFoodLength;
  if (foodList.length <= 3) {
    calculateDensity *= 30;
  } else if (foodList.length <= 5) {
    calculateDensity *= 10;
  } else if (foodList.length <= 7) {
    calculateDensity *= 5;
  } else {
    calculateDensity *= 3;
  }

  //음식 무게 리스트 초기화 600은 kcal
  List<num> myFoodMassList = new List(totalFoodLength + 1);
  List<num> maxMass = new List(foodLength);
  List<num> minMass = new List(foodLength);
  List<num> calorie = new List(totalFoodLength);
  List<num> nutriInfo = new List(totalFoodLength * 3);

  if (hardOrSoft) {
    //hard모드
    for (var i = 0; i < foodLength; i++) {
      minMass[i] =
          targetCalorie * 0.1 / foodList[i].kcal; //최소 전체 음식 칼로리의 10% 선에서 돌림
      //foodList[i].servingSize / 4;
      myFoodMassList[i] = minMass[i];
      calorie[i] = foodList[i].carbohydrate * 4 +
          foodList[i].fat * 9 +
          foodList[i].protein * 4;
      maxMass[i] =
          targetCalorie * 0.9 / foodList[i].kcal; //최대 전체 음식 칼로리의 80% 선에서 돌림
      //foodList[i].servingSize * 2;

      nutriInfo[i * 3] = foodList[i].carbohydrate;
      nutriInfo[i * 3 + 1] = foodList[i].protein;
      nutriInfo[i * 3 + 2] = foodList[i].fat;
    }
  } else {
    //soft모드
    for (var i = 0; i < foodLength; i++) {
      minMass[i] =
          targetCalorie * 0.5 / foodList[i].kcal; //최소 전체 음식 칼로리의 50% 선에서 돌림
      //foodList[i].servingSize / 4;
      myFoodMassList[i] = minMass[i];
      calorie[i] = foodList[i].carbohydrate * 4 +
          foodList[i].fat * 9 +
          foodList[i].protein * 4;
      maxMass[i] =
          targetCalorie * 0.8 / foodList[i].kcal; //최대 전체 음식 칼로리의 80% 선에서 돌림
      //foodList[i].servingSize * 2;

      nutriInfo[i * 3] = foodList[i].carbohydrate;
      nutriInfo[i * 3 + 1] = foodList[i].protein;
      nutriInfo[i * 3 + 2] = foodList[i].fat;
    }
  }

  var k = 0;
  for (var i = foodLength; i < totalFoodLength; i++) {
    myFoodMassList[i] = defaultMassList[k];
    calorie[i] = defaultNutriInfo[k * 3] * 4 +
        defaultNutriInfo[k * 3 + 1] * 4 +
        defaultNutriInfo[k * 3 + 2] * 9;
    nutriInfo[i * 3] = defaultNutriInfo[k * 3];
    nutriInfo[i * 3 + 1] = defaultNutriInfo[k * 3 + 1];
    nutriInfo[i * 3 + 2] = defaultNutriInfo[k * 3 + 2];
    k += 1;
  }

  int tempIndex = 0;
  //일치율
  myFoodMassList.last = 0;

  // print(myFoodMassList);
  print(targetCalorie);

  massList = [
    makeForLooP(tempIndex, myFoodMassList, minMass, maxMass, nutriInfo, calorie,
        defaultFoodLength)
  ];

  // print(massList);
  num corect = massList[0].removeLast(); //일치율 pop
  num temp;
  for (var i = 0; i < defaultFoodLength; i++) {
    temp = massList[0].removeLast();
    massList[0].insert(0, temp);
  }

  massList[0].add(corect);

  // print(massList);
  return massList[0];
}

List<dynamic> justCalculateNutri(
    List<num> foodList, num foodLength, num defaultFoodLength) {
  num totalFoodLength = defaultFoodLength + foodLength;
  List<num> carbohydrateList = List<num>(totalFoodLength);
  List<num> proteinList = List<num>(totalFoodLength);
  List<num> fatList = List<num>(totalFoodLength);
  for (var i = 0; i < totalFoodLength; i++) {
    carbohydrateList[i] = foodList[3 * i];
    proteinList[i] = foodList[3 * i + 1];
    fatList[i] = foodList[3 * i + 2];
  }

  List<num> mass = List<num>(foodList.length - totalFoodLength * 3 - 1);

  int j = 0;
  //일치율은 무게 계산에서 제외
  for (var i = totalFoodLength * 3; i < foodList.length - 1; i++) {
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
  // num cosTheta = returnDotProduct(ratio, nutriRatio) /
  //     (returnAmplitude(ratio) * returnAmplitude(nutriRatio));
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
    " ",
    carbohydrate,
    protein,
    fat
  ];
  return csvFile;
}

List<num> makeForLooP(
    num tempIndex,
    List<num> myFoodMassList,
    List<num> minMass,
    List<num> maxMass,
    List<num> nutriInfo,
    List<num> calorie,
    num defaultAmount) {
  List<num> maxMassList;
  if (tempIndex == maxMass.length - 1) {
    num tempDegree = 0;
    num maxDegree = myFoodMassList.last;
    List<num> returnMassList = List<num>.from(myFoodMassList);
    List<num> tempMassList = List<num>.from(myFoodMassList);
    for (tempMassList[tempIndex] = minMass[tempIndex];
        tempMassList[tempIndex] < maxMass[tempIndex];
        tempMassList[tempIndex] +=
            ((maxMass[tempIndex] - minMass[tempIndex]) ~/ calculateDensity)) {
      // totalCalorie = totalCalorieOverFlow(myFoodMassList, calorie);
      // if (totalCalorie > targetCalorie * 1.2 ||
      //     totalCalorie < targetCalorie * 0.8) {
      //   //걍 넘어가  //걍 넘어가면 일치율은 올라가고 무게가 살인적
      // } else {
      List<num> tempMassList2 = List<num>.from(tempMassList);

      List<num> sendData = [];
      num inputTotalCalorie = totalCalorieOverFlow(
          tempMassList2.sublist(0, maxMass.length),
          calorie.sublist(0, maxMass.length));

      // print("$targetCalorie $inputTotalCalorie");
      // print("$inputTotalCalorie ${maxMass.length}");
      // print(tempMassList2);
      for (var i = 0; i < maxMass.length; i++) {
        tempMassList2[i] *= (targetCalorie / inputTotalCalorie);
      }
      // print(totalCalorieOverFlow(tempMassList2.sublist(0, maxMass.length),
      //     calorie.sublist(0, maxMass.length)));
      // print(tempMassList2);

      sendData.addAll(nutriInfo);
      sendData.addAll(tempMassList2);
      tempDegree =
          justCalculateNutri(sendData, maxMass.length, defaultAmount)[1];

      if (tempDegree >= maxDegree) {
        //현재의 일치율을 가져와 전보다 높으면 return mass list에 저장
        maxDegree = tempDegree;
        // print(maxDegree);
        returnMassList = List<num>.from(tempMassList2);
        returnMassList.last = maxDegree;
      } else {}
      // }
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
      tempMassList = new List<num>.from(makeForLooP(tempIndex, myFoodMassList,
          minMass, maxMass, nutriInfo, calorie, defaultAmount));

      if (tempMassList.last >= maxMassList.last) {
        maxMassList = new List<num>.from(tempMassList);
      }
      tempIndex -= 1;
    }
  } else {}
  // print("mass : $myFoodMassList");
  return maxMassList;
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

//ratio: 설정 비율, nutriRatio: 특정 점의 비율
num correctness(List<num> ratio, List<num> nutriRatio) {
  num ampRatio = returnAmplitude(ratio);
  num ampNutriRatio = returnAmplitude(nutriRatio);
  if (ampNutriRatio == 0.0) {
    return 0;
  }
  //단위원 안에 넣기
  for (int i = 0; i < 3; i++) {
    // if (ampRatio == 0 || ampNutriRatio == 0) {
    //   return 0;
    // }
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
      if (minusV[direction] <= 0) {
        break;
      } else {
        continue;
      }
    }
  }

  // List<num> plane = normalV;
  List<num> pointInPlane = [0, 0, 0];
  switch (direction) {
    case 0: //yz평면 방향으로 갈때
      {
        // pointInPlane[0] = 0;
        pointInPlane[1] = sqrt(1 / (pow((normalV[1] / normalV[2]), 2) + 1));
        pointInPlane[2] = sqrt(1 / (pow((normalV[2] / normalV[1]), 2) + 1));
      }
      break;
    case 1: //zx 평면 방향
      {
        // pointInPlane[1] = 0;
        pointInPlane[2] = sqrt(1 / (pow((normalV[2] / normalV[0]), 2) + 1));
        pointInPlane[0] = sqrt(1 / (pow((normalV[0] / normalV[2]), 2) + 1));
      }
      break;
    case 2: //xy평면 방향
      {
        // pointInPlane[2] = 0;
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
