import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/io_client.dart';
import 'package:warehouser/services/resource.dart';

enum Provider { WAREHOUSER, GOOGLE, FACEBOOK }

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

  static Future<AuthorizationTokenResponse> authenticateWarehouser() async {
    print(Uri.https(publicAuthority, '/').toString());
    // why this way ? https://www.ory.sh/oauth2-for-mobile-app-spa-browser/
    return await appAuth.authorizeAndExchangeCode(AuthorizationTokenRequest(
      "warehouser",
      "com.stasbar.warehouser:/oauth2redirect",
      issuer: Uri.https(publicAuthority, '/').toString(),
      scopes: ['openid', 'offline'],
    ));
  }

  static Future<AuthorizationTokenResponse> authenticateGoogle() async {
    final googleClientId =
        "960807507840-ts3874na6r9h6ctrp5mig0fjgnjoc020.apps.googleusercontent.com";
    final authToken = await appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        googleClientId,
        'com.stasbar.warehouser:/oauth2redirect',
        issuer: 'https://accounts.google.com',
        scopes: ["openid", "email", "profile"],
      ),
    );

    // why this way ? https://www.ory.sh/oauth2-for-mobile-app-spa-browser/
    // TODO set explicitly oauth/login serach arguments to contain
    // google_id_token
    print(Uri.https(publicAuthority, '/').toString());
    return await appAuth.authorizeAndExchangeCode(AuthorizationTokenRequest(
      "warehouser",
      "com.stasbar.warehouser:/oauth2redirect",
      additionalParameters: {
        "google_id_token": authToken.idToken,
      },
      issuer: Uri.https(publicAuthority, '/').toString(),
      scopes: ['openid', 'offline'],
    ));
  }

  static Future<AuthorizationTokenResponse> authenticateFacebook() async {
    final result = await FacebookLogin().logIn(['email']);
    if (result.status == FacebookLoginStatus.cancelledByUser)
      throw new Exception("Cancel by user");

    if (result.status == FacebookLoginStatus.error)
      throw new Exception(result.errorMessage);

    // why this way ? https://www.ory.sh/oauth2-for-mobile-app-spa-browser/
    print(Uri.https(publicAuthority, '/').toString());
    return appAuth.authorizeAndExchangeCode(AuthorizationTokenRequest(
      "warehouser",
      "com.stasbar.warehouser:/oauth2redirect",
      additionalParameters: {
        "facebook_access_token": result.accessToken.token,
      },
      issuer: Uri.https(publicAuthority, '/').toString(),
      scopes: ['openid', 'offline'],
    ));
  }

  static authenticate(Provider provider) async {
    switch (provider) {
      case Provider.FACEBOOK:
        var result = await authenticateFacebook();
        ResourceService.accessToken = result.accessToken;
        ResourceService.refreshToken = result.refreshToken;
        break;
        break;
      case Provider.GOOGLE:
        var result = await authenticateGoogle();
        ResourceService.accessToken = result.accessToken;
        ResourceService.refreshToken = result.refreshToken;
        break;
        break;
      case Provider.WAREHOUSER:
        var result = await authenticateWarehouser();
        ResourceService.accessToken = result.accessToken;
        ResourceService.refreshToken = result.refreshToken;
        break;
    }
  }

  static logout() async {
    final res = await ioClient.post(
        Uri.https(publicAuthority, '/oauth2/revoke'),
        body: {'token': ResourceService.refreshToken});
    if (res.statusCode == 200) {
      return json.decode(res.body).status;
    } else {
      throw Exception(
          'received status code from server: ${res.statusCode} body: ${res.body}');
    }
  }
}
