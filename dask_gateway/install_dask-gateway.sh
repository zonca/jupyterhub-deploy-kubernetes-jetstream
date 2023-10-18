RELEASE=dask-gateway
NAMESPACE=jhub

helm upgrade  \
    --install \
    --repo=https://helm.dask.org \
    --version 2023.9.0 \
    --namespace $NAMESPACE \
    --values config_dask-gateway.yaml \
    $RELEASE \
    dask-gateway
