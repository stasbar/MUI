import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:warehouser/_routing/routes.dart';
import '../../model/Product.dart';
import '../../services/resource.dart';

class ProductsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Product> _products;
  Exception _exception;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    fetchProducts();
    super.initState();
  }

  Future fetchProducts() async {
    try {
      final products = await ResourceService.getAllProducts();
      setState(() {
        _products = products;
        _exception = null;
      });
    } catch (e) {
      setState(() {
        _products = null;
        _exception = e;
      });
    }
  }

  void _onRefresh() async {
    print("onRefresh");
    await fetchProducts();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent;
    if (_products == null && _exception == null) {
      mainContent = CircularProgressIndicator();
    } else if (_exception != null) {
      mainContent = Text("Exception: ${_exception.toString()}");
    } else {
      mainContent = ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _products.length,
        itemBuilder: (BuildContext _context, int i) {
          final product = _products[i];
          return _buildRow(context, product);
        },
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Products'),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.add),
                onPressed: () =>
                    Navigator.pushNamed(context, createProductViewPage)),
          ],
        ),
        body: SmartRefresher(
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: mainContent));
  }

  Widget _buildRow(BuildContext context, Product product) {
    return ListTile(
      title: Text(
        product.manufacturer + "  " + product.model,
      ),
      subtitle: Text("\$${product.price} QA:${product.quantity}"),
      trailing: Icon(Icons.phone_android),
      onTap: () => Navigator.pushNamed(context, editProductViewPage,
          arguments: product.id),
    );
  }
}
