import 'package:flutter/material.dart';

class InitPage extends StatefulWidget {
  @override
  _InitPage createState() => _InitPage();
}

class _InitPage extends State<InitPage> {
  bool selected = false;
  bool selChild = false;
  @override
  Widget build(context) {
    return GestureDetector(
        onTap: () {
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
        },
        child: Container(
          child: Center(
              child: AnimatedContainer(
                  onEnd: () {
                    Navigator.pushNamed(context, '/personalForm');
                    setState(() {
                      selected = false;
                      //selChild = false;
                    });
                  },
                  width: selected ? 300.0 : 100.0,
                  height: selected ? 100.0 : 300.0,
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
