RELEASE=jhub
NAMESPACE=jhub

helm upgrade --install $RELEASE jupyterhub/jupyterhub \
      --namespace $NAMESPACE  \
      --version 0.11.1 \
      --values config_standard_storage.yaml --values secrets.yaml
