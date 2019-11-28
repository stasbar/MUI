import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:warehouser/model/Product.dart';
import 'package:warehouser/services/resource.dart';
import 'package:warehouser/utils/colors.dart';

class EditProductPage extends StatefulWidget {
  final Product product;

  EditProductPage({Key key, this.product}) : super(key: key);

  @override
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _product = Map();

  Exception _exception;
  int _delta;

  @override
  void initState() {
    if (isInEditModel()) {
      fetchProduct();
    }
    super.initState();
  }

  bool isInEditModel() => widget.product != null;

  void _changeDelta(String text) {
    setState(() {
      _delta = int.tryParse(text) != null ? int.tryParse(text) : 0;
    });
  }

  Future fetchProduct() async {
    setState(() {
      _product = widget.product.toJson();
    });
  }

  void _submit(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      if (isInEditModel()) {
        verbose(context, () {
          var product = Product.fromJson(_product);
          ResourceService.updateProduct(product);
        });
      } else {
        final product = new Product.fromJson(_product);
        verbose(context, () => ResourceService.createProduct(product));
      }
    }
  }

  void _delete(BuildContext context) async {
    verbose(context, () => ResourceService.deleteProduct(widget.product.id));
  }

  void _decreaseDelta(BuildContext context) async {
    _performDelta(context, -_delta);
  }

  void _increaseDelta(BuildContext context) {
    _performDelta(context, _delta);
  }

  void _performDelta(BuildContext context, int delta) {
    verbose(context, () {
      print(_delta);
      if (delta == null || delta == 0) {
        throw new Exception("Please enter value first");
      } else {
        var product = Product.fromJson(_product);
        ResourceService.deltaQuantity(product, delta);
      }
    });
  }

  void verbose(BuildContext context, Function func) async {
    try {
      await func();
      Navigator.pop(context);
    } catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBar = Padding(
      padding: EdgeInsets.only(bottom: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );

    final pageTitle = Container(
      child: Text(
        "${isInEditModel() ? "Edit" : "Create"} Product",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 40.0,
        ),
      ),
    );

    final submitBtn = (BuildContext context) => Container(
          margin: EdgeInsets.only(top: 40.0),
          height: 60.0,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7.0),
            border: Border.all(color: Colors.white),
            color: Colors.white,
          ),
          child: RaisedButton(
            elevation: 5.0,
            onPressed: () => _submit(context),
            color: Colors.white,
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(7.0),
            ),
            child: Text(
              isInEditModel() ? 'UPDATE' : 'CREATE',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20.0,
              ),
            ),
          ),
        );

    final deleteBtn = (context) => InkWell(
          onTap: () => _delete(context),
          child: Container(
            height: 60.0,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7.0),
              border: Border.all(color: Colors.white),
              color: Colors.transparent,
            ),
            child: Center(
              child: Text(
                'DELETE',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
    final form = (Product product) => Padding(
          padding: EdgeInsets.only(top: 30.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Manufacturer',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  style: TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Can not be empty';
                    }
                    return null;
                  },
                  onChanged: (text) => _product['manufacturer'] =
                      product == null || text != product.manufacturer
                          ? text
                          : null,
                  initialValue: product != null ? product.manufacturer : "",
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Model',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  style: TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Can not be empty';
                    }
                    return null;
                  },
                  onChanged: (text) => _product['model'] =
                      product == null || text != product.model ? text : null,
                  initialValue: product != null ? product.model : "",
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Price',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  style: TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Can not be empty';
                    }
                    return null;
                  },
                  onChanged: (text) => _product['price'] =
                      product == null || int.tryParse(text) != product.price
                          ? int.tryParse(text)
                          : null,
                  initialValue: product != null ? product.price.toString() : "",
                ),
              ],
            ),
          ),
        );

    final deltaView = (BuildContext context) => Row(
          children: <Widget>[
            IconButton(
              onPressed: () => _decreaseDelta(context),
              icon: Icon(
                Icons.remove,
                color: Colors.white,
              ),
            ),
            Expanded(
              child: TextField(onChanged: (text) => _changeDelta(text)),
            ),
            IconButton(
              onPressed: () => _increaseDelta(context),
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ],
        );

    Widget mainContent;
    if (isInEditModel()) {
      if (_exception == null) {
        mainContent = form(Product.fromJson(_product));
      } else if (_exception != null) {
        mainContent = Text("Exception: ${_exception.toString()}");
      } else {}
    } else {
      mainContent = form(null);
    }

    return Scaffold(
      body: Builder(builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(top: 40.0),
            decoration: BoxDecoration(gradient: primaryGradient),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: <Widget>[
                appBar,
                Container(
                  padding: EdgeInsets.only(left: 30.0, right: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      pageTitle,
                      mainContent,
                      Visibility(
                          visible: isInEditModel(), child: deltaView(context)),
                      submitBtn(context),
                      Visibility(
                          visible: isInEditModel(), child: deleteBtn(context)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
