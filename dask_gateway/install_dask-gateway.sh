RELEASE=dask-gateway
NAMESPACE=jhub

helm install  \
    --namespace $NAMESPACE \
    --values config_dask-gateway.yaml \
    $RELEASE \
    dask-gateway/resources/helm/dask-gateway/
