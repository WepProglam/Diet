import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/all.dart';
import 'appBar.dart';

const clientId = "95999b99c7e646e06ec5988f6687540e";
const javascriptId = "ad2a9c300925d996c5968a56f38231eb";

void main() {
  KakaoContext.clientId = clientId;
  KakaoContext.javascriptClientId = javascriptId;

  runApp(MyApp2());
}

class MyApp2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: KaKaoLogin(),
    );
  }
}

class KaKaoLogin extends StatefulWidget {
  @override
  _KakaoLoginState createState() => _KakaoLoginState();
}

class _KakaoLoginState extends State<KaKaoLogin> {
  bool _isKakaoTalkInstalled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: basicAppBar('kakao login', context),
      body: Center(
        child: InkWell(
          onTap: () => _isKakaoTalkInstalled ? _loginWithTalk : _loginWithKakao,
          child: Container(
            width: MediaQuery.of(context).size.width + 0.6,
            height: MediaQuery.of(context).size.height * 0.07,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: Colors.yellow),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble,
                  color: Colors.black54,
                ),
                SizedBox(
                  width: 10,
                ),
                Text("카카오계정 로그인")
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    _initKakaoInstalled();
    super.initState();
  }

  _initKakaoInstalled() async {
    final installed = await isKakaoTalkInstalled();
    print('kakao install : ' + installed.toString());

    setState(() {
      _isKakaoTalkInstalled = installed;
    });
  }

  _issueAccessToken(String authCode) async {
    try {
      var token = await AuthApi.instance.issueAccessToken(authCode);
      AccessTokenStore.instance.toStore(token);
      print(token);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyApp2(),
          ));
    } catch (e) {
      print(e.toString());
    }
  }

  _loginWithKakao() async {
    try {
      var code = await AuthCodeClient.instance.request();
      await _issueAccessToken(code);
    } catch (e) {
      print(e.toString());
    }
  }

  _loginWithTalk() async {
    try {
      var code = await AuthCodeClient.instance.requestWithTalk();
      await _issueAccessToken(code);
    } catch (e) {
      print(e.toString());
    }
  }
}
