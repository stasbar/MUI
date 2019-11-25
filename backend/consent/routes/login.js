const fetch = require('node-fetch');
const express = require('express');
const router = express.Router();
const url = require('url');
const moment = require('moment');
const hydra = require('../services/hydra')
const { URLSearchParams } = require('url');

// Sets up csrf protection
const csrf = require('csurf');
const csrfProtection = csrf({ cookie: true });

router.get('/', csrfProtection, async function (req, res, next) {
  const query = url.parse(req.url, true).query;
  const challenge = query.login_challenge;

  try{
    const response = await hydra.getLoginRequest(challenge)
    const requestUrl = new URL(response.request_url);
    const googleIdToken = requestUrl.searchParams.get('google_id_token');
    const facebookAccessToken = requestUrl.searchParams.get('facebook_access_token');
    if (response.skip) {
      return hydra.acceptLoginRequest(challenge, {
        subject: response.subject
      }).then(function (response) {
        res.redirect(response.redirect_to);
      });
    } else if (googleIdToken) {
      await authenticateWithGoogle(res, next, challenge, googleIdToken);
    } else if (facebookAccessToken ) {
      await authenticateWithFacebook(res, next, challenge, facebookAccessToken );
    }else{
      renderLoginPage(req, res, challenge)
    }
  }catch (error) {
    next(error);
  }
});

function renderLoginPage(req, res, challenge){
  res.render('login', {
    csrfToken: req.csrfToken(),
    challenge: challenge,
  });
}

router.post('/', csrfProtection, function (req, res, next) {
  // The challenge is now a hidden input field, so let's take it from the request body instead
  const challenge = req.body.challenge;

  const { email, password } = req.body;

  const isValidEmployee = email === "employee@warehouser.com" && password === "password";
  const isValidManager = email === "manager@warehouser.com" && password === "password";
  // Let's check if the user provided valid credentials. Of course, you'd use a database or some third-party service
  // for this!
  if (!isValidEmployee && !isValidManager) {
    console.error(`failed to login: ${email} and ${password}`);
    // Looks like the user provided invalid credentials, let's show the ui again...

    res.render('login', {
      csrfToken: req.csrfToken(),

      challenge: challenge,

      error: 'The username / password combination is not correct'
    });
    return;
  }

  // Seems like the user authenticated! Let's tell hydra...
  hydra.acceptLoginRequest(challenge, {
    // Subject is an alias for user ID. A subject can be a random string, a UUID, an email address, ....
    subject: email,

    // This tells hydra to remember the browser and automatically authenticate the user in future requests. This will
    // set the "skip" parameter in the other route to true on subsequent requests!
    remember: Boolean(req.body.remember),
    remember_for: 60 * 60 * 24 * 90, // 90 days

    // Sets which "level" (e.g. 2-factor authentication) of authentication the user has. The value is really arbitrary
    // and optional. In the context of OpenID Connect, a value of 0 indicates the lowest authorization level.
    // acr: '0',
  })
    .then(function (response) {
      // All we need to do now is to redirect the user back to hydra!
      res.redirect(response.redirect_to);
    })
    // This will handle any error that happens when making HTTP calls to hydra
    .catch(function (error) {
      next(error);
    });
});

async function authenticateWithGoogle(res, next, challenge, googleIdToken) {
  try{
    const tokenInfoUrl = new URL("https://oauth2.googleapis.com/tokeninfo");
    tokenInfoUrl.searchParams.append('id_token', googleIdToken);
    const tokenInfoRes = await fetch(tokenInfoUrl);
    const token = await tokenInfoRes.json();
    validateGoogleToken(token);
    const response = await hydra.acceptLoginRequest(challenge, {
      subject: token.email,
      remember_for: 60 * 60 * 24 * 90,
    })
    res.redirect(response.redirect_to);
  } catch (error) {
    next(error);
  } 
}

async function authenticateWithFacebook(res, next, challenge, facebookIdToken) {
  try{
    const accessTokenUrl = new URL("https://graph.facebook.com/oauth/access_token");
    accessTokenUrl.searchParams.append('client_id', process.env.FACEBOOK_CLIENT_ID);
    accessTokenUrl.searchParams.append('client_secret', process.env.FACEBOOK_CLIENT_SECRET
    );
    accessTokenUrl.searchParams.append('grant_type', "client_credentials");

    const accessTokenRes = await fetch(accessTokenUrl);
    const accessToken = await accessTokenRes.json();
    const fbAppAccessToken = accessToken.access_token;

    const debugTokenUrl = new URL("https://graph.facebook.com/v5.0/debug_token");
    debugTokenUrl.searchParams.append('input_token', facebookIdToken);
    console.dir(facebookIdToken)
    debugTokenUrl.searchParams.append('access_token', fbAppAccessToken);
    console.dir(fbAppAccessToken)
    const debugTokenRes = await fetch(debugTokenUrl);
    const token = await debugTokenRes.json();
    validateFacebookToken(token)

    const userId = token.data.user_id;
    const userUrl = new URL(`https://graph.facebook.com/v5.0/${userId}`);
    userUrl.searchParams.append('fields', 'email');
    userUrl.searchParams.append('access_token', facebookIdToken);
    console.dir(userUrl);
    const userRes = await fetch(userUrl);
    const user = await userRes.json();
    console.log(user);
    const response = await hydra.acceptLoginRequest(challenge, {
      subject: user.email,
      remember_for: 60 * 60 * 24 * 90,
    })
    res.redirect(response.redirect_to);
  }catch (error){
    next(error);
  }
}

function validateFacebookToken(token){
  console.dir(token);
  return token;
}

function validateGoogleToken(token){
  console.dir(token);
  const iss = token.iss;
  if(!iss){
    throw new Error("could not find iss field in id_token");
  }
  if (iss !== "https://accounts.google.com" && iss !== "accounts.google.com") {
    throw new Error("Invalid iss %s\n", iss);
  }

  const exp = token.exp
  if (!exp) {
    throw new Error("could not find exp field in id_token")
  }
  if (Number(exp) < moment().unix()) {
    throw new Error("token expired")
  }
  return token;
}

module.exports = router;
