import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:warehouser/model/Product.dart';
import 'package:warehouser/model/User.dart';

class ResourceService {
  static int port = 1234;
  static String baseUrl = 'https://home.stasbar.com:$port';

  static String accessToken;
  static String refreshToken;

  static HttpClient httpClient = new HttpClient()
    ..badCertificateCallback =
    ((X509Certificate cert, String host, int port) => true);

  static IOClient ioClient = new IOClient(httpClient);


  static Future<List<Product>> fetchProducts() async {
    final url = '$baseUrl/products';
    final response = await ioClient.get(url, headers: {'Authorization': 'bearer $accessToken'});

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

  static Future<String> exchangeGoogle(String tokenId) async {
    return _exchange('google', tokenId);
  }

  static Future<String> exchangeFacebook(String tokenId) async {
    return _exchange('facebook', tokenId);
  }

  static Future<String> _exchange(String provider, String tokenId) async {
    final url = '$baseUrl/auth/$provider';
    final response = await ioClient.post(url, body: {'tokenId': tokenId});

    if (response.statusCode == 200) {
      return json.decode(response.body).accessToken;
    } else {
      throw Exception('Failed to exchange id for access token');
    }
  }

  static Future<User>currentUser() async {
    final url = '$baseUrl/currentUser';
    final response = await ioClient.get(url, headers: {'Authorization': 'bearer $accessToken'});
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to exchange id for access token');
    }
  }
}
