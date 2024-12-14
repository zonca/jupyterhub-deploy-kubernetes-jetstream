#!/bin/bash

echo "
hub:
  cookieSecret: \"$(openssl rand -hex 32)\"

proxy:
  secretToken: \"$(openssl rand -hex 32)\"

# only needed with kubespray
#ingress:
#  enabled: true
#  hosts:
#    - $(hostname)
" > secrets.yaml
