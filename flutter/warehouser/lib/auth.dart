import 'dart:convert';
import 'dart:io';

import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/io_client.dart';

const googleClientId =
    "960807507840-ts3874na6r9h6ctrp5mig0fjgnjoc020.apps.googleusercontent.com";
const googleUri = "https://accounts.google.com/o/oauth2/v2/auth";

FlutterAppAuth appAuth = FlutterAppAuth();

Future<AuthorizationTokenResponse> authenticateGoogle() {
  return appAuth.authorizeAndExchangeCode(
    AuthorizationTokenRequest(
      googleClientId,
      'com.stasbar.warehouser:/oauth2redirect',
      issuer: 'https://accounts.google.com',
      scopes: ["openid", "email", "profile"],
    ),
  );
}

Future<FacebookLoginResult> authenticateFacebook() {
  return FacebookLogin().logIn(['email']);
}

Future<AuthorizationResponse> authenticateUsernamePassword() async {
  print("before auth");
  const myHost = "https://10.0.2.2:9000";
  return await appAuth.authorize(AuthorizationRequest(
    "warehouser",
    "com.stasbar.warehouser:/oauth2redirect",
    serviceConfiguration: AuthorizationServiceConfiguration(
      "$myHost/oauth2/auth",
      "$myHost/oauth2/token",
    ),
    scopes: ['openid', 'offline', 'photos.read'],
  ));
}

Future<AuthorizationTokenResponse> authenticateAndToken() async {
  print("before auth");
  const myHost = "https://10.0.2.2:9000";
  return await appAuth.authorizeAndExchangeCode(AuthorizationTokenRequest(
    "warehouser",
    "com.stasbar.warehouser:/oauth2redirect",
    serviceConfiguration: AuthorizationServiceConfiguration(
      "$myHost/oauth2/auth",
      "$myHost/oauth2/token",
    ),
    scopes: ['openid', 'offline', 'photos.read'],
  ));
}

Future<String> sendGoogleCode(String code) async {
  HttpClient httpClient = new HttpClient()
    ..badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
  IOClient ioClient = new IOClient(httpClient);
  final url = 'https://home.stasbar.com:1234/auth/google';
  final response = await ioClient.post(url, body: jsonEncode({code: code}));

  if (response.statusCode == 200) {
    print(response.body);
    final postsJson = json.decode(response.body);
    return postsJson;
  } else {
    throw Exception('Filed to load product');
  }
}
