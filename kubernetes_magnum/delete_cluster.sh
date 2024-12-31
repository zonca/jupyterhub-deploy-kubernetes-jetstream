#!/bin/bash

# Ensure the cluster name is provided as an argument
if [ -z "$K8S_CLUSTER_NAME" ]; then
    echo "Please set the K8S_CLUSTER_NAME environment variable."
    exit 1
fi

# Get the current node count before deletion
CURRENT_NODE_COUNT=$(openstack coe cluster show $K8S_CLUSTER_NAME -f value -c node_count)
echo "Current node count before deletion: $CURRENT_NODE_COUNT"

# Start timing
START=$(date +%s)

# Delete the cluster
openstack coe cluster delete $K8S_CLUSTER_NAME

# Poll the cluster status
echo "Waiting for the cluster to be deleted..."
while true; do
    STATUS=$(openstack coe cluster show $K8S_CLUSTER_NAME -f value -c status 2>/dev/null)
    
    if [ -z "$STATUS" ]; then
        echo "Cluster successfully deleted."
        break
    elif [ "$STATUS" == "DELETE_COMPLETE" ]; then
        echo "Cluster deletion completed successfully."
        break
    elif [ "$STATUS" == "DELETE_FAILED" ]; then
        echo "Cluster deletion failed."
        exit 1
    fi

    CURRENT=$(date +%s)
    ELAPSED=$((CURRENT - START))
    ELAPSED_MINUTES=$((ELAPSED / 60))
    echo "Time passed: $ELAPSED_MINUTES minutes. Current status: $STATUS."
    
    sleep 60
done

# End timing
END=$(date +%s)
DURATION=$((END - START))
DURATION_MINUTES=$((DURATION / 60))

# Output the elapsed time in minutes
echo "Cluster deletion took $DURATION_MINUTES minutes."
