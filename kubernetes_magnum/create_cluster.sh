# we can override the default values of the template
FLAVOR="m3.small"
TEMPLATE="kubernetes-1-30-jammy"
MASTER_FLAVOR=$FLAVOR
DOCKER_VOLUME_SIZE_GB=10

# number of instances
N_MASTER=3 # needs to be odd
N_NODES=1

openstack coe cluster create --cluster-template $TEMPLATE \
    --master-count $N_MASTER --node-count $N_NODES \
    --master-flavor $MASTER_FLAVOR --flavor $FLAVOR \
    --docker-volume-size $DOCKER_VOLUME_SIZE_GB \
    --labels auto_scaling_enabled=true \
    --labels min_node_count=1 \
    --labels max_node_count=5 \
    $K8S_CLUSTER_NAME
