# AGENTS.md

To work on this project you need access to the OpenStack API.

1) Source your `*openrc*.sh` file to load OpenStack credentials.
2) Activate the Python environment: `.venv/bin/activate`.
3) If the cluster was created with Magnum, see `kubernetes_magnum/configure_kubectl_locally.sh`.

After that you can interact with the deployment using `kubectl`, `helm`, and `openstack`.

## Getting help

If you need help with Jetstream issues, contact `help@jetstream-cloud.org`. To create a support ticket, I'll first show you the draft text locally, then create it in Gmail (work account) using smithery for you to review before sending.

## Repo layout note

Tutorials live under `zonca.dev/posts`, while Kubernetes/JupyterHub configuration files live in this repo (e.g. `nfs/`, `nbgrader/`, `config_*.yaml`). Keep that separation in mind when editing or referencing "this repo".
