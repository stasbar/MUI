import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

const googleClientId =
    "960807507840-ts3874na6r9h6ctrp5mig0fjgnjoc020.apps.googleusercontent.com";
const googleUri = "https://accounts.google.com/o/oauth2/v2/auth";

FlutterAppAuth appAuth = FlutterAppAuth();

Future<TokenResponse> authenticateGoogle() {
  return appAuth.token(
    TokenRequest(
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
