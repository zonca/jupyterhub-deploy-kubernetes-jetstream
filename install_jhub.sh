RELEASE=jhub
NAMESPACE=jhub

helm upgrade --install $RELEASE jupyterhub/jupyterhub \
      --namespace $NAMESPACE  \
      --create-namespace \
      --version 4.3.1 \
      --debug \
      --values config_standard_storage.yaml \
      --values dask_operator/jupyterhub_config.yaml \
      --values dask_operator/jupyterhub_dask_dashboard_config.yaml \
      --values secrets.yaml
#      --values gpu/jupyterhub_gpu.yaml \
