import 'package:flutter/material.dart';
import 'model/Product.dart';
import 'services/resource.dart';

class ProductsPage extends StatelessWidget {
  ProductsPage(this.resService);

  final ResourceService resService;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Products',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: Products(resService),
    );
  }
}

class Products extends StatefulWidget {
  Products(this.resService);

  final ResourceService resService;

  @override
  ProductsState createState() => ProductsState(resService);
}

class ProductsState extends State<Products> {
  ProductsState(this.resService);

  final ResourceService resService;
  final TextStyle _biggerFont = const TextStyle(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
      ),
      body: FutureBuilder<List<Product>>(
        future: resService.fetchProducts(),
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
