import 'package:flutter/material.dart';
import 'package:warehouser/items.dart';

import 'package:flutter_facebook_login/flutter_facebook_login.dart';
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
  String idToken = "";
  String userId = "";
  String accessToken = "";
  String permissions = "";
  String message = "";

  void _pushSaved() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return ProductsPage();
    }));
  }

  void _authGoogle() async {
    var result = await AuthorizationService.authenticateGoogle();
    setState(() {
      idToken = result.idToken;
    });
  }

  void _authFacebook() async {
    var result = await AuthorizationService.authenticateFacebook();
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        setState(() {
          permissions = result.accessToken.permissions.toString();
          userId = result.accessToken.userId;
          accessToken = result.accessToken.token;
        });
        break;
      case FacebookLoginStatus.cancelledByUser:
        setState(() {
          message = "cancelByUser";
        });
        break;
      case FacebookLoginStatus.error:
        setState(() {
          message = result.errorMessage;
        });
        break;
    }
  }

  void _authWarehourser() async {
    print("auth username password");
    var result = await AuthorizationService.authenticateAndToken();
    print("result: ${result.accessToken}");
    setState(() {
      message = result.authorizationAdditionalParameters.toString();
      idToken = result.idToken;
      permissions = "";
      accessToken = result.accessToken;
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
      body: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(children: [
              RaisedButton(child: Text("Google"), onPressed: _authGoogle),
              RaisedButton(
                  child: Text("Send"),
                  onPressed: () => ResourceService.exchangeGoogle(idToken)),
            ]),
            Column(children: [
              RaisedButton(child: Text("Facebook"), onPressed: _authFacebook),
              RaisedButton(
                  child: Text("Send"),
                  onPressed: () => ResourceService.exchangeFacebook(idToken)),
            ]),
            Column(children: [
              RaisedButton(
                  child: Text("Warehourser"), onPressed: _authWarehourser),
              RaisedButton(
                  child: Text("Send"),
                  onPressed: () => ResourceService.exchangeWarehouser(idToken)),
            ]),
          ],
        ),
        Card(
            child: ListTile(
          title: Text("idToken"),
          subtitle: Text(idToken),
        )),
        Card(
            child: ListTile(
          title: Text("accessToken"),
          subtitle: Text(accessToken),
        )),
        Card(
            child: ListTile(
          title: Text("userId"),
          subtitle: Text(userId),
        )),
        Card(
            child: ListTile(
          title: Text("message"),
          subtitle: Text(message),
        )),
      ]),
    );
  }
}
