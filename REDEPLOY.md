# Documentation on how to redeploy JupyterHub without loosing data

## Save single user storage

Save the persistent volume claims:

    kubectl -n jhub get pvc -l "component=singleuser-storage" -o yaml > pvc.yaml

The persistent volumes do not have labels, so first print out the pvc:

    kubectl -n jhub get pvc -l "component=singleuser-storage"

Then copy paste the desired IDs from the VOLUME column:

    kubectl -n jhub get pv ID1 ID2 ID3 -o yaml > pv.yaml

## Tear down JupyterHub and NGINX

* `helm -n jhub delete dask-gateway jhub`
* **DO NOT DELETE THE NAMESPACE TO PRESERVE THE USER DISKS** `k delete namespace jhub`
* Check that the persistent volumes are still there with `kubectl -n jhub get pvc`

## Save the data volume

* Identify the ID of the data volume with `openstack volume list | grep 500`
* Currently it is `7681ccc9-7bdb-470f-bd6d-43587e2c2328`
* Serialize to YAML `k get pvc data-pv-claim -o yaml > existing_data_volume_claim.yaml`
* Serialize to YAML `k get pv pvc-8712010b-7512-11ea-a548-fa163eeabf17 -o yaml > existing_data_volume.yaml`

## Wipe cluster

First we don't want Kubernetes during the shutdown phase to delete the volume,
so let's stop the instance first:

`openstack server stop`

Save the floating IP:

    openstack server remove floating ip zonca-k8s-master-1 149.165.156.119

Delete the cluster with Magnum or Terraform. If this doesn't work,
delete manually from Horizon, to delete the network components, first open the network topology,
click on the networks and "delete interfaces", after that you can delete the networks and the
routers.

Check in openstack if there are volumes that needs to be deleted.

Sometimes volumes are stuck in "Deleting" or "Reserved" state, email xsede to delete them.

## Redeploy Kubernetes with Magnum or Kubespray

Follow instruction in the [README.md](https://github.com/det-lab/jupyterhub-deploy-kubernetes-jetstream/blob/master/README.md)

For kubespray, set:

    supplementary_addresses_in_ssl_keys: [149.165.156.119]

    k8s_master_fips = ["149.165.156.119"]

    
in `k8s-cluster.yml` before running ansible.
   
Once the instances are created, assign the right IP to the master instance:

    MASTER=k8s-5ohejqqnatgc-master-0
    openstack server remove floating ip $MASTER $IP
    openstack server add floating ip $MASTER 149.165.156.119 

The certificates in the cluster have the old IP, therefore we need to fix the kubectl configuration:

`kubectl_secret/config`

## Remount the data volume into CVMFS

I have saved the current Kubernetes PersistentVolume and PersistentVolumeClaim,
restore them with:

    kubectl create -f existing_data_volume.yaml
    kubectl create -f existing_data_volume_claim.yaml

Then launch the CVMFS pod:

    kubectl create -f pod_cvmfs_nfs.yaml

Open port 30022:

    SECURITY_GROUP_NAME=zonca-k8s-master
    openstack security group rule create $SECURITY_GROUP_NAME --protocol tcp --dst-port 30022:30022 --remote-ip 0.0.0.0/0

Test SSH connection with `ssh_data.sh`

## Restore the user storage

    kubectl create -f pv.yaml
    kubectl create -f pvc.yaml
