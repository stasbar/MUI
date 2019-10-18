import 'package:flutter/material.dart';
import 'package:warehouser/items.dart';

// import the io version
import 'package:flutter_appauth/flutter_appauth.dart';

void main() => runApp(MyApp());

const googleClientId =
    "960807507840-ts3874na6r9h6ctrp5mig0fjgnjoc020.apps.googleusercontent.com";
const googleUri = "https://accounts.google.com/o/oauth2/v2/auth";

FlutterAppAuth appAuth = FlutterAppAuth();

Future<AuthorizationTokenResponse> authenticate(
    String issuerUri, String clientId, List<String> scopes) async {
  // create the client
  var result = await appAuth.authorizeAndExchangeCode(
    AuthorizationTokenRequest(
      clientId,
      'com.stasbar.warehouser:/oauth2redirect',
      issuer: issuerUri,
      scopes: scopes,
    ),
  );
  print(result);
  print(result.accessToken);
  print(result.authorizationAdditionalParameters);
  print(result.idToken);
  print(result.tokenAdditionalParameters);
  print(result.tokenType);
  return result;
}

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
  String accessToken = "";

  void _pushSaved() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return ProductsPage();
    }));
  }

  void _auth() async {
    var result = await authenticate('https://accounts.google.com',
        googleClientId, ["openid", "email", "profile"]);
    setState(() {
      idToken = result.idToken;
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
          IconButton(icon: Icon(Icons.assignment_ind), onPressed: _auth),
        ],
      ),
      body: Column(children: [
        Text("idToken: " + idToken),
        Text("accessToken:" + accessToken)
      ]),
    );
  }
}
