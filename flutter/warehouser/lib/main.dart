import 'package:flutter/material.dart';
import 'package:warehouser/items.dart';

import 'model/User.dart';
import 'services/resource.dart';
import 'services/authorization.dart';

// import the io version

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warehourser',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: MyHomePage(title: 'Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  User user;
  String message = "";

  void _pushSaved() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return ProductsPage();
    }));
  }

  Function _auth(Provider provider) {
    return () async {
      await AuthorizationService.authenticate(provider);
      _fetchCurrentUser();
    };
  }

  void _fetchCurrentUser() async {
    var userResult = await ResourceService.currentUser();
    setState(() {
      user = userResult;
    });
  }

  void _logout() async {
    await AuthorizationService.logout();
    setState(() {
      user = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(children: [
                RaisedButton(
                    child: Text("Google"), onPressed: _auth(Provider.GOOGLE)),
              ]),
              Column(children: [
                RaisedButton(
                    child: Text("Facebook"),
                    onPressed: _auth(Provider.FACEBOOK)),
              ]),
              Column(children: [
                RaisedButton(
                    child: Text("Warehourser"),
                    onPressed: _auth(Provider.WAREHOUSER)),
              ]),
              Column(children: [
                RaisedButton(child: Text("Logout"), onPressed: _logout),
              ]),
            ],
          ),
          Card(
              child: ListTile(
            title: Text("User Email"),
            subtitle: Text(user != null ? user.email : "Unknown"),
          )),
          Card(
              child: ListTile(
            title: Text("User Role"),
            subtitle: Text(user != null ? user.role : "Unknown"),
          )),
          Card(
              child: ListTile(
            title: Text("message"),
            subtitle: Text(message),
          )),
        ]),
      ),
    );
  }
}
