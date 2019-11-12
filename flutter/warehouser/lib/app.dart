import 'package:flutter/material.dart';
import 'package:warehouser/_routing/router.dart' as router;
import 'package:warehouser/_routing/routes.dart';
import 'package:warehouser/theme.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warehourser',
      debugShowCheckedModeBanner: false,
      theme: buildThemeData(),
      onGenerateRoute: router.generateRoute,
      initialRoute: loginViewRoute,
    );
  }
}
