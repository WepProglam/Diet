import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'appBar.dart';

List<dynamic> justCalNutri(List<num> foodList) {
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
    i += 1;
  }
  List<num> nutriRatio = [carbohydrate, protein, fat];
  num degree = acos(returnDotProduct(ratio, nutriRatio) /
      (returnAmplitude(ratio) * returnAmplitude(nutriRatio)));
  // print(mass);
  List<dynamic> csvFile = [mass[0],mass[1],mass[2],degree];
  return csvFile;
}

num returnAmplitude(List<num> a) {
  return (pow(pow(a[0], 2) + pow(a[1], 2) + pow(a[2], 2), 1 / 2));
}

num returnDotProduct(List<num> a, List<num> b) {
  return (a[0] * b[0] + a[1] * b[1] + a[2] * b[2]);
}

void calculate() async {
  List<num> randomList1 = [];
  List<List<dynamic>> randomList = [["a1","b1","c1","a2","b2","c2","a3","b3","c3","mass1","mass2","mass3","degree"]];
  // List<List<double>> randomList2 = [];
  // List<List<double>> randomList3 = [];
  for (var i = 0; i < 100; i++) {
  randomList1 = [];
  randomList1.addAll(
  [Random().nextDouble(), Random().nextDouble(), Random().nextDouble()]);
  randomList1.addAll(
  [Random().nextDouble(), Random().nextDouble(), Random().nextDouble()]);
  randomList1.addAll(
  [Random().nextDouble(), Random().nextDouble(), Random().nextDouble()]);

  List<dynamic> massDegree=[];
  List<dynamic> putItem=[];
  num leastDegree=0;
  num tempDegree=100;
  bool saveOrNot= true;

  for (int j = 0; j < 100*1000*1000; j++) {  //각 음식 비율이 랜덤으로 50*50*50개 생성됨 (음수가 나올 경우 pass)
      List<num> item = new List<num>.from(randomList1);
      List<dynamic> pushMass=[];
      num car=Random().nextDouble()*150;
      num pro=Random().nextDouble()*150;
      num fat=(600 - car*4 - pro*4)/9;  //전체 칼로리 600 중 지방은 600 - 탄 - 단
      if(fat<0){  //지방이 음수일경우 그냥 넘어감
        // randomList1.clear();
        // saveOrNot=false;
        // break;
        leastDegree = j==0? tempDegree: leastDegree;
        // print("$tempDegree $leastDegree $j");

      }
      else{
        item.addAll([car,pro,fat]);
        pushMass=justCalNutri(item);
        tempDegree=pushMass[3];
        leastDegree = j==0? tempDegree: leastDegree;
        // print("$tempDegree $leastDegree $j");
        if(tempDegree <= leastDegree){
          massDegree=justCalNutri(item);//각 음식 무게 비율 토대로 목표 비율과 얼마나 차이가 나는지 계산 (삼차원 공간 속 내적으로 각도 계산함(feat 내적))
          leastDegree=tempDegree;
        }
      }
    }
  if(saveOrNot){
    print("$i th loop - $massDegree");
    putItem.addAll(randomList1);
    putItem.addAll(massDegree);
    randomList.add(putItem);
  }

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
  return a.toString().length < 5
      ? a.toString()
      : a.toString().substring(0, 5);
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
              calculate();
            },
          ));
  }
}
