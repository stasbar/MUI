import 'package:flutter/material.dart';
import 'package:warehouser/_routing/routes.dart';
import 'package:warehouser/views/editProduct.dart';
import 'package:warehouser/views/home.dart';
import 'package:warehouser/views/login.dart';
import 'package:warehouser/views/products.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case loginViewRoute:
      return MaterialPageRoute(builder: (context) => LoginPage());
    case homeViewRoute:
      return MaterialPageRoute(builder: (context) => HomePage());
    case productsViewRoute:
      return MaterialPageRoute(builder: (context) => ProductsPage());
    case createProductViewPage:
      return MaterialPageRoute(builder: (context) => EditProductPage());
    case editProductViewPage:
      return MaterialPageRoute(
          builder: (context) => EditProductPage(productId: settings.arguments));
      break;
    default:
      return MaterialPageRoute(builder: (context) => LoginPage());
  }
}
