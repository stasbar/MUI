import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:warehouser/model/Product.dart';
import 'package:warehouser/services/resource.dart';
import 'package:warehouser/utils/colors.dart';

class EditProductPage extends StatefulWidget {
  final String productId;

  EditProductPage({Key key, this.productId}) : super(key: key);

  @override
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> update = Map();

  Product _product;
  Exception _exception;

  bool isInEditModel() => widget.productId != null;

  void _delete() async {
    await ResourceService.deleteProduct(widget.productId);
  }

  @override
  void initState() {
    if (isInEditModel()) {
      fetchProduct();
    }
    super.initState();
  }

  Future fetchProduct() async {
    try {
      final theProduct = await ResourceService.getProduct(widget.productId);
      setState(() {
        _product = theProduct;
        _exception = null;
      });
    } catch (e) {
      setState(() {
        _product = null;
        _exception = e;
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState.validate()) {
      if (isInEditModel()) {
        await ResourceService.updateProduct(widget.productId, update);
      } else {
        final product = new Product.fromJson(update);
        await ResourceService.createProduct(product);
      }
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

    final submitBtn = Container(
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
        onPressed: () => _submit(),
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

    final deleteBtn = InkWell(
      onTap: () => _delete(),
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
                  onChanged: (text) => update['manufacturer'] =
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
                  onChanged: (text) => update['model'] =
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
                  onChanged: (text) => update['price'] =
                      product == null || int.tryParse(text) != product.price
                          ? int.tryParse(text)
                          : null,
                  initialValue: product != null ? product.price.toString() : "",
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Quantity',
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
                  onChanged: (text) => update['quantity'] =
                      product == null || int.tryParse(text) != product.quantity
                          ? int.tryParse(text)
                          : null,
                  initialValue: product != null ? product.quantity.toString() : "",
                )
              ],
            ),
          ),
        );
    Widget mainContent;
    if (isInEditModel()) {
      if (_product == null && _exception == null) {
        mainContent = CircularProgressIndicator();
      } else if (_exception != null) {
        mainContent = Text("Exception: ${_exception.toString()}");
      } else {
        mainContent = form(_product);
      }
    } else {
      mainContent = form(null);
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(top: 40.0),
          decoration: BoxDecoration(gradient: primaryGradient),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
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
                      submitBtn,
                      deleteBtn,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
