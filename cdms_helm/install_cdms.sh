RELEASE=cdms
NAMESPACE=cdms

helm upgrade --install $RELEASE cdms/cdms \
    --version "v0.1.1-86665a6" \
    --namespace $NAMESPACE \
    --values config_jupyterhub_cdms_helm.yaml
