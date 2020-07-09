FLAVOR="m1.medium"
MASTER_FLAVOR=$FLAVOR
DOCKER_VOLUME_SIZE_GB=10

openstack coe cluster template create --coe kubernetes \
    --image "Fedora-Atomic-29-JS-Latest" \
    --keypair comet \
    --external-network public --fixed-network ${OS_USERNAME}-newk8s-network --fixed-subnet ${OS_USERNAME}-newk8s-subnet1 --network-driver flannel \
    --flavor $FLAVOR --master-flavor $MASTER_FLAVOR \
    --docker-volume-size $DOCKER_VOLUME_SIZE_GB --docker-storage-driver devicemapper \
    --floating-ip-enabled \
    --server-type vm \
    --labels cloud-provider-enabled=true \
    --volume-driver cinder \
    k8s_cluster_template
