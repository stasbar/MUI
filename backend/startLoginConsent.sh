#!/usr/bin/bash

SECRETS_SYSTEM=this_needs_to_be_the_same_always_and_also_very_hard
DSN=postgres://hydra:secret@ory-hydra-example--postgres:5432/hydra?sslmode=disable

docker run -d \
  --name warehouser-consent \
  -v /home/stasbar/.secrets/letsencrypt/home.stasbar.com:/home/stasbar/.secrets/letsencrypt/home.stasbar.com \
  -p 9020:3000 \
  --network hydraguide \
  -e HYDRA_ADMIN_URL=http://ory-hydra-example--hydra:4445 \
  -e NODE_TLS_REJECT_UNAUTHORIZED=0 \
  warehouser-consent
