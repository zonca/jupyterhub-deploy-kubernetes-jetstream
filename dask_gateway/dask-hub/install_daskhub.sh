RELEASE=daskhub
NAMESPACE=jhub
VERSION=2021.12.0

helm upgrade --install \
    --namespace $NAMESPACE \
    --version $VERSION \
    --values config_daskhub.yaml \
    $RELEASE \
    dask/daskhub
