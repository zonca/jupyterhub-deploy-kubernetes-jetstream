source my_aws_config
kubectl -n jhub create secret generic awsconfig \
      --from-literal=AWS_ACCESS_KEY_ID=$aws_access_key_id \
      --from-literal=AWS_SECRET_ACCESS_KEY=$aws_secret_access_key \
      --from-literal=AWS_DEFAULT_REGION=$region \
      --from-literal=JUPYTERHUB_API_TOKEN=$jhub_token
