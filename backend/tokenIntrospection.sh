
#!/usr/bin/bash

curl -X POST https://home.stasbar.com:9001/oauth2/introspect \
  -H 'Accept: application/json' \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "token=$1"
