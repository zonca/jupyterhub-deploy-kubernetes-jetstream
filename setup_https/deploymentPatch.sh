# Patch deployments to make cert-manager pods spawn in master node
# See https://github.com/zonca/jupyterhub-deploy-kubernetes-jetstream/issues/52

DEPLOYMENTS=( "cert-manager" "cert-manager-cainjector" "cert-manager-webhook" )

for DEPLOYMENT in ${DEPLOYMENTS[@]}
do
        kubectl patch deployment -n cert-manager $DEPLOYMENT --patch-file ./deploymentPatch.yml
done
