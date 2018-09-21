for user in $(awk '{print $1'} account.list)
do
    awk -v user="$user" '$0 ~ user {print "export OS_PROJECT_DOMAIN_NAME=tacc \nexport OS_USER_DOMAIN_NAME=tacc \nexport OS_PROJECT_NAME=TG-CDA170005 \nexport OS_USERNAME="$2"\nexport OS_PASSWORD='\''" $3 "'\'' \nexport OS_AUTH_URL=https://tacc.jetstream-cloud.org:5000/v3 \nexport OS_IDENTITY_API_VERSION=3 \nexport OS_REGION_NAME=RegionOne" }' account.list > /home/$user/openrc.sh
done
