import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:warehouser/model/Product.dart';
import 'package:warehouser/services/resource.dart';

class EditProductPage extends StatelessWidget {
  final String productId;
  final Map<String, dynamic> update = Map();

  EditProductPage({Key key, this.productId}) : super(key: key);

  void _update() async {
    await ResourceService.updateProduct(productId, update);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.cloud_upload),
              onPressed: () => _update),
        ],
      ),
      body: FutureBuilder<Product>(
        future: ResourceService.getProduct(productId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final product = snapshot.data;
            return Column(
              children: <Widget>[
                TextField(
                  controller: TextEditingController()
                    ..text = product.manufacturer,
                  onChanged: (text) => update['manufacturer'] =
                      text != product.manufacturer ? text : null,
                ),
                TextField(
                  controller: TextEditingController()
                    ..text = snapshot.data.model,
                  onChanged: (text) =>
                      update['model'] = text != product.model ? text : null,
                ),
                TextField(
                  controller: TextEditingController()
                    ..text = snapshot.data.price.toString(),
                  onChanged: (text) => update['price'] =
                      int.tryParse(text) != product.price
                          ? int.tryParse(text)
                          : null,
                ),
                TextField(
                  controller: TextEditingController()
                    ..text = snapshot.data.quantity.toString(),
                  onChanged: (text) => update['quantity'] =
                      int.tryParse(text) != product.quantity
                          ? int.tryParse(text)
                          : null,
                ),
              ],
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
