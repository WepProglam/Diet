// import 'dart:html';
import 'package:flutter/material.dart';

// class ScaffoldAppBar extends StatelessWidget {
//   var body;
//   String title;
//   var attribute;

//   ScaffoldAppBar({var body, var title, var attribute}) {
//     this.body = body;
//     this.title = title;
//     this.attribute = attribute;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: NavDrawer(),
//       appBar: basicAppBar(
//         title,
//         context,
//       ),
//       body: body,
//     );
//   }
// }

Widget basicAppBar(String title, BuildContext context) {
  return AppBar(
    //color
    // backgroundColor: Colors.deepOrangeAccent,
    iconTheme: IconThemeData(color: Colors.white),

    //앱 이름
    centerTitle: true,
    title: Text(
      title, /* style: TextStyle(color: Colors.white) */
    ),
    //마이페이지
    actions: <Widget>[
      IconButton(
        icon: Icon(
          Icons.person,
        ),
        onPressed: () {
          Navigator.pushNamed(context, '/personalForm');
        },
      ),
    ],
  );
}

class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.all(5),
        children: <Widget>[
          Container(
            height: 150,
            child: DrawerHeader(
              child: Text(
                'Side menu',
                style: TextStyle(fontSize: 25),
              ),
              // decoration: BoxDecoration(color: Colors.deepOrangeAccent),
            ),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('내 식단'),
            onTap: () {
              // print(ModalRoute.of(context).settings.name);
              Navigator.pop(context);
              Navigator.pushNamed(context, '/searchDiet');
              print(ModalRoute.of(context).settings.name);
            },
          ),
          ListTile(
            leading: Icon(Icons.border_color),
            title: Text('내 음식'),
            onTap: () {
              // print(ModalRoute.of(context).settings.name);
              Navigator.pop(context);
              Navigator.pushNamed(context, '/searchFood');
              print(ModalRoute.of(context).settings.name);
            },
          ),
          ListTile(
            leading: Icon(Icons.input),
            title: Text('식단 추가'),
            onTap: () {
              // print(ModalRoute.of(context).settings.name);
              Navigator.pop(context);
              Navigator.pushNamed(context, '/addDiet');
              print(ModalRoute.of(context).settings.name);
            },
          ),
          ListTile(
            leading: Icon(Icons.verified_user),
            title: Text('신체 정보'),
            onTap: () {
              // print(ModalRoute.of(context).settings.name);
              Navigator.pop(context);
              Navigator.pushNamed(context, '/personalForm');
              print(ModalRoute.of(context).settings.name);
            },
          ),
          ListTile(
            leading: Icon(Icons.input),
            title: Text('음식 추가'),
            onTap: () {
              // print(ModalRoute.of(context).settings.name);
              Navigator.pop(context);
              Navigator.pushNamed(context, '/addFood');
              print(ModalRoute.of(context).settings.name);
            },
          ),
        ],
      ),
    );
  }
}

// ListTile(
//             leading: Icon(Icons.input),
//             title: Text('addFood'),
//             onTap: () {
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => AddFood(),
//                   ));
//             },
//           ),
//           ListTile(
//             leading: Icon(Icons.verified_user),
//             title: Text('personalForm'),
//             onTap: () {
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => PersonalForm(),
//                   ));
//             },
//           ),
//           ListTile(
//             leading: Icon(Icons.settings),
//             title: Text('savedDiet'),
//             onTap: () {
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => SavedDiet(),
//                   ));
//             },
//           ),
//           ListTile(
//             leading: Icon(Icons.border_color),
//             title: Text('saving'),
//             onTap: () => {
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => Saving(),
//                   ))
//             },
//           ),
//         ],
//       ),
