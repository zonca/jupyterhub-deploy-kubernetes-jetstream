# Deploy JupyterHub for CDMS on Jetstream

## JupyterHub

* Basic deployment with Magnum, see the [tutorial](https://zonca.github.io/2019/06/kubernetes-jupyterhub-jetstream-magnum.html), configuration files in the `kubernetes_magnum/` folder, using <https://github.com/det-lab/jupyterhub-deploy-kubernetes-jetstream/tree/cdms_zonca>
* setup HTTPS <https://zonca.dev/2020/03/setup-https-kubernetes-letsencrypt.html>
* deploy CVMFS <https://zonca.dev/2020/02/cvmfs-kubernetes.html>
* Will also deploy autoscaling, see the [autoscaling tutorial](https://zonca.github.io/2019/09/kubernetes-jetstream-autoscaler.html).

## Jupyter Notebook Single user image

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

The software stack is based on <http://lcgdocs.web.cern.ch/lcgdocs/lcgreleases/introduction/>

Documentation specific to CDMS is at <https://confluence.slac.stanford.edu/display/CDMS/Using+CDMS+software+releases>

After logging in to Jupyterhub, open a terminal, then:

```
cd /cvmfs/cdms.opensciencegrid.org
. setup_cdms.sh -L
. setup_cdms.sh v01-02-01
BatRoot
```

### Note about OS support

by @bloer

The CVMFS CDMS repo supports officially CentOS 7 and SLC6. I am reasonably certain that any RedHat-derived flavor should work though (in particular I know RHEL6 works).

There is no support from CERN for newer OS's yet. There is ubuntu support; I am not building a version of the CDMS image off of that currently but probably could if there was a good reason to do so.
