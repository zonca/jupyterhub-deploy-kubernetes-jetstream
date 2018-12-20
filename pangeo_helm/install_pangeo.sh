RELEASE=pangeo
NAMESPACE=pangeo

helm upgrade --install $RELEASE pangeo/pangeo \
    --version "v0.1.1-86665a6" \
    --namespace $NAMESPACE \
    --values config_jupyterhub_pangeo_helm.yaml
