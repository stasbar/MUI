import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

const googleClientId =
    "960807507840-ts3874na6r9h6ctrp5mig0fjgnjoc020.apps.googleusercontent.com";
const googleUri = "https://accounts.google.com/o/oauth2/v2/auth";

FlutterAppAuth appAuth = FlutterAppAuth();

Future<AuthorizationTokenResponse> authenticateGoogle() async {
  // create the client
  return appAuth.authorizeAndExchangeCode(
    AuthorizationTokenRequest(
      googleClientId,
      'com.stasbar.warehouser:/oauth2redirect',
      issuer: 'https://accounts.google.com',
      scopes: ["openid", "email", "profile"],
    ),
  );
}

Future<FacebookLoginResult> authenticateFacebook() async {
  final facebookLogin = FacebookLogin();
  return facebookLogin.logIn(['email']);
}
