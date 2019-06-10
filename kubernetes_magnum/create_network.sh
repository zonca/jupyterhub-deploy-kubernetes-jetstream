openstack network create ${OS_USERNAME}-newk8s-network

openstack subnet create --network ${OS_USERNAME}-newk8s-network --subnet-range 10.0.0.0/24 ${OS_USERNAME}-newk8s-subnet1

openstack router create ${OS_USERNAME}-newk8s-router

openstack router add subnet ${OS_USERNAME}-newk8s-router ${OS_USERNAME}-newk8s-subnet1

openstack router set --external-gateway public ${OS_USERNAME}-newk8s-router
