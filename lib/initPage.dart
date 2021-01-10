import 'package:flutter/material.dart';

class InitPage extends StatefulWidget {
  @override
  _InitPage createState() => _InitPage();
}

class _InitPage extends State<InitPage> {
  bool selected = false;
  bool selChild = false;
  bool _condition = true;
  bool changed = false;

  @override
  Widget build(context) {
    return GestureDetector(
        onTap: _condition
            ? () {
                // making it false when onTap() is pressed and after 1 second we'll make it true
                setState(() => _condition = false);
                Future.delayed(Duration(milliseconds: 2500),
                    () => setState(() => _condition = true));
                setState(() {
                  selChild = !selChild;
                  selected = !selected;
                  Future.delayed(const Duration(milliseconds: 1200), () {
                    setState(() {
                      selected = !selected;
                      selChild = !selChild;
                    });
                  });
                });
                // your implementation
              }
            : null,
        onDoubleTap: () {
          Navigator.pushNamed(context, '/mainPage');
          setState(() {
            selected = false;
            changed = true;
            //selChild = false;
          });
        },
        child: Container(
          child: Center(
              child: AnimatedContainer(
                  onEnd: () {
                    if (changed == false) {
                      Navigator.pushNamed(context, '/mainPage');
                    }
                    setState(() {
                      selected = false;
                      //selChild = false;
                    });
                  },
                  width: selected ? 500.0 : 200.0,
                  height: selected ? 200.0 : 500.0,
                  alignment:
                      selected ? Alignment.center : AlignmentDirectional.center,
                  duration: Duration(milliseconds: 1500),
                  color: selected ? Colors.redAccent : Colors.blueAccent,
                  curve: Curves.fastOutSlowIn,
                  child: selChild
                      ? Icon(
                          Icons.accessibility_new,
                          size: 75,
                        )
                      : Icon(
                          Icons.accessibility,
                          size: 75,
                        ))),
          color: Colors.white,
        ));
    // onTap: ;
  }
}
