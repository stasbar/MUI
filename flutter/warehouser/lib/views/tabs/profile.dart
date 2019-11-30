import 'package:flutter/material.dart';
import 'package:warehouser/_routing/routes.dart';
import 'package:warehouser/model/User.dart';
import 'package:warehouser/services/authorization.dart';
import 'package:warehouser/services/resource.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePage createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage>{
  User _currentUser;
  Exception _exception;
  String _installationId;

  @override
  void initState() {
    fetchCurrentUser();
    fetchInstallationId();
    super.initState();
  }

  void fetchCurrentUser() async {
    try {
      final theCurrentUser = await ResourceService.currentUser();
      AuthorizationService.currentUser = theCurrentUser;
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

  void fetchInstallationId() async {
    _installationId = await ResourceService.getInstallationId();
  }


  void _logout() async {
    await AuthorizationService.logout();
    Navigator.pushReplacementNamed(context, loginViewRoute);
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
              child: ListTile(
                title: Text("DeviceId"),
                subtitle: Text(_installationId),
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