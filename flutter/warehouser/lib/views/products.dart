import 'package:flutter/material.dart';
import 'package:warehouser/_routing/routes.dart';
import '../model/Product.dart';
import '../services/resource.dart';

class ProductsPage extends StatelessWidget {
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
                return _buildRow(context, product);
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

  Widget _buildRow(BuildContext context, Product product) {
    return ListTile(
      title: Text(
        product.manufacturer + "" + product.model,
      ),
      subtitle: Text("\$${product.price} QA:${product.quantity}"),
      trailing: Icon(Icons.phone_android),
      onTap: () => Navigator.pushNamed(context, editProductViewPage, arguments: product.id),
    );
  }
}
