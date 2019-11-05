#!/usr/bin/bash

docker run --rm -it \
  --network hydraguide \
  oryd/hydra \
  clients create \
  --endpoint http://warehouser-hydra:4445 \
  --id warehouser \
  -g authorization_code,refresh_token \
  -r token,code,id_token \
  --token-endpoint-auth-method none \
  --scope openid,offline \
  --callbacks com.stasbar.warehouser:/oauth2redirect
