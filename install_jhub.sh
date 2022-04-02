RELEASE=jhub
NAMESPACE=jhub

helm upgrade --install $RELEASE jupyterhub/jupyterhub \
      --namespace $NAMESPACE  \
      --version 1.2.0 \
      --values config_standard_storage.yaml --values secrets.yaml
