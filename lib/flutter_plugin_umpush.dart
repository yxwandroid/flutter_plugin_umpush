import 'dart:async';
import 'dart:ffi';

import 'package:flutter/services.dart';


typedef Future<dynamic> MessageHandler(String message);


class FlutterPluginUmpush {

  MethodChannel _channel;

  MessageHandler _onMessage;
  MessageHandler _onLaunch;
  MessageHandler _deviceToken;
  MessageHandler _onAlias;




  // 工厂模式 : 单例公开访问点
  factory FlutterPluginUmpush() => _getInstance();

  static FlutterPluginUmpush get instance => _getInstance();


  ///私有化构造方法
  FlutterPluginUmpush._internal() {
    // 初始化
    _channel =  MethodChannel('flutter_plugin_umpush');
    _channel.setMethodCallHandler(_handler);
  }

  // 静态私有成员，没有初始化
  static FlutterPluginUmpush _instance;


  // 静态、同步、私有访问点
  static FlutterPluginUmpush _getInstance() {
    if (_instance == null) {
      _instance = new FlutterPluginUmpush._internal();
    }
    return _instance;
  }



  ///配置flutter 回调方法
  void configure({
    MessageHandler onMessage,
    MessageHandler onLaunch,
    MessageHandler deviceToken,
    MessageHandler onAlias,
  }) {
    _onMessage = onMessage;
    _onLaunch = onLaunch;
    _deviceToken = deviceToken;
    _onAlias = onAlias;

    initUmPush();
  }

  ///初始化友盟配置
  initUmPush(){
    _channel.invokeMethod('configure');
  }


  ///flutter -> native  setAlias   设置别名
  Future<void> setAlias(String token) async {
    _channel.invokeMethod("setAlias", {"alias": token});
  }



  ///flutter -> native get devicveToken
  Future<void> getDeviceToken() async {
     _channel.invokeMethod("deviceToken");
  }


  /// native -> flutter
  Future<void> _handler(MethodCall call) async {
    switch (call.method) {
      case "onToken":
        final String token = call.arguments;
        print('FlutterUmpush onToken: $token');
        _onAlias(token);
        return null;
      case "onMessage":
        final String message = call.arguments;
        print('FlutterUmpush onMessage: $message');
        _onMessage(message);
        return null;
      case "onLaunch":
        final String message = call.arguments;
        print('FlutterUmpush onLaunch: $message');
        _onLaunch(call.arguments.cast<String>());
        return null;
      case "onGetAlias":
        final String message = call.arguments;
        print('FlutterUmpush get alias : $message');
        _onAlias(message);
        return null;
       case "deviceToken":
        final String message = call.arguments;
        print('FlutterUmpush get deviceToken : $message');
        _deviceToken(message);
        return null;

      default:
        throw new UnsupportedError("Unrecognized JSON message");
    }

  }
}
