openstack network create ${OS_USERNAME}-k8s-network

openstack subnet create --network ${OS_USERNAME}-k8s-network --subnet-range 10.0.0.0/24 ${OS_USERNAME}-k8s-subnet1
