#!/usr/bin/bash

curl -X GET https://home.stasbar.com:9000/userinfo \
  -H 'Accept: application/json' \
  -H "Authorization: Bearer $1"
