#!/usr/bin/bash

docker run --rm -it \
  --network backend_default \
  oryd/hydra clients create \
  --skip-tls-verify \
  --endpoint "https://warehouser-hydra:4445" \
  --id "warehouser" \
  -g "authorization_code,refresh_token" \
  -r "token,code,id_token" \
  --token-endpoint-auth-method "none" \
  --scope "openid,offline" \
  --callbacks "com.stasbar.warehouser:/oauth2redirect"
