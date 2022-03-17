RELEASE=jhub
NAMESPACE=jhub

helm upgrade --install $RELEASE jupyterhub/jupyterhub \
      --namespace $NAMESPACE  \
      --values config_standard_storage.yaml --values cdms_secrets.yaml \
      --version 1.2.0 \
