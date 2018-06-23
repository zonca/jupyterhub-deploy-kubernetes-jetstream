openstack network create ${OS_USERNAME}-api-net

openstack subnet create --network ${OS_USERNAME}-api-net --subnet-range 10.0.0.0/24 ${OS_USERNAME}-api-subnet1
