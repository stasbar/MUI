import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warehouser/app.dart';
import 'package:warehouser/utils/colors.dart';
import 'package:uuid/uuid.dart';
import 'package:warehouser/utils/const.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: primaryDark));
  generateInstallationId();
  runApp(App());
}

void generateInstallationId() async {
  final prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey(INSTALLATION_ID)) {
    var uuid = Uuid();
    prefs.setString(INSTALLATION_ID, uuid.v4());
  }
}
