RELEASE=jhub
NAMESPACE=jhub

helm upgrade --install $RELEASE jupyterhub/jupyterhub \
      --namespace $NAMESPACE  \
      --version 0.9.0 \
      --values config_standard_storage.yaml --values cdms_secrets.yaml \
      --values dask_gateway/config_jupyterhub.yaml
