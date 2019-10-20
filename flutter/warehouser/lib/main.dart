import 'package:flutter/material.dart';
import 'package:warehouser/items.dart';

import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'auth.dart';

// import the io version

void main() => runApp(MyApp());


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String idToken = "";
  String userId = "";
  String accessToken = "";

  void _pushSaved() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return ProductsPage();
    }));
  }

  void _authGoogle() async {
    var result = await authenticateGoogle();
    setState(() {
      idToken = result.idToken;
      accessToken = result.accessToken;
    });
  }

  void _authFacebook() async {
    var result = await authenticateFacebook();
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        setState(() {
          userId = result.accessToken.userId;
          accessToken = result.accessToken.token;
        });
        break;
      case FacebookLoginStatus.cancelledByUser:
        setState(() {
          userId = "cancelByUser";
        });
        break;
      case FacebookLoginStatus.error:
        setState(() {
          userId = result.errorMessage;
        });
        break;
    }
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
          IconButton(icon: Icon(Icons.assignment_ind), onPressed: _authGoogle),
          IconButton(icon: Icon(Icons.face), onPressed: _authFacebook),
        ],
      ),
      body: Column(children: [
        Text("idToken: " + idToken),
        Text("accessToken:" + accessToken),
        Text("userId:" + userId)
      ]),
    );
  }
}
