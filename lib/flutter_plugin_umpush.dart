import 'dart:async';
import 'dart:ffi';

import 'package:flutter/services.dart';


typedef Future<dynamic> MessageHandler(String message);
class FlutterPluginUmpush {

  MethodChannel _channel;

  MessageHandler _onMessage;
  MessageHandler _onLaunch;
  MessageHandler _onResume;
  MessageHandler _onToken;




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
    MessageHandler onResume,
    MessageHandler onToken,
  }) {
    _onMessage = onMessage;
    _onLaunch = onLaunch;
    _onResume = onResume;
    _onToken = onToken;
    _channel.invokeMethod('configure');
  }




  ///flutter -> native  获取友盟注册成功的token
  Future<void> getToken(String token) async {
    _channel.invokeMethod("getToken", {"token": token});
  }



  /// native -> flutter
  Future<void> _handler(MethodCall call) async {
    switch (call.method) {
      case "onToken":
        final String token = call.arguments;
        print('FlutterUmpush onToken: $token');
        _onToken(token);
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
      case "onResume":
        final String message = call.arguments;
        print('FlutterUmpush onResume: $message');
        _onResume(call.arguments.cast<String>());
        return null;
      case "onGetToken":
        final String message = call.arguments;
        print('FlutterUmpush onGetToken: $message');
        _onToken(message);
        return null;

      default:
        throw new UnsupportedError("Unrecognized JSON message");
    }

  }
}
