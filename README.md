# Deploy JupyterHub for CDMS on Jetstream


* Basic deployment with Magnum, see the [tutorial](https://zonca.github.io/2019/06/kubernetes-jupyterhub-jetstream-magnum.html), configuration files in the `kubernetes_magnum/` folder
* Will also deploy autoscaling, see the [autoscaling tutorial](https://zonca.github.io/2019/09/kubernetes-jetstream-autoscaler.html).
* Single user image: `supercdms/cdms-jupyterlab:1.8b`, [Dockerfile](https://gitlab.com/supercdms/CompInfrastructure/cdms-jupyterlab/blob/master/Dockerfile), [Docker Hub repository](https://hub.docker.com/r/supercdms/cdms-jupyterlab/tags)
