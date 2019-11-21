import 'package:flutter/material.dart';
import 'package:flutter_plugin_umpush/flutter_plugin_umpush.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _pushData = '别名alias';
  String _deviceToken = '设备token';

  FlutterPluginUmpush _flutterUmpush;

  @override
  void initState() {
    super.initState();
    _flutterUmpush = FlutterPluginUmpush.instance;
    initPushState();
  }

  ///初始化友盟推送
  Future<void> initPushState() async {
    _flutterUmpush.configure(
      onMessage: (String message) async {
        print("main onMessage: $message");
        setState(() {
          _deviceToken = message;
        });
        return true;
      },
      onLaunch: (String message) async {
        print("main onLaunch: $message");
        setState(() {
          _pushData = message;
        });
        return true;
      },

      ///获取deviceToken
      deviceToken: (String message) async {
        print("main deviceToken: $message");
        setState(() {
          _deviceToken = message;
        });
        return true;
      },

      /// 设置别名的回调
      onAlias: (String token) async {
        print("main onToken: $token");
        setState(() {
          _pushData = token;
        });
        return true;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              RaisedButton(
                child: Text("get device token "),
                onPressed: () {
                  _flutterUmpush.getDeviceToken();
                },
              ),
              Text('设备deviceToken   $_deviceToken'),
              Container(
                height: 100,
              ),
              RaisedButton(
                child: Text("设置别名"),
                onPressed: () {
                  _flutterUmpush.setAlias("alias");
                },
              ),
              Text('设置的别名 alias  $_pushData'),
            ],
          ),
        ),
      ),
    );
  }
}
