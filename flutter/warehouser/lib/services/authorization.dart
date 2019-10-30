import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/io_client.dart';

class AuthorizationService {
  static String baseUrl = 'https://home.stasbar.com';
  static int publicPort = 9000;
  static int privatePort = 9001;
  static String publicAuthority = 'home.stasbar.com:$publicPort';

  static HttpClient httpClient = new HttpClient()
    ..badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
  static IOClient ioClient = new IOClient(httpClient);

  static FlutterAppAuth appAuth = FlutterAppAuth();

  static Future<String> getHealthStatus() async {
    final res = await ioClient.get(Uri.https(publicAuthority, '/health/ready'));
    if (res.statusCode == 200) {
      return json.decode(res.body).status;
    } else {
      throw Exception(
          'received status code from server: ${res.statusCode} body: ${res.body}');
    }
  }

  static Future<AuthorizationTokenResponse> authenticateAndToken() async {
    return await appAuth.authorizeAndExchangeCode(AuthorizationTokenRequest(
      "warehouser",
      "com.stasbar.warehouser:/oauth2redirect",
      issuer: Uri.https(publicAuthority, '/').toString(),
      scopes: ['openid', 'offline', 'photos.read'],
    ));
  }

  static Future<AuthorizationTokenResponse> authenticateGoogle() {
    final googleClientId =
        "960807507840-ts3874na6r9h6ctrp5mig0fjgnjoc020.apps.googleusercontent.com";
    return appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        googleClientId,
        'com.stasbar.warehouser:/oauth2redirect',
        issuer: 'https://accounts.google.com',
        scopes: ["openid", "email", "profile"],
      ),
    );
  }

  static Future<FacebookLoginResult> authenticateFacebook() {
    return FacebookLogin().logIn(['email']);
  }
}
