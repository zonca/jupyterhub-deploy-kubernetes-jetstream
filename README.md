# Deploy JupyterHub for CDMS on Jetstream


deploy Kubernetes + JupyterHub through Magnum https://zonca.dev/2019/06/kubernetes-jupyterhub-jetstream-magnum.html, but use https://github.com/det-lab/jupyterhub-deploy-kubernetes-jetstream/tree/cdms_zonca
* Basic deployment with Magnum, see the [tutorial](https://zonca.github.io/2019/06/kubernetes-jupyterhub-jetstream-magnum.html), configuration files in the `kubernetes_magnum/` folder, using <https://github.com/det-lab/jupyterhub-deploy-kubernetes-jetstream/tree/cdms_zonca>
* setup HTTPS <https://zonca.dev/2020/03/setup-https-kubernetes-letsencrypt.html>
* deploy CVMFS <https://zonca.dev/2020/02/cvmfs-kubernetes.html>
* Will also deploy autoscaling, see the [autoscaling tutorial](https://zonca.github.io/2019/09/kubernetes-jetstream-autoscaler.html).
* Single user image: `supercdms/cdms-jupyterlab:1.8b`, [Dockerfile](https://gitlab.com/supercdms/CompInfrastructure/cdms-jupyterlab/blob/master/Dockerfile), [Docker Hub repository](https://hub.docker.com/r/supercdms/cdms-jupyterlab/tags)

## Software stack via CVMFS

The software stack is based on <http://lcgdocs.web.cern.ch/lcgdocs/lcgreleases/introduction/>

Documentation specific to CDMS is at <https://confluence.slac.stanford.edu/display/CDMS/Using+CDMS+software+releases>

### Note about OS support

by @bloer

The CVMFS CDMS repo supports officially CentOS 7 and SLC6. I am reasonably certain that any RedHat-derived flavor should work though (in particular I know RHEL6 works).

There is no support from CERN for newer OS's yet. There is ubuntu support; I am not building a version of the CDMS image off of that currently but probably could if there was a good reason to do so.
