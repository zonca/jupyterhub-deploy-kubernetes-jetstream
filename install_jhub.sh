RELEASE=jhub
NAMESPACE=jhub

helm upgrade --install $RELEASE jupyterhub/jupyterhub \
      --namespace $NAMESPACE  \
      --create-namespace \
      --version 4.3.1 \
      --debug \
      --values config_standard_storage.yaml --values secrets.yaml
