import 'package:flutter/material.dart';
import 'appBar.dart';

class AddFood extends StatefulWidget {
  @override
  _AddFood createState() => _AddFood();
}

class _AddFood extends State<AddFood> {
  final _carboController = TextEditingController();
  final _proController = TextEditingController();
  final _fatController = TextEditingController();
  final _ulController = TextEditingController();
  final _foodNameController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _carboController.dispose();
    _proController.dispose();
    _fatController.dispose();
    _ulController.dispose();
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
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: basicAppBar('Add Food', context),
          drawer: NavDrawer(),
          body: Center(
              child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(
                  flex: 2,
                ),
                searchBar(_foodNameController),
                subBuilderQuestion("탄수화물", "g",
                    controller: _carboController, icon: Icon(Icons.favorite)),
                subBuilderQuestion("단백질", "g",
                    controller: _proController,
                    icon: Icon(Icons.restaurant_menu_outlined)),
                subBuilderQuestion("지방", "g",
                    controller: _fatController,
                    icon: Icon(Icons.restaurant_outlined)),
                subBuilderQuestion("열량?", "g",
                    controller: _ulController,
                    icon: Icon(Icons.restaurant_menu_sharp)),
                Spacer(
                  flex: 1,
                ),
                Spacer(
                  flex: 3,
                ),
              ],
            ),
          )),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.done),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                print(_carboController.value.text);
                Navigator.pushNamed(context, '/saving');
              }
            },
          ),
        ));
  }

  Widget searchBar(var controller) {
    return Expanded(
        flex: 2,
        child: Center(
            child: Row(
          children: [
            Spacer(
              flex: 1,
            ),
            // spacer_icon(icon: icon),
            // spacer_question(question),
            Expanded(
                flex: 2,
                child: TextFormField(
                  autofocus: false,
                  controller: controller,
                  // keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Type Food Name'),
                  textAlign: TextAlign.center,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter info';
                    }
                    return null;
                  },
                )),
            // spacer_unit(unit),
            Spacer(
              flex: 1,
            ),
          ],
        )));
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
            // spacer_icon(icon: icon),
            spacer_question(question),
            Expanded(flex: 6, child: questionForm(controller)),
            spacer_unit(unit),
            Spacer(
              flex: 1,
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

  Widget spacer_icon({var icon}) {
    return Expanded(flex: 1, child: Center(child: icon));
  }

  Widget spacer_question(var question) {
    return Expanded(
        flex: 4,
        child: Center(
          child: Text(question),
        ));
  }

  Widget spacer_unit(var unit) {
    return Expanded(
        flex: 3,
        child: Center(
          child: Text(unit),
        ));
  }
}
