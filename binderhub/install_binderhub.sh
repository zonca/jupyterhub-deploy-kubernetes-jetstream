# config_vars.sh defines 2 variables:
# export ALLOCATION=xxx1234567
# export GOOGLE_PROJECT=binderhub-000000
source config_vars.sh
sed -e "s/ALLOCATION/$ALLOCATION/g" -e "s/GOOGLE_PROJECT/$GOOGLE_PROJECT/g" config_template.yaml > config.yaml
helm upgrade --install binderhub jupyterhub/binderhub --version=1.0.0-0.dev.git.2816.h5db2f98 --namespace=jhub -f secret.yaml -f config.yaml
