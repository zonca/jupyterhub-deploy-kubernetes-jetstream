# Plan for Gateways 2023 tutorial

## Title

Interactive distributed computing with Jupyter+Python+Dask on Jetstream for Science Gateways

## Requirements

Basic Python knowledge preferred, no previous knowledge of Dask or distributed computing required.

## Before the workshop

Deploy:
* Kubernetes hopefully with Magnum, otherwise [with Kubespray](https://github.com/jetstream-cloud/js2docs/pull/46)
* [Jupyterhub](https://www.zonca.dev/posts/2022-03-31-jetstream2_jupyterhub)
* [Dask Gateway](https://www.zonca.dev/posts/2022-04-04-dask-gateway-jupyterhub)

Update all the tutorials involved, if needed.

Test all the material

Day before the workshop
* Scale up the deployment based on registered users

## Workshop program

* Users connect to the JupyterHub instance, something like `gw.jetstream-cloud.org`
* Users login via Github (any Github account works no need to lock it down)
* Show a flow-chart of the architecture of the whole system, explain that we have tutorials so that Gateways developers can deploy themselves, provide slide and webpage with all links
* Familiarize with Dask locally in Jupyter
* Connect to Dask Gateway
* Run multiple distributed computations with Dask showing scaling and statistics
* The material will be a subset of the Dask tutorial @zonca teaches at the [San Diego Summer Institute](https://github.com/sdsc/sdsc-summer-institute-2021/tree/main/2.1a_Python_for_HPC), executed on Jetstream instead of Expanse.
* Save data to object storage in Zarr format, see <https://www.zonca.dev/posts/2022-04-04-zarr_jetstream2>, maybe also read in parallel with Dask
