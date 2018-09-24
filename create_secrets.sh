#!/bin/bash

echo "
hub:
  cookieSecret: \"$(openssl rand -hex 32)\"

proxy:
  secretToken: \"$(openssl rand -hex 32)\"

ingress:
  enabled: true
  hosts:
    - $(hostname)
" > secrets.yaml
