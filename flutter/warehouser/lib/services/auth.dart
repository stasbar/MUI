import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';

Future<String> exchangeAccessTokenForGoogleTokenId(String tokenId) async {
  HttpClient httpClient = new HttpClient()
    ..badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
  IOClient ioClient = new IOClient(httpClient);
  final url = 'https://home.stasbar.com:1234/auth/google/';
  final response = await ioClient.post(url,body: {tokenId: tokenId});

  if (response.statusCode == 200) {
    final responseJson = json.decode(response.body);
    return responseJson;
  } else {
    throw Exception('Filed to load product');
  }
}
