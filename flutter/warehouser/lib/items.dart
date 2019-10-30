import 'package:flutter/material.dart';
import 'model/Product.dart';
import 'services/resource.dart';

class ProductsPage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Products',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: Products(),
    );
  }
}

class Products extends StatefulWidget {
  @override
  ProductsState createState() => ProductsState();
}

class ProductsState extends State<Products> {
  final TextStyle _biggerFont = const TextStyle(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
      ),
      body: FutureBuilder<List<Product>>(
        future: ResourceService.fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext _context, int i) {
                final product = snapshot.data[i];
                return _buildRow(product);
              },
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

  Widget _buildRow(Product product) {
    return ListTile(
      title: Text(
        product.manufacturer + "" + product.model,
        style: _biggerFont,
      ),
      subtitle: Text("\$${product.price} QA:${product.quantity}"),
      trailing: Icon(Icons.phone_android),
    );
  }
}
