# we can override the default values of the template
FLAVOR="m1.medium"
MASTER_FLAVOR=$FLAVOR
DOCKER_VOLUME_SIZE_GB=10

# number of instances
N_MASTER=1
N_NODES=1

openstack coe cluster create --cluster-template k8s_cluster_template \
    --master-count $N_MASTER --node-count $N_NODES \
    --keypair comet \
    --master-flavor $MASTER_FLAVOR --flavor $FLAVOR \
    --docker-volume-size $DOCKER_VOLUME_SIZE_GB k8s
