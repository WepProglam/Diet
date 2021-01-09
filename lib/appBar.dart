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
    //메뉴
    // leading: IconButton(
    //   icon: Icon(Icons.menu),
    //   //눌렀을 때 기능 추후에 추가
    //   onPressed: () {},
    // ),

    //앱 이름
    title: Text(title),
    //마이페이지
    actions: <Widget>[
      IconButton(
        icon: Icon(Icons.person),
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
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.input),
            title: Text('addFood'),
            onTap: () {
              // print(ModalRoute.of(context).settings.name);
              Navigator.pushNamed(context, '/addFood');
              print(ModalRoute.of(context).settings.name);
            },
          ),
          ListTile(
            leading: Icon(Icons.verified_user),
            title: Text('personalForm'),
            onTap: () {
              // print(ModalRoute.of(context).settings.name);
              Navigator.pushNamed(context, '/personalForm');
              print(ModalRoute.of(context).settings.name);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('savedDiet'),
            onTap: () {
              // print(ModalRoute.of(context).settings.name);
              Navigator.pushNamed(context, '/savedDiet');
              print(ModalRoute.of(context).settings.name);
            },
          ),
          ListTile(
            leading: Icon(Icons.border_color),
            title: Text('savedFood'),
            onTap: () {
              // print(ModalRoute.of(context).settings.name);
              Navigator.pushNamed(context, '/savedFood');
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
