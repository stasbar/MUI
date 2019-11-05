#!/usr/bin/bash

SECRETS_SYSTEM=$(grep SECRETS_SYSTEM .env | cut -d '=' -f 2-)
POSTGRES_USER=$(grep POSTGRES_USER .env | cut -d '=' -f 2-)
POSTGRES_PASSWORD=$(grep POSTGRES_PASSWORD .env | cut -d '=' -f 2-)
POSTGRES_DB=$(grep POSTGRES_DB .env | cut -d '=' -f 2-)

DSN=postgres://$POSTGRES_USER:$POSTGRES_PASSWORD@warehouser-db:5432/$POSTGRES_DB?sslmode=disable

docker-compose run --rm \
  hydra migrate sql --yes $DSN

# docker run -it --rm \
#   --network backend_default \
#   oryd/hydra \
#   migrate sql --yes $DSN
