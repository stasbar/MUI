#!/usr/bin/bash

SECRETS_SYSTEM=this_needs_to_be_the_same_always_and_also_very_hard
DSN=postgres://hydra:secret@ory-hydra-example--postgres:5432/hydra?sslmode=disable

docker run -d \
  --name ory-hydra-example--postgres \
  --network hydraguide \
  -e POSTGRES_USER=hydra \
  -e POSTGRES_PASSWORD=secret \
  -e POSTGRES_DB=hydra \
  postgres:9.6
