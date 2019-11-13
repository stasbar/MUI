import 'package:flutter/material.dart';
import 'package:warehouser/_routing/routes.dart';
import 'package:warehouser/services/authorization.dart';

import '../model/User.dart';
import '../services/resource.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User _currentUser;
  Exception _exception;

  @override
  void initState() {
    fetchCurrentUser();
    super.initState();
  }

  void _logout() async {
    await AuthorizationService.logout();
    Navigator.pushReplacementNamed(context, loginViewRoute);
  }

  void fetchCurrentUser() async {
    try {
      final theCurrentUser = await ResourceService.currentUser();
      setState(() {
        _currentUser = theCurrentUser;
        _exception = null;
      });
    } catch (e) {
      setState(() {
        _currentUser = null;
        _exception = e;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent;
    if (_currentUser == null && _exception == null) {
      mainContent = CircularProgressIndicator();
    } else if (_exception != null) {
      mainContent = Text("Exception: ${_exception.toString()}");
    } else {
      mainContent = SingleChildScrollView(
        child: Column(children: [
          Card(
              child: ListTile(
            title: Text("Email"),
            subtitle: Text(_currentUser.email),
          )),
          Card(
              child: ListTile(
            title: Text("Role"),
            subtitle: Text(_currentUser.role),
          )),
          Card(
              child: FlatButton(
            child: Text("Show Products"),
            onPressed: () => Navigator.pushNamed(context, productsViewRoute),
          )),
        ]),
      );
    }
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text("Home"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.call_made),
              onPressed: () => _logout(),
            ),
          ],
        ),
        body: mainContent);
  }
}
