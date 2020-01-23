FLAVOR="m1.medium"
MASTER_FLAVOR=$FLAVOR

openstack coe cluster template create --coe kubernetes \
    --image "Fedora-Atomic-27-20180419" \
    --keypair comet \
    --external-network public --fixed-network ${OS_USERNAME}-newk8s-network --fixed-subnet ${OS_USERNAME}-newk8s-subnet1 --network-driver flannel \
    --flavor $FLAVOR --master-flavor $MASTER_FLAVOR \
    --docker-storage-driver overlay2 \
    --floating-ip-enabled \
    --labels cloud-provider-enabled=true \
    --volume-driver cinder \
    k8s_cluster_template
