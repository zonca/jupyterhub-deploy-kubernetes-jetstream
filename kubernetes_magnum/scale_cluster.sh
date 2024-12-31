#!/bin/bash

# Ensure the new node count is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <new_node_count>"
    exit 1
fi

NEW_NODE_COUNT=$1

# Get the current node count and display it
CURRENT_NODE_COUNT=$(openstack coe cluster show k8s -f value -c node_count)
echo "Current node count: $CURRENT_NODE_COUNT"

# Start timing
START=$(date +%s)

# Update the cluster
openstack coe cluster update k8s replace node_count=$NEW_NODE_COUNT

# Poll the cluster status
echo "Waiting for the cluster update to complete..."
while true; do
    STATUS=$(openstack coe cluster show k8s -f value -c status)
    CURRENT=$(date +%s)
    ELAPSED=$((CURRENT - START))
    ELAPSED_MINUTES=$((ELAPSED / 60))
    echo "Time passed: $ELAPSED_MINUTES minutes. Current status: $STATUS."
    
    if [ "$STATUS" == "UPDATE_COMPLETE" ]; then
        break
    elif [ "$STATUS" == "UPDATE_FAILED" ]; then
        echo "Cluster update failed."
        exit 1
    fi
    sleep 60
done

# End timing
END=$(date +%s)
DURATION=$((END - START))
DURATION_MINUTES=$((DURATION / 60))

# Output the elapsed time in minutes
echo "Cluster update took $DURATION_MINUTES minutes."
