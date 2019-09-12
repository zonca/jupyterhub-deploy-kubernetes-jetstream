openstack server create fedora_update \
    --flavor m1.medium \
    --image Fedora-Atomic-27-20180419   \
    --key-name comet \
    --security-group ${OS_USERNAME}-global-ssh \
    --nic net-id=${OS_USERNAME}-api-net
