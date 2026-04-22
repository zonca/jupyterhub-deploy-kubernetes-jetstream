# AGENTS.md

To work on this project you need access to the OpenStack API.

1) Source your `*openrc*.sh` file to load OpenStack credentials.
2) Activate the Python environment: `.venv/bin/activate`.
3) If the cluster was created with Magnum, see `kubernetes_magnum/configure_kubectl_locally.sh`.

After that you can interact with the deployment using `kubectl`, `helm`, and `openstack`.

## Getting help

If you need help with Jetstream issues, contact `help@jetstream-cloud.org`. To create a support ticket, I'll first show you the draft text locally, then create it in Gmail (work account) using smithery for you to review before sending.

## Useful contacts

- Julien Chastang: chastang@ucar.edu
- Ana Espinoza: respinoza@ucar.edu

## Email

When working with email, always use the `gog` CLI with account `andrea@andreazonca.com`.

Search emails:
```bash
gog gmail search "jetstream" --account andrea@andreazonca.com
```

## Trello

Always use the **XSEDE** board for tracking tickets and work items.

List boards:
```bash
curl -s "https://api.trello.com/1/members/me/boards?key=$TRELLO_API_KEY&token=$TRELLO_TOKEN" | jq '.[] | {name, id}'
```

Search for a card (e.g., ATS-26466):
```bash
curl -s "https://api.trello.com/1/boards/57b4d1c4c484b2620ef4df73/cards?key=$TRELLO_API_KEY&token=$TRELLO_TOKEN" | jq '.[] | select(.name | contains("ATS-26466"))'
```

## Repo layout note

Tutorials live under `zonca.dev/posts`, while Kubernetes/JupyterHub configuration files live in this repo (e.g. `nfs/`, `nbgrader/`, `config_*.yaml`). Keep that separation in mind when editing or referencing "this repo".
