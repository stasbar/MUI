import 'package:flutter/material.dart';
import 'package:warehouser/_routing/routes.dart';

import '../model/User.dart';
import '../services/resource.dart';

class HomePage extends StatelessWidget {
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
        title: Text("Home"),
      ),

      body: FutureBuilder<User>(
        future: ResourceService.currentUser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final user = snapshot.data;
            return SingleChildScrollView(
              child: Column(children: [
                Card(
                    child: ListTile(
                      title: Text("Email"),
                      subtitle: Text(user != null ? user.email : "Unknown"),
                    )),
                Card(
                    child: ListTile(
                      title: Text("Role"),
                      subtitle: Text(user != null ? user.role : "Unknown"),
                    )),
                Card(
                    child: FlatButton(
                      child: Text("Show Products"),
                      onPressed: () => Navigator.pushNamed(context, productsViewRoute),
                    )),
              ]),
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          // By default, show a loading spinner.
          return CircularProgressIndicator();
        },
      ),
    );
  }
}
