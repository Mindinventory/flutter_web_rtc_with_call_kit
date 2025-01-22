import 'package:flutter/material.dart';

abstract class AppConstants {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static BuildContext get navigatorContext =>
      navigatorKey.currentState!.context;

  static Map<String, dynamic> webrtcConfiguration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302',
        ],
      }
    ]
  };
}
