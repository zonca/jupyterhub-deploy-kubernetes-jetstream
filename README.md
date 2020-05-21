# Deploy JupyterHub for CDMS on Jetstream

The deployment is available at <https://supercdms.jetstream-cloud.org>, all members of the SuperCDMS Gitlab organizations have permission to login.

* Access [CDMS secrets repository](https://github.com/pibion/jupyterhub-deploy-kubernetes-jetstream-secrets) (ask @pibion for access) for SSH access to the data pod
* Check project progress at <https://github.com/det-lab/jupyterhub-deploy-kubernetes-jetstream/projects/1>
* Report problems at <https://github.com/det-lab/jupyterhub-deploy-kubernetes-jetstream/issues>

## JupyterHub

* Basic deployment with Magnum, see the [tutorial](https://zonca.github.io/2020/05/kubernetes-jupyterhub-jetstream-magnum.html), configuration files in the `kubernetes_magnum/` folder, using <https://github.com/det-lab/jupyterhub-deploy-kubernetes-jetstream/>
* setup HTTPS <https://zonca.dev/2020/03/setup-https-kubernetes-letsencrypt.html>
* deploy CVMFS <https://zonca.dev/2020/02/cvmfs-kubernetes.html>
* Will also deploy autoscaling, see the [autoscaling tutorial](https://zonca.github.io/2019/09/kubernetes-jetstream-autoscaler.html).

## Jupyter Notebook Single user image

[Issue with the discussion about the software environment](https://github.com/det-lab/jupyterhub-deploy-kubernetes-jetstream/issues/3)

First rebuilt the Jupyter Docker stacks out of Centos 7 instead of Ubuntu (see note about OS support below),
see:

<https://github.com/zonca/jupyter-docker-stacks-centos7>

I build this manually (later will possibly setup autobuild) and push to Docker Hub:

<https://hub.docker.com/repository/docker/zonca/jupyter-docker-stacks-centos7>

We are interested in the image tagged `tensorflow`.

Finally we inherit from that image to create `docker-jupyter-cdms-light`:

<https://github.com/zonca/docker-jupyter-cdms-light>

This is setup with autobuild, currently doesn't have any customization, but
we can make pull requests to this repository to add additional packages.
As examples, checkout the `Dockerfile` files in <https://github.com/zonca/jupyter-docker-stacks-centos7>

## Software stack via CVMFS

* The pod that runs CVMFS, the NFS server and the SSH server is based on the docker container at <https://github.com/zonca/docker-cvmfs-client>, which is automatically built on [Dockerhub as `zonca/cvmfs-client-nfs`](https://hub.docker.com/repository/docker/zonca/cvmfs-client-nfs)
* [Issue with the discussion about integrating CVMFS](https://github.com/det-lab/jupyterhub-deploy-kubernetes-jetstream/issues/4)
* [Tutorial for the deployment of CVMFS on top of Kubernetes](https://zonca.dev/2020/02/cvmfs-kubernetes.html)

The software stack is based on <http://lcgdocs.web.cern.ch/lcgdocs/lcgreleases/introduction/>

Documentation specific to CDMS is at <https://confluence.slac.stanford.edu/display/CDMS/Using+CDMS+software+releases>

After logging in to Jupyterhub, open a terminal, then:

```
cd /cvmfs/cdms.opensciencegrid.org
. setup_cdms.sh -L
. setup_cdms.sh v01-02-01
BatRoot
```

### Install Jupyter Kernels

All the CDMS Jupyter Kernels can be installed in the user environment by opening a terminal and then running:

    > install_cdms_kernels
    
the reload JupyterLab by reloading the webpage. After this the user should see all the available CDMS kernels.
This only needs to be run once. And then run again when new releases of the software stack are made available.
Sometimes releases are removed from CVMFS, so it possible that installed kernels stop working, in this case
the user can remove them by deleting the right folder from:

    ~/.local/share/jupyter/kernels/

**Note about OS support**

by @bloer

The CVMFS CDMS repo supports officially CentOS 7 and SLC6. I am reasonably certain that any RedHat-derived flavor should work though (in particular I know RHEL6 works).

There is no support from CERN for newer OS's yet. There is ubuntu support; I am not building a version of the CDMS image off of that currently but probably could if there was a good reason to do so.

## Data volume

The same pod that runs CVMFS also mounts a large volume (currently 500GB), this is made available to
all Jupyter Notebook containers via NFS at `/cvmfs/data/`. The filesystem location is just for convenience,
this has nothing to do with CVMFS.
The filesystem is readable and writable by all the Jupyter Notebook users, the Jupyter Notebook users run
as the user `jovyan` so everyone can delete everyone else data.
However if we copy data there via SSH (see below) the folders are owned by root, therefore all users can
read the data but not delete them, so by default large amounts of data copied via SSH are protected.
To make folders created via SSH writable by users, modify permissions:

    chmod -R a+wx writable_folder

### Copy data to the data volume

The CVMFS pod also has a public facing SSH server running on port 30022 on the master node,
it only supports SSH key authentication.
You need to get the private key from the [CDMS secrets repository](https://github.com/pibion/jupyterhub-deploy-kubernetes-jetstream-secrets) (ask @pibion for access) then:

    ssh -i cdms_nfs_ssh_key -p 30022 root@js-xxx-xxx.jetstream-cloud.org

making sure you get the current address of the master node, also from the secrets repository.

## Resource usage

```
--------------- SU usage for the minimum scenario
1 m1.medium master - 0 m1.xlarge workers
6 SU/hour
144 SU/day
4,320 SU/month
--------------- SU usage for the average scenario
1 m1.medium master - 3 m1.xlarge workers
78 SU/hour
1,872 SU/day
56,160 SU/month
--------------- SU usage for the maximum scenario
1 m1.medium master - 6 m1.xlarge workers
150 SU/hour
3,600 SU/day
108,000 SU/month
```

[Issue with more details](https://github.com/det-lab/jupyterhub-deploy-kubernetes-jetstream/issues/2#issuecomment-567164886)

## Other documentation

How to run the CDMS container:

```
sudo docker run -it --user 1000:1000 supercdms/cdms-jupyterlab:1.8b /opt/rh/rh-python36/root/bin/ipython3
```

Read raw data:

```
series="09190321_1522"
filepath = series + "/"
os.mkdir(series)

from requests.auth import HTTPBasicAuth
a = requests.get(url, auth=HTTPBasicAuth("user", "password"))
with open(filepath + "09190321_1522_F0001.mid.gz","wb") as out:
    out.write(a.content)
ev=getRawEvents(filepath,series)
ev.head(2)
```
