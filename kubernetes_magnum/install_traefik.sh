helm repo add traefik https://traefik.github.io/charts
helm repo update

helm upgrade --install traefik traefik/traefik \
        --namespace ingress-traefik --create-namespace \
        --set 'api.dashboard=false' \
        --set 'providers.kubernetesCRD.enabled=false' \
        --set 'logs.access.enabled=true' \
        --set 'nodeSelector.capi\.stackhpc\.com/node-group=default-worker'
