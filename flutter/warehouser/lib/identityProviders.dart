class IdentityProvider {
  String name;
  String discoveryEndpoint;
  String authEndpoint;
  String tokenEndpoint;
  String clientId;
  String clientSecret;
  String authRedirectUri;
  String scopeString;

  IdentityProvider({this.name, this.discoveryEndpoint, this.authEndpoint,
    this.tokenEndpoint, this.clientId, this.clientSecret,
    this.authRedirectUri, this.scopeString});
}

final googleIdp = IdentityProvider(
  name: "Google",
  discoveryEndpoint: "https://accounts.google.com/.well-known/openid-configuration",
  authEndpoint: "",
  tokenEndpoint: "",
  clientId: "960807507840-ts3874na6r9h6ctrp5mig0fjgnjoc020.apps.googleusercontent.com",
  clientSecret: "",
  authRedirectUri: "com.googleusercontent.apps.960807507840-ts3874na6r9h6ctrp5mig0fjgnjoc020",
  scopeString: "openid profile email",
);

