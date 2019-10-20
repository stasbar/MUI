import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:http/io_client.dart';
import 'model/Product.dart';

class ProductsPage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
        title: Text('Saved Suggestions'),
      ),
      body: FutureBuilder<List<Product>>(
        future: fetchProducts(),
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

  Future<List<Product>> fetchProducts() async {
    HttpClient httpClient = new HttpClient()
      ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = new IOClient(httpClient);
    final url = 'https://home.stasbar.com:1234/products/';
    final response = await ioClient.get(url);

    if (response.statusCode == 200) {
      final postsJson = json.decode(response.body);
      List<Product> posts = [];
      for (final post in postsJson) {
        posts.add(Product.fromJson(post));
      }
      return posts;
    } else {
      throw Exception('Filed to load product');
    }
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
