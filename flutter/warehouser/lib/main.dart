import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:warehouser/app.dart';
import 'package:warehouser/utils/colors.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: primaryDark));
  runApp(App());
}
