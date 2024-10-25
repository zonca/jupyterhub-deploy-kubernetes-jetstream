#!/bin/bash
share_name="$1"
share_id=$(openstack share list --name "$share_name" -f value -c ID)
path=$(openstack share show $share_id -f value -cexport_locations | grep -oP 'path = \K.*')
access_name=$(openstack share access list "$share_id" -f value -c 'Access To' | head -n 1)
access_key=$(openstack share access list "$share_id" -f value -c 'Access Key' | head -n 1)
echo 'curl https://jetstream2.exosphere.app/exosphere/assets/scripts/mount_ceph.py | sudo python3 - mount \'
echo "--access-rule-name='$access_name' \\"
echo "--access-rule-key='$access_key' \\"
echo "--share-path='$path' \\"
echo "--share-name='$share_name'"
