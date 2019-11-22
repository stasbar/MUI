import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppConfig {
  static const appName = "Warehouser";
  static const appTagline =
      "Let's make this world,\n\t\t\t\t\t\t\tbetter place";
}

class AvailableFonts {
  static const primaryFont = "Quicksand";
}

class AvailableImages {
  static const appLogo = const AssetImage('assets/images/logo.png');
}

toast(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}
