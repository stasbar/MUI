import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warehouser/model/Product.dart';
import 'package:warehouser/model/User.dart';

class ResourceService {
  static int port = 1234;
  static String baseUrl = 'https://home.stasbar.com:$port';

  static Future<String> accessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("accessToken");
  }

  static Future<String> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("refreshToken");
  }

  static HttpClient httpClient = new HttpClient()
    ..badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);

  static IOClient ioClient = new IOClient(httpClient);

  static Future<User> currentUser() async {
    final url = '$baseUrl/currentUser';
    print(url);
    final response = await ioClient
        .get(url, headers: {'Authorization': 'bearer ${await accessToken()}'});
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to get current user, response: ${response.statusCode}');
    }
  }

  static Future<List<Product>> fetchProducts() async {
    final url = '$baseUrl/products';
    print(url);
    final response = await ioClient
        .get(url, headers: {'Authorization': 'bearer ${await accessToken()}'});

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

  static Future<Product> getProduct(String productId) async {
    final url = '$baseUrl/products/$productId';
    print(url);
    final response = await ioClient
        .get(url, headers: {'Authorization': 'bearer ${await accessToken()}'});
    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to get product, response: ${response.statusCode}');
    }
  }

  static updateProduct(String productId, Map<String, dynamic> update) async {
    final url = '$baseUrl/products/$productId';
    print(url);
    final response = await ioClient.put(url,
        body: json.encode(update),
        headers: {'Authorization': 'bearer ${await accessToken()}'});
    if (response.statusCode == 200) {
      print(response.body);
    } else {
      throw Exception(
          'Failed to get product, response: ${response.statusCode}');
    }
  }

  static deleteProduct(String productId) async {
    final url = '$baseUrl/products/$productId';
    print(url);
    final response = await ioClient
        .delete(url, headers: {'Authorization': 'bearer ${await accessToken()}'});
    if (response.statusCode == 200) {
      print(response.body);
    } else {
      throw Exception(
          'Failed to get product, response: ${response.statusCode}');
    }
  }

  static createProduct(Product product) async {
    final url = '$baseUrl/products';
    print(url);

    final response = await ioClient.post(url,
        body: jsonEncode(product),
        headers: {'Authorization': 'bearer ${await accessToken()}'});
    if (response.statusCode == 201) {
      print(response.body);
    } else {
      throw Exception(
          'Failed to get product, response: ${response.statusCode}');
    }
  }
}
