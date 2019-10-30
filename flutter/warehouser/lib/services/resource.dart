import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:warehouser/model/Product.dart';

class ResourceService {
  static int port = 1234;
  static String baseUrl = 'https://home.stasbar.com:$port';

  static HttpClient httpClient = new HttpClient()
    ..badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);

  static IOClient ioClient = new IOClient(httpClient);


  Future<List<Product>> fetchProducts() async {
    final url = '$baseUrl/products';
    final response = await ioClient.get(url);

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

  Future<String> exchangeTokenIdForAccessToken(String tokenId) async {
    final url = '$baseUrl/auth/google';
    final response = await ioClient.post(url, body: {'tokenId': tokenId});

    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      return responseJson;
    } else {
      throw Exception('Failed to exchange id for access token');
    }
  }
}
