#!/bin/bash

# We can override the default values of the template
FLAVOR="m3.small"
TEMPLATE="kubernetes-1-30-jammy"
MASTER_FLAVOR=$FLAVOR
DOCKER_VOLUME_SIZE_GB=10

# Number of instances
N_MASTER=3 # Needs to be odd
N_NODES=1

# Start timing
START=$(date +%s)

# Create the cluster
openstack coe cluster create --cluster-template $TEMPLATE \
    --master-count $N_MASTER --node-count $N_NODES \
    --master-flavor $MASTER_FLAVOR --flavor $FLAVOR \
    --docker-volume-size $DOCKER_VOLUME_SIZE_GB \
    --labels auto_scaling_enabled=true \
    --labels min_node_count=1 \
    --labels max_node_count=5 \
    $K8S_CLUSTER_NAME

# Poll the cluster status
echo "Waiting for the cluster to become ready..."
while true; do
    STATUS=$(openstack coe cluster show $K8S_CLUSTER_NAME -f value -c status)
    echo "Current status: $STATUS"
    if [ "$STATUS" == "CREATE_COMPLETE" ]; then
        break
    elif [ "$STATUS" == "CREATE_FAILED" ]; then
        echo "Cluster creation failed."
        exit 1
    fi
    sleep 10
done

# End timing
END=$(date +%s)
DURATION=$((END - START))

# Convert duration to minutes and seconds
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

# Output the elapsed time
echo "Cluster creation took $MINUTES minutes and $SECONDS seconds."
