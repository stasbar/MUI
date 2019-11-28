import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:warehouser/dao/productsDao.dart';
import 'package:warehouser/model/Product.dart';
import 'package:warehouser/model/User.dart';
import 'package:warehouser/services/authorization.dart';
import 'package:warehouser/utils/const.dart';
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
    final productsMap = await ProductsDao.getProductsMap();
    print("productsMap: $productsMap ");
    final quantitiesMap = await ProductsDao.getQuantitiesMap();
    final remQuantitiesMap = await ProductsDao.getRemQuantitiesMap();

    List<Product> products = productsMap.values.map((product) {
      final quantity = getOrZero(product['id'], quantitiesMap) +
          getOrZero(product['id'], remQuantitiesMap);
      product['quantity'] = quantity;
      return Product.fromJson(product);
    }).toList();

    print("products $products");
    return products;
  }

  static int getOrZero(String productId, Map<String, dynamic> map) {
    if (map.containsKey(productId)) {
      return map[productId];
    } else {
      return 0;
    }
  }

  static updateProduct(Product product) async {
    final productJson = product.toJson();
    productJson['lastTimeModified'] = new DateTime.now().millisecondsSinceEpoch;
    final localMap = await ProductsDao.getProductsMap();
    localMap[product.id] = productJson;
    ProductsDao.putProductsMap(localMap);
  }

  static createProduct(Product product) async {
    final productJson = product.toJson();
    productJson['lastTimeModified'] = new DateTime.now().millisecondsSinceEpoch;
    productJson['id'] = Uuid().v4();
    productJson['deleted'] = false;
    final localMap = await ProductsDao.getProductsMap();
    localMap[productJson['id']] = productJson;
    ProductsDao.putProductsMap(localMap);
  }

  static deleteProduct(String productId) async {
    final localMap = await ProductsDao.getProductsMap();
    localMap[productId]['deleted'] = true;
    ProductsDao.putProductsMap(localMap);
  }

  static deltaQuantity(Product product, int delta) async {
    // increase lastTimeModified
    await updateProduct(product);
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('quantities')) {
      await prefs.setString('quantities', jsonEncode({}));
    }
    String quantitiesString = prefs.getString('quantities');
    Map<String, dynamic> quantitiesJson = json.decode(quantitiesString);
    if (quantitiesJson.containsKey(product.id)) {
      quantitiesJson[product.id] = quantitiesJson[product.id] + delta;
    } else {
      quantitiesJson[product.id] = delta;
    }
    quantitiesString = jsonEncode(quantitiesJson);

    await prefs.setString('quantities', quantitiesString);
  }

  static synchronize() async {
    final prefs = await SharedPreferences.getInstance();
    final productsString = prefs.getString('products');
    final quantitiesString = prefs.getString('quantities');
    final remQuantitiesString = prefs.getString('remQuantities');

    Map<String, dynamic> products =
        productsString != null ? jsonDecode(productsString) : Map();

    Map<String, dynamic> quantities =
        quantitiesString != null ? jsonDecode(quantitiesString) : Map();

    Map<String, dynamic> remQuantities =
        remQuantitiesString != null ? jsonDecode(remQuantitiesString) : Map();

    products.forEach((id, productMap) {
      products[id]['quantity'] = quantities[id];
    });

    final url = '$baseUrl/sync';
    print(url);
    final response =
        await ioClient.post(url, body: jsonEncode(products), headers: {
      'Authorization': 'bearer ${await AuthorizationService.accessToken()}',
      'X-Device': prefs.getString(INSTALLATION_ID)
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to get all product reason: ${response.body}');
    }

    Map<String, dynamic> remoteProducts = json.decode(response.body);

    await synchronizeProducts(remoteProducts, products, prefs);
    await synchronizeQuantities(
        remoteProducts, remQuantities, quantities, prefs);
  }

  static Future synchronizeProducts(Map<String, dynamic> remoteProducts,
      Map<String, dynamic> products, SharedPreferences prefs) async {
    remoteProducts.forEach((id, productMap) {
      final remoteProduct = Product.fromJson(productMap);
      if (products.containsKey(id)) {
        final localProduct = Product.fromJson(products[id]);
        if (remoteProduct.lastTimeModified >= localProduct.lastTimeModified) {
          products[id] = remoteProduct;
        }
      } else {
        products[id] = remoteProduct;
      }
    });

    await prefs.setString('products', jsonEncode(products));
  }

  static Future synchronizeQuantities(
      Map<String, dynamic> remoteProducts,
      Map<String, dynamic> remQuantities,
      Map<String, dynamic> quantities,
      SharedPreferences prefs) async {
    remoteProducts.forEach((id, productMap) {
      remQuantities[id] = productMap['quantity'] - getOrZero(id, quantities);
    });
    await prefs.setString('remQuantities', jsonEncode(remQuantities));
  }
}
