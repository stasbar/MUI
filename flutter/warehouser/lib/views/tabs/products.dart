import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:warehouser/_routing/routes.dart';
import 'package:warehouser/dao/productsDao.dart';
import 'package:warehouser/utils/utils.dart';
import '../../model/Product.dart';
import '../../services/resource.dart';

class ProductsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Product> _products;
  List<String> _warehouses = [];
  String _dropdownValue;
  Error _exception;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    fetchProducts();
    fetchWarehouses();
    _refreshController.refreshCompleted();
    super.initState();
  }

  Future fetchWarehouses() async {
    try {
      List<String> warehouses = await ResourceService.getAllWarehouses();
      String warehouse = await ProductsDao.getWarehouse(warehouses[0]);
      print(warehouses);
      setState(() {
        _warehouses = warehouses;
        _dropdownValue = warehouse;
        _exception = null;
      });
    } catch (e) {
      setState(() {
        _warehouses = null;
        _exception = e;
      });
      throw e;
    }
  }

  Future fetchProducts() async {
    try {
      final products = await ResourceService.getAllProducts();
      setState(() {
        _products = products.where((product) => !product.deleted).toList();
        _exception = null;
      });
    } catch (e) {
      setState(() {
        _products = null;
        _exception = e;
      });
      throw e;
    }
  }

  void _onRefresh() async {
    print("onRefresh");
    await fetchProducts();
    _refreshController.refreshCompleted();
  }

  Future _synchronize(BuildContext context) async {
    verbose(context, () async {
      await ResourceService.synchronize();
      toast("synchronization complete");
    });
  }

  void verbose(BuildContext context, Function func) async {
    try {
      await func();
    } catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent;
    if (_products == null && _exception == null) {
      mainContent = CircularProgressIndicator();
    } else if (_exception != null) {
      mainContent = Text("Exception: ${_exception.toString()}");
    } else if (_products != null) {
      mainContent = Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _products.length,
          itemBuilder: (BuildContext _context, int i) {
            final product = _products[i];
            return _buildRow(context, product);
          },
        ),
      );
    }
    Widget warehouses;
    if (_warehouses != null) {
      warehouses = DropdownButton(
        value: _dropdownValue,
        icon: Icon(Icons.arrow_downward),
        iconSize: 24,
        elevation: 16,
        style: TextStyle(color: Colors.deepPurple),
        underline: Container(
          height: 2,
          color: Colors.deepPurpleAccent,
        ),
        onChanged: (String newValue) {
          setState(() {
            _dropdownValue = newValue;
          });
          ProductsDao.setWarehouse(newValue);
        },
        items: _warehouses.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      );
    } else {
      warehouses = Text("Failed to fetch warehouses");
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Products'),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.add),
                onPressed: () =>
                    Navigator.pushNamed(context, createProductViewPage)),
            IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () => _synchronize(context)),
          ],
        ),
        body: SmartRefresher(
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: Column(children: [warehouses, mainContent])));
  }

  Widget _buildRow(BuildContext context, Product product) {
    return ListTile(
      title: Text(
        product.manufacturer + "  " + product.model,
      ),
      subtitle: Text(
          "\$${product.price} QA:${product.quantity} Local: ${product.quantityLocal} Rem: ${product.quantityRem}"),
      trailing: Icon(Icons.phone_android),
      onTap: () =>
          Navigator.pushNamed(context, editProductViewPage, arguments: product),
    );
  }
}
