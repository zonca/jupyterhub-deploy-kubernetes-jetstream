RELEASE=nginx
NAMESPACE=default

helm upgrade --install $RELEASE stable/nginx-ingress \
      --namespace $NAMESPACE  \
      --values nginx_ingress.yaml
