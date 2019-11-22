import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warehouser/model/Product.dart';
import 'package:warehouser/model/User.dart';
import 'package:device_id/device_id.dart';
import 'package:warehouser/services/authorization.dart';
import 'package:warehouser/utils/utils.dart';

class ResourceService {
  static int port = 1234;
  static String baseUrl = 'https://home.stasbar.com:$port';

  static HttpClient httpClient = new HttpClient()
    ..badCertificateCallback =
    ((X509Certificate cert, String host, int port) => true);

  static IOClient ioClient = new IOClient(httpClient);

  static Future<User> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await fetchCurrentUser();
    } catch (e) {
      if (prefs.containsKey('currentUser')) {
        toast(
            "Failed to fetch currentUser from server, falling back to local cache");
      } else {
        throw e;
      }
    }
    final currentUserString = prefs.getString('currentUser');
    return User.fromJson(json.decode(currentUserString));
  }

  static fetchCurrentUser() async {
    final url = '$baseUrl/currentUser';
    print(url);
    final response = await ioClient.get(url, headers: {
      'Authorization': 'bearer ${await AuthorizationService.accessToken()}'
    });
    if (response.statusCode == 200) {
      final user = User.fromJson(json.decode(response.body));
      persistCurrentUser(user);
    } else {
      throw Exception('Failed to get current user, reason: ${response.body}');
    }
  }

  static persistCurrentUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUser', jsonEncode(user));
  }

  static Future<List<Product>> getAllProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsString = prefs.getString('products');
    Map<String, dynamic> productsJson = json.decode(productsString);
    List<Product> products = productsJson.map((id, product) =>
        MapEntry(id, Product.fromJson(product))).values;
    return products;
  }

  static synchronize() async {
    final prefs = await SharedPreferences.getInstance();
    final productsString = prefs.getString('products');
    final quantitiesString = prefs.getString('quantities');
    final remQuantitiesString = prefs.getString('remQuantities');
    Map<String, dynamic> products = json.decode(productsString);
    Map<String, dynamic> quantities = json.decode(quantitiesString);
    Map<String, dynamic> remQuantities = json.decode(remQuantitiesString);

    products.forEach((id, productMap) {
      products[id]['quantity'] = quantities[id];
    });

    final url = '$baseUrl/sync';
    print(url);
    final response = await ioClient.post(url, body: productsString, headers: {
      'Authorization': 'bearer ${await AuthorizationService.accessToken()}'
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to get all product reason: ${response.body}');
    }

    Map<String, dynamic> resProducts = json.decode(response.body);
    resProducts.forEach((id, productMap) {
      // update server state
      remQuantities[id] = productMap['quantity'] - quantities[id];
    });

    _persistAllProducts(resProducts);
  }

  static _persistAllProducts(Map<String, dynamic> productsJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('products', jsonEncode(productsJson));
  }

  //TODO refactor
  static _persistProduct(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('products')) {
      await prefs.setString('products', jsonEncode({}));
    }
    String localProducts = prefs.getString('products');
    Map<String, dynamic> localMap = jsonDecode(localProducts);
    localMap[product.id] = product;

    await prefs.setString('products', jsonEncode(localMap));
  }

  //TODO refactor
  static updateProduct(String productId, Map<String, dynamic> update) async {
    final url = '$baseUrl/products/$productId';
    print(url);
    final response = await ioClient.put(url,
        body: json.encode(update),
        headers: {
          'Authorization': 'bearer ${await AuthorizationService.accessToken()}'
        });
    if (response.statusCode == 200) {
      print(response.body);
    } else {
      throw Exception('Failed to update product reason: ${response.body}');
    }
  }

  //TODO refactor
  static deleteProduct(String productId) async {
    final url = '$baseUrl/products/$productId';
    print(url);
    final response = await ioClient.delete(url, headers: {
      'Authorization': 'bearer ${await AuthorizationService.accessToken()}'
    });
    if (response.statusCode == 200) {
      print(response.body);
    } else {
      throw Exception('Failed to delete product reason: ${response.body}');
    }
  }

  static createProduct(Product product) async {}

  static pushProduct(Product product) async {
    final url = '$baseUrl/products';
    print(url);

    final response = await ioClient.post(url,
        body: jsonEncode(product),
        headers: {
          'Authorization': 'bearer ${await AuthorizationService.accessToken()}'
        });
    if (response.statusCode == 201) {
      print(response.body);
    } else {
      throw Exception('Failed to create product reason: ${response.body}');
    }
  }

  static deltaQuantity(String productId, int delta) async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('quantities')) {
      await prefs.setString('quantities', jsonEncode({}));
    }
    String quantitiesString = prefs.getString('quantities');
    Map<String, dynamic> quantitiesJson = json.decode(quantitiesString);
    if (quantitiesJson.containsKey(productId)) {
      quantitiesJson[productId] = quantitiesJson[productId] + delta;
    } else {
      quantitiesJson[productId] = delta;
    }
    quantitiesString = jsonEncode(quantitiesJson);

    await prefs.setString('quantities', quantitiesString);

    await sync();
  }

  static sync() async {
    final url = '$baseUrl/sync';
    print(url);

    final deviceId = await DeviceId.getID;
    final email = AuthorizationService.currentUser.email;
    final prefs = await SharedPreferences.getInstance();

    final response =
    await ioClient.post(url, body: prefs.getString(email), headers: {
      'Authorization': 'bearer ${await AuthorizationService.accessToken()}',
      'DeviceId': deviceId
    });
    if (response.statusCode == 200) {
      print(response.body);
    } else {
      throw Exception('Failed to create product reason: ${response.body}');
    }
  }
}
