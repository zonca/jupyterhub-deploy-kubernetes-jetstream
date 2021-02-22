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

### Use Dask for distributed computing

Dask is a Python package that has an array syntax very similar to `numpy` but under the hood can distribute the computation across many different "workers".
In the SuperCDMS JupyterHub deployment on Jetstream, all users by default have access only to the Jupyter Notebook instance. However, they can leverage Dask to launch more workers inside the Kubernetes cluster and parallelize their computation, having access to way more CPU and RAM.

Access to Dask is available via ["Dask Gateway"](https://gateway.dask.org/), check their documentation to know more. The deployment itself is explained in [this tutorial](https://zonca.dev/2020/08/dask-gateway-jupyterhub.html), but this is not necessary for users.

Before testing it, please notify `@zonca` on [the relevant github issue](https://github.com/det-lab/jupyterhub-deploy-kubernetes-jetstream/issues/51).

In order to test it:

* check [this notebook](https://nbviewer.jupyter.org/gist/zonca/355a7ec6b5bd3f84b1413a8c29fbc877)
* download it to your local machine clicking on the download icon on the top
* upload it to the SuperCDMS JupyterHub and open it
* replace the `js-XXX-YYY` string in one of the first cells to `supercdms`
* add `services/dask-gateway` to the URL to access the Dask dashboard
* execute the whole notebook

## Information about the deployment

* Check project progress at <https://github.com/det-lab/jupyterhub-deploy-kubernetes-jetstream/projects/1>
* See [DEPLOY.md](DEPLOY.md)
