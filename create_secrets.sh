#!/bin/bash

echo "
hub:
  cookieSecret: \"$(openssl rand -hex 32)\"

proxy:
  secretToken: \"$(openssl rand -hex 32)\"

ingress:
  enabled: true
  ingressClassName: traefik
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt"
  hosts:
        - k8s.$PROJ.projects.jetstream-cloud.org
  tls:
        - hosts:
           - k8s.$PROJ.projects.jetstream-cloud.org 
          secretName: certmanager-tls-jupyterhub
" > secrets.yaml
