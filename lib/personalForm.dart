import 'package:flutter/material.dart';
import 'savedDiet.dart';
import 'appBar.dart';

class PersonalForm extends StatefulWidget {
  @override
  _PersonalForm createState() => _PersonalForm();
}

class _PersonalForm extends State<PersonalForm> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _bmiController = TextEditingController();
  final _strengthController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _purposeList = [
    DropdownMenuItem(child: Center(child: Text('다이어트')), value: 1),
    DropdownMenuItem(child: Center(child: Text('벌크업')), value: 2),
    DropdownMenuItem(child: Center(child: Text('린매스업')), value: 3),
    DropdownMenuItem(child: Center(child: Text('빈둥빈둥')), value: 4),
    DropdownMenuItem(child: Center(child: Text('좌식업무')), value: 5),
    DropdownMenuItem(child: Center(child: Text('돌아다니는 업무')), value: 6),
    DropdownMenuItem(child: Center(child: Text('활동적인 업무')), value: 7),
    DropdownMenuItem(child: Center(child: Text('일반 직장인')), value: 8),
    DropdownMenuItem(child: Center(child: Text('휴가 직장인')), value: 9)
  ];
  int _selValue = 1;

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _bmiController.dispose();
    _strengthController.dispose();
    //_purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          currentFocus.unfocus();
        },
        onDoubleTap: () {
          // Navigator.pushNamed(context, '/saving');
        },
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: basicAppBar('Personal Form', context),
          drawer: NavDrawer(),
          body: Center(
              child: Form(
            key: _formKey,
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                // Spacer(
                //   flex: 1,
                // ),
                subBuilderQuestion("키", "CM",
                    controller: _heightController,
                    icon: Icon(Icons.accessibility)),
                subBuilderQuestion("몸무게", "KG",
                    controller: _weightController,
                    icon: Icon(Icons.accessibility)),
                subBuilderQuestion("체지방률", "%",
                    controller: _bmiController,
                    icon: Icon(Icons.directions_run)),
                subBuilderQuestion("골격근량", "KG/%",
                    controller: _strengthController,
                    icon: Icon(Icons.fitness_center)),
                subBuilderPurpose("목표", icon: Icon(Icons.accessibility)),
                Spacer(
                  flex: 1,
                ),
                Spacer(
                  flex: 2,
                ),
              ],
            ),
          )),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.done),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                Navigator.pushNamed(context, '/saving');
              }
              ;
              //print(_heightController.text);
            },
          ),
        ));
  }

  Widget subBuilderQuestion(var question, var unit,
      {var controller, var icon}) {
    return Expanded(
        flex: 1,
        child: Center(
            child: Row(
          children: [
            Spacer(
              flex: 1,
            ),
            spacer_icon(icon: icon),
            spacer_question(question),
            Expanded(flex: 6, child: questionForm(controller)),
            spacer_unit(unit),
            Spacer(
              flex: 1,
            ),
          ],
        )));
  }

  Widget subBuilderPurpose(var question, {var icon}) {
    return Expanded(
        flex: 1,
        child: Center(
            child: Row(
          children: [
            Spacer(
              flex: 1,
            ),
            spacer_icon(icon: icon),
            spacer_question(question),
            Expanded(flex: 8, child: pruposeForm()),
            Spacer(
              flex: 2,
            ),
          ],
        )));
  }

  Widget questionForm(TextEditingController controller) {
    return TextFormField(
      autofocus: false,
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(hintText: ''),
      textAlign: TextAlign.center,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter info';
        }
        return null;
      },
    );
  }

  Widget pruposeForm() {
    return DropdownButtonFormField(
      value: _selValue,
      items: _purposeList,
      decoration: InputDecoration(hintText: ""),
      validator: (value) {
        if (value > 3) {
          return 'Select Number 1-3';
        }
        return null;
      },
      onChanged: (value) {
        _selValue = value;
      },
      onSaved: (value) {
        print(value);
      },
    );
  }

  Widget spacer_icon({var icon}) {
    return Expanded(flex: 1, child: Center(child: icon));
  }

  Widget spacer_question(var question) {
    return Expanded(
        flex: 4,
        child: Center(
          child: Text(
            question,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
          ),
        ));
  }

  Widget spacer_unit(var unit) {
    return Expanded(
        flex: 3,
        child: Center(
          child: Text(
            unit,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
          ),
        ));
  }
}
