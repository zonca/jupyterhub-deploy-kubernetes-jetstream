#!/bin/bash

echo "
hub:
  cookieSecret: \"$(openssl rand -hex 32)\"

proxy:
  secretToken: \"$(openssl rand -hex 32)\"

ingress:
  hosts:
    - $(hostname)
  tls:
   - hosts:
      - $(hostname)
     secretName: kubelego-tls-jupyterhub
" > secrets.yaml
