set -e # stop script on error

SCALEUP_PENDING_MINUTES=3
MIN_WORKER_NODES=1
MAX_WORKER_NODES=4
export CLUSTER=kubejetstream

base_folder=$(pwd)

while true; do
    bash 1_get_pending.sh
    pending_minutes=$(python 2_extract_pending_min.py)
    current_worker_nodes=$(bash 3_current_nodes.sh)
    echo "Current worker nodes: $current_worker_nodes"
    if (( $pending_minutes > $SCALEUP_PENDING_MINUTES )); then
        echo "The oldest singleuser pod has been pending for $pending_minutes minutes"
        if (($current_worker_nodes < $MAX_WORKER_NODES)); then
            echo "Scale up"
            new_number_of_worker_nodes=$(($current_worker_nodes + 1))
            sed -i "s/number_of_k8s_nodes = [[:digit:]]\+/number_of_k8s_nodes = $new_number_of_worker_nodes/" kubespray/inventory/$CLUSTER/cluster.tfvars
            cd kubespray/inventory/$CLUSTER
            date -u +%s > LAST_SCALEUP
            echo "Run Terraform"
            bash terraform_apply.sh
            cd ../..
            sleep 5m
            echo "Run Ansible"
            bash k8s_scale.sh
            cd $base_folder
            sleep 10m
        fi
    else
        echo "No pods pending for more than $SCALEUP_PENDING_MINUTES minutes"
        if (( $current_worker_nodes > $MIN_WORKER_NODES )); then
            node_labels=$(bash 4_current_node_labels.sh)
            for node_label in $node_labels; do
                    num_pods=$(bash 5_get_number_of_singleuser_pods_in_node.sh $node_label)
                    if (( $num_pods == 0 )); then
                        echo "Node $node_label has no singleuser pods running"
                        #sleep 30m
                        num_pods=$(bash 5_get_number_of_singleuser_pods_in_node.sh $node_label)
                        if (( $num_pods == 0 )); then
                            echo "Removing node $node_label"
                            cd kubespray
                            bash k8s_remove_node.sh $node_label
                            openstack server delete $node_label
                            cd $base_folder
                        fi
                    fi

            done
        fi
    fi
    sleep 1m
done
