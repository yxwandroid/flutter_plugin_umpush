import 'package:flutter/material.dart';
import 'package:flutter_plugin_umpush/flutter_plugin_umpush.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _pushData = 'Unknown';


  FlutterPluginUmpush _flutterUmpush;
  @override
  void initState() {
    super.initState();
    _flutterUmpush = FlutterPluginUmpush.instance;
    initPushState();
  }




  Future<void> initPushState() async {
    _flutterUmpush.configure(
      onMessage: (String message) async {
        print("main onMessage: $message");
        setState(() {
          _pushData = message;
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
      onResume: (String message) async {
        print("main onResume: $message");
        setState(() {
          _pushData = message;
        });
        return true;
      },
      onToken: (String token) async {
        print("main onToken: $token");
        setState(() {
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
        body: Center(
          child: Text('Running on: $_pushData\n'),
        ),
      floatingActionButton: FloatingActionButton(
        child: Text("333"),
        onPressed: (){
          _flutterUmpush.getToken("token");
        },
      ),
      ),

    );
  }
}
