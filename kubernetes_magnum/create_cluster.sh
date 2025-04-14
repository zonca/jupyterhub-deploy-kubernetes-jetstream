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
    $K8S_CLUSTER_NAME

# Poll the cluster status
echo "Waiting for the cluster to become ready..."
while true; do
    STATUS=$(openstack coe cluster show $K8S_CLUSTER_NAME -f value -c status)
    CURRENT=$(date +%s)
    ELAPSED=$((CURRENT - START))
    ELAPSED_MINUTES=$((ELAPSED / 60))
    echo "Time passed: $ELAPSED_MINUTES minutes. Current status: $STATUS"
    
    if [ "$STATUS" == "CREATE_COMPLETE" ]; then
        break
    elif [ "$STATUS" == "CREATE_FAILED" ]; then
        echo "Cluster creation failed."
        exit 1
    fi
    sleep 60
done

# End timing
END=$(date +%s)
DURATION=$((END - START))
DURATION_MINUTES=$((DURATION / 60))

# Output the elapsed time in minutes
echo "Cluster creation took $DURATION_MINUTES minutes."
