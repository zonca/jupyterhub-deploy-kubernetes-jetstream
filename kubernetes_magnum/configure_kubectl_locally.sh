openstack coe cluster config $K8S_CLUSTER_NAME --force
export KUBECONFIG=$(pwd)/config
chmod 600 config
