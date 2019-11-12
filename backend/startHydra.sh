#!/usr/bin/bash

SECRETS_SYSTEM=this_needs_to_be_the_same_always_and_also_very_hard
DSN=postgres://hydra:secret@ory-hydra-example--postgres:5432/hydra?sslmode=disable

docker run -d \
  --name ory-hydra-example--hydra \
  --network hydraguide \
  -v /home/stasbar/.secrets/letsencrypt/home.stasbar.com:/home/stasbar/.secrets/letsencrypt/home.stasbar.com \
  -p 9000:4444 \
  -p 9001:4445 \
  -e SECRETS_SYSTEM=$SECRETS_SYSTEM \
  -e DSN=$DSN \
  -e URLS_SELF_ISSUER=https://home.stasbar.com:9000/ \
  -e URLS_CONSENT=https://home.stasbar.com:9020/consent \
  -e URLS_LOGIN=https://home.stasbar.com:9020/login \
  -e SERVE_TLS_KEY_PATH=/home/stasbar/.secrets/letsencrypt/home.stasbar.com/privkey.pem \
  -e SERVE_TLS_CERT_PATH=/home/stasbar/.secrets/letsencrypt/home.stasbar.com/fullchain.pem \
  oryd/hydra:v1.0.8 serve all
