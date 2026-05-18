#!/bin/bash

echo "
hub:
  cookieSecret: \"$(openssl rand -hex 32)\"

proxy:
  secretToken: \"$(openssl rand -hex 32)\"

ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: \"traefik\"
    cert-manager.io/cluster-issuer: \"letsencrypt\"
    traefik.ingress.kubernetes.io/middlewares.limit.buffering.maxRequestBodyBytes: \"500000000\"
  hosts:
        - $SUBDOMAIN.$PROJ.projects.jetstream-cloud.org
  tls:
        - hosts:
           - $SUBDOMAIN.$PROJ.projects.jetstream-cloud.org
          secretName: certmanager-tls-jupyterhub
" > secrets.yaml
