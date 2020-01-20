import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ProductsDao {
  static Future<Map<String, dynamic>> getProductsMap() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('products')) {
      await prefs.setString('products', jsonEncode({}));
    }
    final productsString = prefs.getString('products');
    return jsonDecode(productsString);
  }

  static setWarehouse(String warehouse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('warehouse', warehouse);
  }

  static Future<String> getWarehouse(String defaultValue) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('warehouse')) {
      return prefs.getString('warehouse');
    } else {
      return defaultValue;
    }
  }

  static putProductsMap(Map<String, dynamic> productsMap) async {
    final prefs = await SharedPreferences.getInstance();
    print("productsMap: $productsMap");
    final mapString = jsonEncode(productsMap);
    print("mapString: $mapString");
    await prefs.setString('products', mapString);
  }

  static Future<Map<String, dynamic>> getQuantitiesMap() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('quantities')) {
      return Map<String, int>();
    }
    final quantitiesString = prefs.getString('quantities');
    print("quantitiesString : $quantitiesString ");
    return jsonDecode(quantitiesString);
  }

  static Future<Map<String, dynamic>> getRemQuantitiesMap() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('remQuantities')) {
      return Map<String, int>();
    }
    final remQuantitiesString = prefs.getString('remQuantities');
    print("remQuantitiesString: $remQuantitiesString ");
    return jsonDecode(remQuantitiesString);
  }
}
