# JupyterHub for CDMS on Jetstream

## Instructions for new users

The deployment is available at <https://supercdms.jetstream-cloud.org>, all members of the SuperCDMS Gitlab organizations have permission to login using their Gitlab credentials.

* The CDMS software is available via CVMFS under the `/cvmfs/cdms.opensciencegrid.org` folder, see below on how to install the Jupyter Kernel
* Access [CDMS secrets repository](https://github.com/pibion/jupyterhub-deploy-kubernetes-jetstream-secrets) (ask @pibion for access) for SSH access to the data pod
* Report problems at <https://github.com/det-lab/jupyterhub-deploy-kubernetes-jetstream/issues>

### Install Jupyter Kernels

All the CDMS Jupyter Kernels can be installed in the user environment by opening a terminal and then running:

    > install_cdms_kernels

then reload JupyterLab by reloading the webpage. After this the user should see all the available CDMS kernels.
This only needs to be run once. And then run again when new releases of the software stack are made available.
Sometimes releases are removed from CVMFS, so it possible that installed kernels stop working, in this case
the user can remove them by deleting the right folder from:

    ~/.local/share/jupyter/kernels/

## Information about the deployment

* Check project progress at <https://github.com/det-lab/jupyterhub-deploy-kubernetes-jetstream/projects/1>
* See [DEPLOY.md](DEPLOY.md)
