RELEASE=jhub
NAMESPACE=jhub

helm upgrade --install $RELEASE jupyterhub/jupyterhub \
      --namespace $NAMESPACE  \
      --version 0.8.2 \
      --values config_standard_storage.yaml --values secrets.yaml
