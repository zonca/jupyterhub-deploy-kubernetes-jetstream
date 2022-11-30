RELEASE=jhub
NAMESPACE=jhub

helm upgrade --install $RELEASE jupyterhub/jupyterhub \
      --namespace $NAMESPACE  \
      --create-namespace \
      --version 1.2.0 \
      --debug \
      --values config_standard_storage.yaml --values secrets.yaml
