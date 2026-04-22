# Full Magnum + JupyterHub + HTTPS (single `tofu apply`)

This folder extends the base `tofu_magnum` recipe to deploy, in one OpenTofu apply:

1. Magnum Kubernetes cluster
2. `ingress-nginx` Helm release
3. Fixed OpenStack floating IP attached to ingress load balancer
4. Jetstream DNS A record for your subdomain
5. `cert-manager` and `letsencrypt` ClusterIssuer
6. JupyterHub Helm release with ingress + TLS annotations

## Prerequisites

Run from the repository root prerequisites described in `AGENTS.md`:

1. Source OpenStack credentials (`*openrc*.sh`)
2. Activate Python env (`.venv/bin/activate`)
3. Ensure tools are available in `PATH`: `tofu`, `openstack`, `kubectl`, `helm`

## Usage

```bash
cd tofu_magnum/full_stack_https
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars

tofu init
tofu apply
```

After apply, OpenTofu prints:

- `jupyterhub_url` (expected HTTPS URL)
- `ingress_fixed_ip`
- `kubeconfig_path`

## Notes

- Base JupyterHub values are loaded from `../../config_standard_storage.yaml` by default.
- Generated files in this folder:
  - `config` (kubeconfig)
  - `rendered-secrets.yaml`
  - `rendered-https-cluster-issuer.yml`
- The ingress floating IP rebind is performed with `openstack` CLI, following the same flow as the tutorial.
- If your DNS zone name differs from `<project_id>.projects.jetstream-cloud.org.`, set `dns_zone_name` in `terraform.tfvars`.
