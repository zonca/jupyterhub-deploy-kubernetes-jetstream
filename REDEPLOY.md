# Documentation on how to redeploy JupyterHub without loosing data

## Tear down JupyterHub and NGINX

* `helm delete --purge jhub nginx`
* `k delete namespace jhub`

## Save the data volume

* Identify the ID of the data volume with `openstack volume list | grep 500`
* Currently it is `7681ccc9-7bdb-470f-bd6d-43587e2c2328`
* Serialize to YAML `k get pvc data-pv-claim -o yaml > existing_data_volume_claim.yaml`
* Serialize to YAML `k get pv pvc-8712010b-7512-11ea-a548-fa163eeabf17 -o yaml > existing_data_volume.yaml`

## Wipe cluster

First we don't want Kubernetes during the shutdown phase to delete the volume,
so let's stop the instance first:

`openstack server stop`

`bash delete_cluster.sh`

Now delete all the volumes that are still in Openstack, probably due to old deployments not properly teared down.

Sometimes volumes are stuck in "Deleting" or "Reserved" state, email xsede to delete them.

## Redeploy with Magnum

Follow instruction in the [README.md](https://github.com/det-lab/jupyterhub-deploy-kubernetes-jetstream/blob/master/README.md)

Once the instances are created, assign the right IP to the master instance:

    MASTER=k8s-5ohejqqnatgc-master-0
    openstack server remove floating ip $MASTER $IP
    openstack server add floating ip $MASTER 149.165.156.119

The certificates in the cluster have the old IP, therefore we need to fix the kubectl configuration:

`kubectl_secret/config`

remove the `certificate-authority` line and add:

    insecure-skip-tls-verify: true
    
just below `server:` at the same indentation level

## Remount the data volume into CVMFS

I have saved the current Kubernetes PersistentVolume and PersistentVolumeClaim,
restore them with:

    kubectl create -f existing_data_volume.yaml
    kubectl create -f existing_data_volume_claim.yaml

Then launch the CVMFS pod:

    kubectl create -f pod_cvmfs_nfs.yaml

Login to the CVMFS pod, add the public key <https://github.com/pibion/jupyterhub-deploy-kubernetes-jetstream-secrets/blob/master/ssh/cdms_nfs_ssh_key.pub> to `.ssh/authorized_keys`.

